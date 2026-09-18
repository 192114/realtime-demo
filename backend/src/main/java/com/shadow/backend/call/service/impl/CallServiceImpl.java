package com.shadow.backend.call.service.impl;

import com.shadow.backend.call.config.LiveKitProperties;
import com.shadow.backend.call.constant.CallStatus;
import com.shadow.backend.call.dto.InitiateCallRequest;
import com.shadow.backend.call.entity.CallSession;
import com.shadow.backend.call.mapper.CallSessionMapper;
import com.shadow.backend.call.response.CallResultCode;
import com.shadow.backend.call.service.CallService;
import com.shadow.backend.call.service.LiveKitTokenService;
import com.shadow.backend.call.vo.CallCursorPageVO;
import com.shadow.backend.call.vo.CallVO;
import com.shadow.backend.chat.entity.ChatConversation;
import com.shadow.backend.chat.mapper.ChatConversationMapper;
import com.shadow.backend.common.exception.BusinessException;
import com.shadow.backend.user.constant.AuditStatus;
import com.shadow.backend.user.entity.User;
import com.shadow.backend.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CallServiceImpl implements CallService {
    private final CallSessionMapper callMapper;
    private final ChatConversationMapper conversationMapper;
    private final UserMapper userMapper;
    private final LiveKitTokenService tokenService;
    private final LiveKitProperties liveKitProperties;
    private final CallEventComposer composer;
    private final CallChatRecorder recorder;

    @Override
    @Transactional(isolation = Isolation.READ_COMMITTED)
    public CallVO initiate(Long userId, InitiateCallRequest request) {
        requirePositive(userId);
        if (request == null || request.getCalleeId() == null || request.getCalleeId() <= 0
                || request.getMediaType() == null
                || !request.getMediaType().matches(InitiateCallRequest.MEDIA_TYPE_PATTERN)) {
            throw new BusinessException(CallResultCode.INVALID_ARGUMENT);
        }
        Long calleeId = request.getCalleeId();
        if (userId.equals(calleeId)) {
            throw new BusinessException(CallResultCode.SELF_CALL_FORBIDDEN);
        }
        User caller = requireActiveUser(userId);
        requireActiveUser(calleeId);
        Long low = Math.min(userId, calleeId);
        Long high = Math.max(userId, calleeId);
        LocalDateTime now = utcNow();
        // 通话与消息共享同一单聊会话上下文；会话行锁同时串行化同对用户的并发呼叫。
        conversationMapper.createDirect(low, high, now);
        ChatConversation conversation = conversationMapper.lockPair(low, high);
        if (callMapper.findActiveByPair(userId, calleeId) != null) {
            throw new BusinessException(CallResultCode.CALL_ALREADY_ACTIVE);
        }
        CallSession call = new CallSession();
        call.setCallId(UUID.randomUUID().toString());
        call.setConversationId(conversation.getId());
        call.setCallerId(userId);
        call.setCalleeId(calleeId);
        call.setStatus(CallStatus.CALLING.getValue());
        call.setMediaType(request.getMediaType());
        call.setCreatedAt(now);
        callMapper.insert(call);
        composer.emit(call, "call.created", now);
        return toResponse(call, userId, caller.getNickname());
    }

    @Override
    @Transactional
    public CallVO accept(Long userId, String callId) {
        CallSession call = requireLockedCall(userId, callId);
        requireCallee(call, userId);
        // 重复接听与终态后接听均幂等返回当前状态，不重复发事件。
        if (CallStatus.fromValue(call.getStatus()) != CallStatus.CALLING) {
            return toResponse(call, userId, nicknameOf(userId));
        }
        LocalDateTime now = utcNow();
        call.setStatus(CallStatus.IN_CALL.getValue());
        call.setAcceptedAt(now);
        callMapper.updateById(call);
        composer.emit(call, "call.accepted", now);
        return toResponse(call, userId, nicknameOf(userId));
    }

    @Override
    @Transactional
    public CallVO reject(Long userId, String callId) {
        CallSession call = requireLockedCall(userId, callId);
        requireCallee(call, userId);
        CallStatus status = CallStatus.fromValue(call.getStatus());
        if (status == CallStatus.IN_CALL) {
            throw new BusinessException(CallResultCode.CALL_STATE_CONFLICT);
        }
        if (status.isTerminal()) {
            return toResponse(call, userId, nicknameOf(userId));
        }
        finish(call, CallStatus.REJECTED, "rejected", "call.rejected");
        return toResponse(call, userId, nicknameOf(userId));
    }

    @Override
    @Transactional
    public CallVO cancel(Long userId, String callId) {
        CallSession call = requireLockedCall(userId, callId);
        requireCaller(call, userId);
        CallStatus status = CallStatus.fromValue(call.getStatus());
        if (status == CallStatus.IN_CALL) {
            throw new BusinessException(CallResultCode.CALL_STATE_CONFLICT);
        }
        if (status.isTerminal()) {
            return toResponse(call, userId, nicknameOf(userId));
        }
        finish(call, CallStatus.CANCELLED, "cancelled", "call.cancelled");
        return toResponse(call, userId, nicknameOf(userId));
    }

    @Override
    @Transactional
    public CallVO end(Long userId, String callId) {
        CallSession call = requireLockedCall(userId, callId);
        CallStatus status = CallStatus.fromValue(call.getStatus());
        if (status == CallStatus.CALLING) {
            throw new BusinessException(CallResultCode.CALL_STATE_CONFLICT);
        }
        if (status.isTerminal()) {
            return toResponse(call, userId, nicknameOf(userId));
        }
        finish(call, CallStatus.ENDED, "hangup", "call.ended");
        return toResponse(call, userId, nicknameOf(userId));
    }

    @Override
    @Transactional(readOnly = true, isolation = Isolation.REPEATABLE_READ)
    public CallVO activeCall(Long userId) {
        requirePositive(userId);
        requireActiveUser(userId);
        CallSession call = callMapper.findActiveByUser(userId);
        return call == null ? null : toResponse(call, userId, nicknameOf(userId));
    }

    @Override
    @Transactional(readOnly = true, isolation = Isolation.REPEATABLE_READ)
    public CallCursorPageVO<CallVO> records(Long userId, Long beforeId, int limit) {
        validatePage(beforeId, limit, 100, true);
        requireActiveUser(userId);
        List<CallSession> rows = callMapper.findPageByUser(userId, beforeId, limit + 1);
        List<CallVO> items = rows.stream().limit(limit).map(composer::payloadOf).toList();
        Long cursor = items.isEmpty() ? null : rows.get(items.size() - 1).getId();
        return new CallCursorPageVO<>(items, rows.size() > limit, cursor);
    }

    @Override
    @Transactional
    public void onRoomFinished(String callId) {
        CallSession call = callMapper.lockByCallId(callId);
        // 未知房间、未接听或已结束的通话均幂等忽略，不重复发事件。
        if (call == null || CallStatus.fromValue(call.getStatus()) != CallStatus.IN_CALL) {
            return;
        }
        finish(call, CallStatus.ENDED, "room_finished", "call.ended");
    }

    private void finish(CallSession call, CallStatus target, String reason, String eventType) {
        LocalDateTime now = utcNow();
        call.setStatus(target.getValue());
        call.setEndReason(reason);
        call.setEndedAt(now);
        callMapper.updateById(call);
        composer.emit(call, eventType, now);
        // 终态同步回写一条聊天记录，与状态更新同事务：回滚则两者都不生效。
        recorder.record(call, now);
    }

    private CallSession requireLockedCall(Long userId, String callId) {
        requirePositive(userId);
        if (callId == null || callId.isBlank() || callId.length() > 36) {
            throw new BusinessException(CallResultCode.INVALID_ARGUMENT);
        }
        CallSession call = callMapper.lockByCallId(callId);
        // 不区分不存在和非成员，避免泄露其他用户的通话存在性。
        if (call == null || (!userId.equals(call.getCallerId()) && !userId.equals(call.getCalleeId()))) {
            throw new BusinessException(CallResultCode.CALL_FORBIDDEN);
        }
        // 结束、接听等状态操作不要求账号仍处于启用状态，避免账号停用导致通话悬挂。
        return call;
    }

    private void requireCallee(CallSession call, Long userId) {
        if (!userId.equals(call.getCalleeId())) {
            throw new BusinessException(CallResultCode.CALL_FORBIDDEN);
        }
    }

    private void requireCaller(CallSession call, Long userId) {
        if (!userId.equals(call.getCallerId())) {
            throw new BusinessException(CallResultCode.CALL_FORBIDDEN);
        }
    }

    private CallVO toResponse(CallSession call, Long userId, String nickname) {
        CallVO vo = composer.payloadOf(call);
        CallStatus status = CallStatus.fromValue(call.getStatus());
        // LiveKit 未启用时仅提供信令状态机；媒体字段（roomName/liveKitUrl/token）不下发，
        // 避免空 API Key 签发 JWT 抛出 IllegalArgumentException 导致信令接口 500。
        if (liveKitProperties.isEnabled() && (status == CallStatus.CALLING || status == CallStatus.IN_CALL)) {
            vo.setRoomName(tokenService.roomName(call.getCallId()));
            vo.setLiveKitUrl(liveKitProperties.getUrl());
            vo.setToken(tokenService.issue(call.getCallId(), userId, nickname));
        }
        return vo;
    }

    private User requireActiveUser(Long userId) {
        requirePositive(userId);
        User user = userMapper.selectById(userId);
        // 现有状态约定为 1 启用，审核状态必须为枚举 APPROVED；异常/空状态一律拒绝。
        if (user == null || !Integer.valueOf(1).equals(user.getStatus())
                || !Integer.valueOf(0).equals(user.getDeleted())
                || AuditStatus.fromValue(user.getAuditStatus()) != AuditStatus.APPROVED) {
            throw new BusinessException(CallResultCode.USER_UNAVAILABLE);
        }
        return user;
    }

    private String nicknameOf(Long userId) {
        User user = userMapper.selectById(userId);
        return user == null ? null : user.getNickname();
    }

    private void validatePage(Long cursor, int limit, int maxLimit, boolean optionalPositive) {
        if (limit < 1 || limit > maxLimit || (optionalPositive && cursor != null && cursor <= 0)) {
            throw new BusinessException(CallResultCode.INVALID_ARGUMENT);
        }
    }

    private void requirePositive(Long value) {
        if (value == null || value <= 0) {
            throw new BusinessException(CallResultCode.INVALID_ARGUMENT);
        }
    }

    private LocalDateTime utcNow() {
        return LocalDateTime.now(ZoneOffset.UTC).truncatedTo(ChronoUnit.MICROS);
    }
}
