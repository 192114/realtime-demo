package com.shadow.backend.realtime.vo;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Max;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.ToString;

import java.util.List;

@Data
@AllArgsConstructor
@ToString(onlyExplicitlyIncluded = true)
public class MqttCredentialsVO {
    @NotBlank
    private String url;
    @NotBlank
    private String clientId;
    @NotBlank
    private String username;
    @NotBlank
    private String password;
    @NotBlank
    private String expiresAt;
    @NotEmpty
    private List<String> topics;
    @Min(1)
    @Max(1)
    private int qos;
}
