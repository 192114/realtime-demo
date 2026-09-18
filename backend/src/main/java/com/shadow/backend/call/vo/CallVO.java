package com.shadow.backend.call.vo;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.ALWAYS)
public class CallVO {
    private String callId;
    private Long conversationId;
    private Long callerId;
    private String callerNickname;
    private Long calleeId;
    private String calleeNickname;
    private Integer status;
    private String mediaType;
    private String endReason;
    private Long durationSeconds;
    private String createdAt;
    private String acceptedAt;
    private String endedAt;
    // 以下三个字段仅出现在对通话参与者的 HTTPS 响应中，绝不写入 MQTT 事件负载。
    private String roomName;
    private String liveKitUrl;
    private String token;
}
