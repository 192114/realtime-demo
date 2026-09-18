package com.shadow.backend.call.vo;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.ALWAYS)
public class CallEventVO<T> {
    private String eventId;
    private String eventType;
    private Integer version;
    private String callId;
    private String occurredAt;
    private T payload;
}
