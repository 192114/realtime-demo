package com.shadow.backend.chat.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class CreateDirectConversationRequest {
    @NotNull(message = "对端用户不能为空")
    @Positive(message = "对端用户ID必须为正数")
    private Long peerUserId;
}
