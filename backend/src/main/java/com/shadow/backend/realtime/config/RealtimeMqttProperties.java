package com.shadow.backend.realtime.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = "realtime.mqtt")
public class RealtimeMqttProperties {
    private boolean enabled;
    private String serverUri = "";
    private String clientWebsocketUrl = "";
    private String emqxVersion = "";
    private String serviceClientId = "";
    private String serviceUsername = "";
    private String servicePassword = "";
    private String internalCallbackSecret = "";
    private int credentialTtlSeconds = 300;
    private int serviceSessionTtlSeconds = 3600;
    private int connectTimeoutSeconds = 5;
    private int publishTimeoutSeconds = 5;
    private int keepAliveSeconds = 30;
    private int maxReconnectDelayMillis = 30000;
}
