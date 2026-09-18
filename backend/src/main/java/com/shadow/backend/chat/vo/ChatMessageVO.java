package com.shadow.backend.chat.vo;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ChatMessageVO {
    private Long messageId;
    private Long conversationId;
    private Long senderId;
    private String clientMsgId;
    private String type;
    private String callId;
    private Long seq;
    private String text;
    private String createdAt;
}
