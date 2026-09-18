package com.shadow.backend.chat.config;

import com.shadow.backend.chat.config.ChatOutboxSchedulingConfiguration.ChatOutboxScheduler;
import com.shadow.backend.chat.service.ChatOutboxDispatcher;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ChatOutboxSchedulingConfigurationTest {
    @Mock private ChatOutboxDispatcher dispatcher;

    @Test
    void defaultDoesNotStartScheduler() {
        runner().run(context -> assertThat(context).doesNotHaveBean(ChatOutboxScheduler.class));
        verifyNoInteractions(dispatcher);
    }

    @Test
    void disabledMqttDoesNotStartScheduler() {
        runner().withPropertyValues("realtime.mqtt.enabled=false")
                .run(context -> assertThat(context).doesNotHaveBean(ChatOutboxScheduler.class));
        verifyNoInteractions(dispatcher);
    }

    @Test
    void enabledMqttStartsScheduler() {
        runner().withPropertyValues("realtime.mqtt.enabled=true", "chat.outbox.initial-delay-ms=3600000")
                .run(context -> assertThat(context).hasSingleBean(ChatOutboxScheduler.class));
    }

    @Test
    void outboxCanBeDisabledIndependently() {
        runner().withPropertyValues("realtime.mqtt.enabled=true", "chat.outbox.enabled=false")
                .run(context -> assertThat(context).doesNotHaveBean(ChatOutboxScheduler.class));
        verifyNoInteractions(dispatcher);
    }

    @Test
    void schedulerRecoversAfterDatabaseFailure() {
        doThrow(new IllegalStateException("不得记录的正文")).doNothing().when(dispatcher).dispatch();
        ChatOutboxScheduler scheduler = new ChatOutboxScheduler(dispatcher);
        scheduler.tick();
        scheduler.tick();
        verify(dispatcher, times(2)).dispatch();
    }

    private ApplicationContextRunner runner() {
        // 仅装配调度配置，不启动应用、数据库、Redis 或 Broker。
        return new ApplicationContextRunner()
                .withUserConfiguration(ChatOutboxSchedulingConfiguration.class)
                .withBean(ChatOutboxDispatcher.class, () -> dispatcher);
    }
}
