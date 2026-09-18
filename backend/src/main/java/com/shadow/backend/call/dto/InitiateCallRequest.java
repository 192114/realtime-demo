package com.shadow.backend.call.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class InitiateCallRequest {
    public static final String MEDIA_TYPE_PATTERN = "AUDIO|VIDEO";

    @NotNull(message = "被叫用户ID不能为空")
    @Positive(message = "被叫用户ID必须为正数")
    private Long calleeId;

    @NotBlank(message = "媒体类型不能为空")
    @Pattern(regexp = MEDIA_TYPE_PATTERN, message = "媒体类型必须为 AUDIO 或 VIDEO")
    private String mediaType;
}
