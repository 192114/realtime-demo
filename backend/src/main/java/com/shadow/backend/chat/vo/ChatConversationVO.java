package com.shadow.backend.chat.vo;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.ALWAYS)
public class ChatConversationVO {
    private Long conversationId;
    private Long peerUserId;
    private String peerNickname;
    private Long lastSeq;
    private Long readSeq;
    private Long peerReadSeq;
    private Long unreadCount;
    private String lastMessage;
    private String updatedAt;
}
