package com.shadow.backend.chat.vo;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.ALWAYS)
public class ChatEventVO<T> {
    private String eventId;
    private String eventType;
    private Integer version;
    private Long conversationId;
    private Long messageId;
    private Long seq;
    private String occurredAt;
    private T payload;

    @Data
    @AllArgsConstructor
    public static class ReadPayload {
        private Long userId;
        private Long readSeq;
    }
}
