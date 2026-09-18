package com.shadow.backend.call.service.impl;

import com.shadow.backend.call.constant.CallStatus;
import com.shadow.backend.call.entity.CallSession;
import com.shadow.backend.call.response.CallResultCode;
import com.shadow.backend.chat.entity.ChatConversation;
import com.shadow.backend.chat.entity.ChatMessage;
import com.shadow.backend.chat.entity.ChatOutbox;
import com.shadow.backend.chat.mapper.ChatConversationMapper;
import com.shadow.backend.chat.mapper.ChatMessageMapper;
import com.shadow.backend.chat.mapper.ChatOutboxMapper;
import com.shadow.backend.chat.response.ChatResultCode;
import com.shadow.backend.chat.vo.ChatEventVO;
import com.shadow.backend.chat.vo.ChatMessageVO;
import com.shadow.backend.common.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import tools.jackson.databind.json.JsonMapper;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

/**
 * 通话终态回写聊天记录：以会话锁追加一条 CALL 消息并广播 message.created，
 * 与文本消息共用 seq 分配与 Outbox 投递；幂等性由通话状态机的单次终态转换保证。
 * 消息文本同时作为会话列表预览，例如“[语音通话] 已取消”“[视频通话] 通话时长 05:32”。
 */
@Service
@RequiredArgsConstructor
public class CallChatRecorder {
    private final ChatConversationMapper conversationMapper;
    private final ChatMessageMapper messageMapper;
    private final ChatOutboxMapper outboxMapper;
    private final JsonMapper jsonMapper;

    public void record(CallSession call, LocalDateTime now) {
        ChatConversation conversation = conversationMapper.lockById(call.getConversationId());
        if (conversation.getLastSeq() == Long.MAX_VALUE) {
            throw new BusinessException(ChatResultCode.SEQUENCE_EXHAUSTED);
        }
        ChatMessage message = new ChatMessage();
        message.setConversationId(conversation.getId());
        // 发送者记为主叫：被叫侧未读计数自然 +1，主叫侧不计未读，与未接来电预期一致。
        message.setSenderId(call.getCallerId());
        message.setClientMsgId(UUID.randomUUID().toString());
        message.setType(ChatMessage.TYPE_CALL);
        message.setCallId(call.getCallId());
        message.setSeq(conversation.getLastSeq() + 1);
        message.setText(previewOf(call));
        message.setCreatedAt(now);
        messageMapper.insert(message);
        conversation.setLastSeq(message.getSeq());
        conversation.setLastText(message.getText());
        conversation.setUpdatedAt(now);
        conversationMapper.updateById(conversation);
        ChatMessageVO vo = new ChatMessageVO(message.getId(), message.getConversationId(),
                message.getSenderId(), message.getClientMsgId(), message.getType(), message.getCallId(),
                message.getSeq(), message.getText(), iso(now));
        ChatEventVO<ChatMessageVO> event = new ChatEventVO<>(UUID.randomUUID().toString(),
                "message.created", 1, conversation.getId(), message.getId(), message.getSeq(), iso(now), vo);
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

    private String previewOf(CallSession call) {
        String prefix = "VIDEO".equals(call.getMediaType()) ? "[视频通话] " : "[语音通话] ";
        return switch (CallStatus.fromValue(call.getStatus())) {
            case REJECTED -> prefix + "已拒绝";
            case CANCELLED -> prefix + "已取消";
            case TIMEOUT -> prefix + "未接听";
            case ENDED -> prefix + "通话时长 " + durationOf(call);
            // 非终态不应回写，防御性拒绝而不是写入误导性记录。
            default -> throw new BusinessException(CallResultCode.CALL_STATE_CONFLICT);
        };
    }

    private String durationOf(CallSession call) {
        if (call.getAcceptedAt() == null || call.getEndedAt() == null) {
            return "00:00";
        }
        long seconds = Math.max(0, Duration.between(call.getAcceptedAt(), call.getEndedAt()).toSeconds());
        long hours = seconds / 3600;
        long minutes = (seconds % 3600) / 60;
        if (hours > 0) {
            return String.format("%d:%02d:%02d", hours, minutes, seconds % 60);
        }
        return String.format("%02d:%02d", minutes, seconds % 60);
    }

    private String iso(LocalDateTime time) {
        return time.toInstant(ZoneOffset.UTC).toString();
    }
}
