package com.shadow.backend.chat.service.impl;

import com.shadow.backend.chat.dto.SendMessageRequest;
import com.shadow.backend.chat.entity.ChatConversation;
import com.shadow.backend.chat.entity.ChatMessage;
import com.shadow.backend.chat.entity.ChatOutbox;
import com.shadow.backend.chat.mapper.ChatConversationMapper;
import com.shadow.backend.chat.mapper.ChatMessageMapper;
import com.shadow.backend.chat.mapper.ChatOutboxMapper;
import com.shadow.backend.chat.response.ChatResultCode;
import com.shadow.backend.chat.service.ChatService;
import com.shadow.backend.chat.vo.ChatConversationVO;
import com.shadow.backend.chat.vo.ChatCursorPageVO;
import com.shadow.backend.chat.vo.ChatEventVO;
import com.shadow.backend.chat.vo.ChatMessageVO;
import com.shadow.backend.chat.vo.ChatReadVO;
import com.shadow.backend.common.exception.BusinessException;
import com.shadow.backend.user.constant.AuditStatus;
import com.shadow.backend.user.entity.User;
import com.shadow.backend.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import tools.jackson.databind.json.JsonMapper;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {
    private static final Pattern CLIENT_ID = Pattern.compile(SendMessageRequest.CLIENT_MSG_ID_PATTERN);

    private final ChatConversationMapper conversationMapper;
    private final ChatMessageMapper messageMapper;
    private final ChatOutboxMapper outboxMapper;
    private final UserMapper userMapper;
    private final JsonMapper jsonMapper;

    @Override
    @Transactional(isolation = Isolation.READ_COMMITTED)
    public ChatConversationVO createDirect(Long userId, Long peerUserId) {
        requirePositive(userId);
        requirePositive(peerUserId);
        if (userId.equals(peerUserId)) {
            throw new BusinessException(ChatResultCode.SELF_CHAT_FORBIDDEN);
        }
        requireActiveUser(userId);
        User peer = requireActiveUser(peerUserId);
        Long low = Math.min(userId, peerUserId);
        Long high = Math.max(userId, peerUserId);
        conversationMapper.createDirect(low, high, utcNow());
        ChatConversation conversation = conversationMapper.lockPair(low, high);
        return toConversationVO(conversation, userId, peer);
    }

    @Override
    @Transactional(readOnly = true, isolation = Isolation.REPEATABLE_READ)
    public ChatCursorPageVO<ChatConversationVO> conversations(Long userId, Long beforeId, int limit) {
        validatePage(beforeId, limit, 100, true);
        requireActiveUser(userId);
        List<ChatConversation> rows = conversationMapper.findPage(userId, beforeId, limit + 1,
                AuditStatus.APPROVED.getValue());
        List<ChatConversationVO> items = rows.stream().limit(limit)
                .map(row -> toConversationVO(row, userId, requireActiveUser(peerId(row, userId))))
                .toList();
        Long cursor = items.isEmpty() ? null : items.getLast().getConversationId();
        return new ChatCursorPageVO<>(items, rows.size() > limit, cursor);
    }

    @Override
    @Transactional(readOnly = true, isolation = Isolation.REPEATABLE_READ)
    public ChatCursorPageVO<ChatMessageVO> history(Long userId, Long conversationId, Long beforeSeq, int limit) {
        validatePage(beforeSeq, limit, 100, true);
        requireConversation(userId, conversationId, false);
        return messagePage(messageMapper.history(conversationId, beforeSeq, limit + 1), limit);
    }

    @Override
    @Transactional(readOnly = true, isolation = Isolation.REPEATABLE_READ)
    public ChatCursorPageVO<ChatMessageVO> sync(Long userId, Long conversationId, Long afterSeq, int limit) {
        validatePage(afterSeq, limit, 500, false);
        requireConversation(userId, conversationId, false);
        return messagePage(messageMapper.sync(conversationId, afterSeq, limit + 1), limit);
    }

    @Override
    @Transactional
    public ChatMessageVO send(Long userId, Long conversationId, SendMessageRequest request) {
        validateMessage(request);
        ChatConversation conversation = requireConversation(userId, conversationId, true);
        // 必须在会话锁后查询幂等键，且不修改文本或对 UUID 做大小写归一化。
        ChatMessage existing = messageMapper.findIdempotent(conversationId, userId, request.getClientMsgId());
        if (existing != null) {
            if (!existing.getText().equals(request.getText())) {
                throw new BusinessException(ChatResultCode.CLIENT_MESSAGE_CONFLICT);
            }
            return toMessageVO(existing);
        }
        if (conversation.getLastSeq() == Long.MAX_VALUE) {
            throw new BusinessException(ChatResultCode.SEQUENCE_EXHAUSTED);
        }
        LocalDateTime now = utcNow();
        ChatMessage message = new ChatMessage();
        message.setConversationId(conversationId);
        message.setSenderId(userId);
        message.setClientMsgId(request.getClientMsgId());
        message.setType(ChatMessage.TYPE_TEXT);
        message.setSeq(conversation.getLastSeq() + 1);
        message.setText(request.getText());
        message.setCreatedAt(now);
        messageMapper.insert(message);
        conversation.setLastSeq(message.getSeq());
        conversation.setLastText(message.getText());
        conversation.setUpdatedAt(now);
        conversationMapper.updateById(conversation);
        ChatMessageVO vo = toMessageVO(message);
        enqueue(conversation, new ChatEventVO<>(UUID.randomUUID().toString(), "message.created", 1,
                conversationId, message.getId(), message.getSeq(), iso(now), vo), now);
        return vo;
    }

    @Override
    @Transactional
    public ChatReadVO read(Long userId, Long conversationId, Long seq) {
        if (seq == null || seq < 0) {
            throw new BusinessException(ChatResultCode.INVALID_ARGUMENT);
        }
        ChatConversation conversation = requireConversation(userId, conversationId, true);
        Long current = readSeq(conversation, userId);
        // 截断超前上报，禁止把尚未存在的消息提前标记为已读。
        Long target = Math.max(current, Math.min(seq, conversation.getLastSeq()));
        if (target.equals(current)) {
            return new ChatReadVO(current);
        }
        if (userId.equals(conversation.getUserLowId())) {
            conversation.setLowReadSeq(target);
        } else {
            conversation.setHighReadSeq(target);
        }
        LocalDateTime now = utcNow();
        conversation.setUpdatedAt(now);
        conversationMapper.updateById(conversation);
        enqueue(conversation, new ChatEventVO<>(UUID.randomUUID().toString(), "conversation.read", 1,
                conversationId, null, target, iso(now), new ChatEventVO.ReadPayload(userId, target)), now);
        return new ChatReadVO(target);
    }

    private ChatConversation requireConversation(Long userId, Long conversationId, boolean lock) {
        requirePositive(userId);
        requirePositive(conversationId);
        ChatConversation conversation = lock ? conversationMapper.lockById(conversationId)
                : conversationMapper.selectById(conversationId);
        // 不区分不存在和非成员，避免泄露其他用户的会话存在性。
        if (conversation == null || (!userId.equals(conversation.getUserLowId())
                && !userId.equals(conversation.getUserHighId()))) {
            throw new BusinessException(ChatResultCode.CONVERSATION_FORBIDDEN);
        }
        requireActiveUser(userId);
        requireActiveUser(peerId(conversation, userId));
        return conversation;
    }

    private User requireActiveUser(Long userId) {
        requirePositive(userId);
        User user = userMapper.selectById(userId);
        // 现有状态约定为 1 启用，审核状态必须为枚举 APPROVED；异常/空状态一律拒绝。
        if (user == null || !Integer.valueOf(1).equals(user.getStatus())
                || !Integer.valueOf(0).equals(user.getDeleted())
                || AuditStatus.fromValue(user.getAuditStatus()) != AuditStatus.APPROVED) {
            throw new BusinessException(ChatResultCode.USER_UNAVAILABLE);
        }
        return user;
    }

    private void enqueue(ChatConversation conversation, ChatEventVO<?> event, LocalDateTime now) {
        String payload = jsonMapper.writeValueAsString(event);
        for (Long recipient : List.of(conversation.getUserLowId(), conversation.getUserHighId())) {
            ChatOutbox row = new ChatOutbox();
            row.setEventId(event.getEventId());
            row.setRecipientId(recipient);
            row.setTopic("chat/user/" + recipient + "/events");
            row.setPayload(payload);
            row.setAttempts(0);
            row.setNextAttemptAt(now);
            row.setCreatedAt(now);
            outboxMapper.insert(row);
        }
    }

    private ChatConversationVO toConversationVO(ChatConversation row, Long userId, User peer) {
        Long read = readSeq(row, userId);
        return new ChatConversationVO(row.getId(), peer.getId(), peer.getNickname(), row.getLastSeq(), read,
                readSeq(row, peer.getId()), messageMapper.countUnread(row.getId(), peer.getId(), read),
                row.getLastText(), iso(row.getUpdatedAt()));
    }

    private ChatCursorPageVO<ChatMessageVO> messagePage(List<ChatMessage> rows, int limit) {
        List<ChatMessageVO> items = rows.stream().limit(limit).map(this::toMessageVO).toList();
        Long cursor = items.isEmpty() ? null : items.getLast().getSeq();
        return new ChatCursorPageVO<>(items, rows.size() > limit, cursor);
    }

    private ChatMessageVO toMessageVO(ChatMessage message) {
        return new ChatMessageVO(message.getId(), message.getConversationId(), message.getSenderId(),
                message.getClientMsgId(), message.getType(), message.getCallId(), message.getSeq(),
                message.getText(), iso(message.getCreatedAt()));
    }

    private Long peerId(ChatConversation row, Long userId) {
        return userId.equals(row.getUserLowId()) ? row.getUserHighId() : row.getUserLowId();
    }

    private Long readSeq(ChatConversation row, Long userId) {
        return userId.equals(row.getUserLowId()) ? row.getLowReadSeq() : row.getHighReadSeq();
    }

    private void validateMessage(SendMessageRequest request) {
        if (request == null || request.getClientMsgId() == null
                || !CLIENT_ID.matcher(request.getClientMsgId()).matches()
                || !StringUtils.hasText(request.getText())
                || request.getText().length() > SendMessageRequest.MAX_TEXT_LENGTH) {
            throw new BusinessException(ChatResultCode.INVALID_ARGUMENT);
        }
    }

    private void validatePage(Long cursor, int limit, int maxLimit, boolean optionalPositive) {
        if (limit < 1 || limit > maxLimit || (optionalPositive && cursor != null && cursor <= 0)
                || (!optionalPositive && (cursor == null || cursor < 0))) {
            throw new BusinessException(ChatResultCode.INVALID_ARGUMENT);
        }
    }

    private void requirePositive(Long value) {
        if (value == null || value <= 0) {
            throw new BusinessException(ChatResultCode.INVALID_ARGUMENT);
        }
    }

    private LocalDateTime utcNow() {
        return LocalDateTime.now(ZoneOffset.UTC).truncatedTo(ChronoUnit.MICROS);
    }

    private String iso(LocalDateTime time) {
        return time.toInstant(ZoneOffset.UTC).toString();
    }
}
