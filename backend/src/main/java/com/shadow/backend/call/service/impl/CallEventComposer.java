package com.shadow.backend.call.service.impl;

import com.shadow.backend.call.entity.CallSession;
import com.shadow.backend.call.vo.CallEventVO;
import com.shadow.backend.call.vo.CallVO;
import com.shadow.backend.chat.entity.ChatOutbox;
import com.shadow.backend.chat.mapper.ChatOutboxMapper;
import com.shadow.backend.user.entity.User;
import com.shadow.backend.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import tools.jackson.databind.json.JsonMapper;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

/**
 * 组装通话事件并写入聊天 Outbox，复用其至少一次投递与租约恢复机制。
 * 事件负载不含 LiveKit Token、地址等只属于参与者 HTTPS 响应的字段。
 */
@Service
@RequiredArgsConstructor
public class CallEventComposer {
    private final ChatOutboxMapper outboxMapper;
    private final UserMapper userMapper;
    private final JsonMapper jsonMapper;

    public CallVO payloadOf(CallSession call) {
        User caller = userMapper.selectById(call.getCallerId());
        User callee = userMapper.selectById(call.getCalleeId());
        CallVO vo = new CallVO();
        vo.setCallId(call.getCallId());
        vo.setConversationId(call.getConversationId());
        vo.setCallerId(call.getCallerId());
        vo.setCallerNickname(caller == null ? null : caller.getNickname());
        vo.setCalleeId(call.getCalleeId());
        vo.setCalleeNickname(callee == null ? null : callee.getNickname());
        vo.setStatus(call.getStatus());
        vo.setMediaType(call.getMediaType());
        vo.setEndReason(call.getEndReason());
        vo.setCreatedAt(iso(call.getCreatedAt()));
        vo.setAcceptedAt(iso(call.getAcceptedAt()));
        vo.setEndedAt(iso(call.getEndedAt()));
        vo.setDurationSeconds(duration(call));
        return vo;
    }

    public void emit(CallSession call, String eventType, LocalDateTime now) {
        CallEventVO<CallVO> event = new CallEventVO<>(UUID.randomUUID().toString(), eventType, 1,
                call.getCallId(), iso(now), payloadOf(call));
        String payload = jsonMapper.writeValueAsString(event);
        for (Long recipient : List.of(call.getCallerId(), call.getCalleeId())) {
            ChatOutbox row = new ChatOutbox();
            row.setEventId(event.getEventId());
            row.setRecipientId(recipient);
            row.setTopic("chat/user/" + recipient + "/calls");
            row.setPayload(payload);
            row.setAttempts(0);
            row.setNextAttemptAt(now);
            row.setCreatedAt(now);
            outboxMapper.insert(row);
        }
    }

    private Long duration(CallSession call) {
        if (call.getAcceptedAt() == null || call.getEndedAt() == null) {
            return null;
        }
        return Math.max(0, Duration.between(call.getAcceptedAt(), call.getEndedAt()).toSeconds());
    }

    private String iso(LocalDateTime time) {
        return time == null ? null : time.toInstant(ZoneOffset.UTC).toString();
    }
}
