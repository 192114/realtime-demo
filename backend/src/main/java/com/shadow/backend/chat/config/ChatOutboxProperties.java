package com.shadow.backend.chat.config;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.validation.annotation.Validated;

@Data
@Component
@Validated
@ConfigurationProperties(prefix = "chat.outbox")
public class ChatOutboxProperties {
    @Min(1)
    @Max(500)
    private int batchSize = 50;
    // 应大于发布实现的超时时间；即使超过租约，旧任务也无法确认或改写新租约。
    @Min(1)
    @Max(3600)
    private int leaseSeconds = 60;
}
