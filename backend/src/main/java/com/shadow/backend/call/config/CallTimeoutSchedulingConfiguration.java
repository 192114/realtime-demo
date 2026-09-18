package com.shadow.backend.call.config;

import com.shadow.backend.call.service.impl.CallTimeoutHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

@Configuration(proxyBeanMethods = false)
@EnableScheduling
@ConditionalOnProperty(prefix = "realtime.livekit", name = "enabled", havingValue = "true")
public class CallTimeoutSchedulingConfiguration {
    @Bean
    public CallTimeoutScheduler callTimeoutScheduler(CallTimeoutHandler handler) {
        return new CallTimeoutScheduler(handler);
    }

    @RequiredArgsConstructor
    @Slf4j
    public static class CallTimeoutScheduler {
        private final CallTimeoutHandler handler;

        @Scheduled(fixedDelayString = "${realtime.livekit.timeout-sweep-millis:5000}",
                initialDelayString = "${realtime.livekit.timeout-sweep-initial-millis:8000}")
        public void tick() {
            try {
                for (String callId : handler.candidates()) {
                    if (Thread.currentThread().isInterrupted()) {
                        return;
                    }
                    handler.timeoutOne(callId);
                }
            } catch (Exception failure) {
                // 数据库异常可能携带连接参数；调度日志只输出类型，不输出堆栈及正文。
                log.warn("通话超时调度失败，下轮恢复: errorType={}", failure.getClass().getSimpleName());
            }
        }
    }
}
