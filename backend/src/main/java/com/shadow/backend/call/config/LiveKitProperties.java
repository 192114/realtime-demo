package com.shadow.backend.call.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = "realtime.livekit")
public class LiveKitProperties {
    private boolean enabled;
    private String url = "";
    private String apiKey = "";
    private String apiSecret = "";
    private int tokenTtlSeconds = 600;
    private int callTimeoutSeconds = 60;
    private int timeoutSweepMillis = 5000;
    private int timeoutSweepInitialMillis = 8000;
    private int timeoutBatchSize = 100;
}
