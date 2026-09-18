package com.shadow.backend.realtime.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;
import lombok.ToString;

@Data
@ToString(onlyExplicitlyIncluded = true)
public class MqttCredentialsRequest {
    @NotBlank(message = "设备标识不能为空")
    @Pattern(regexp = "[A-Za-z0-9_-]{16,64}", message = "设备标识必须为 16 至 64 位字母、数字、下划线或连字符")
    private String deviceId;
}
