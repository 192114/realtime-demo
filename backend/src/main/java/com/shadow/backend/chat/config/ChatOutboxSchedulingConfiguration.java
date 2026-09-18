package com.shadow.backend.chat.config;

import com.shadow.backend.chat.service.ChatOutboxDispatcher;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

@Configuration(proxyBeanMethods = false)
@EnableScheduling
@ConditionalOnProperty(prefix = "realtime.mqtt", name = "enabled", havingValue = "true")
public class ChatOutboxSchedulingConfiguration {
    @Bean
    @ConditionalOnProperty(prefix = "chat.outbox", name = "enabled", havingValue = "true", matchIfMissing = true)
    public ChatOutboxScheduler chatOutboxScheduler(ChatOutboxDispatcher dispatcher) {
        return new ChatOutboxScheduler(dispatcher);
    }

    @RequiredArgsConstructor
    @Slf4j
    public static class ChatOutboxScheduler {
        private final ChatOutboxDispatcher dispatcher;

        @Scheduled(fixedDelayString = "${chat.outbox.poll-delay-ms:1000}",
                initialDelayString = "${chat.outbox.initial-delay-ms:5000}")
        public void tick() {
            try {
                dispatcher.dispatch();
            } catch (Exception failure) {
                // 数据库或发布器异常可能携带完整参数；调度日志只输出类型，不输出堆栈及正文。
                log.warn("聊天 Outbox 调度失败，下轮恢复: errorType={}", failure.getClass().getSimpleName());
            }
        }
    }
}
