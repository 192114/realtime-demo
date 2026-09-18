package com.shadow.backend.chat.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Data;

@Data
public class ReadConversationRequest {
    @NotNull(message = "已读序号不能为空")
    @PositiveOrZero(message = "已读序号不能为负数")
    private Long seq;
}
