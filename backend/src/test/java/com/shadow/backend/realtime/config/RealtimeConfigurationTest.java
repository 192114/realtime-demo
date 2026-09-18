package com.shadow.backend.realtime.config;

import com.shadow.backend.chat.service.ChatEventPublisher;
import com.shadow.backend.realtime.service.impl.PahoChatEventPublisher;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.mock.env.MockEnvironment;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class RealtimeConfigurationTest {
    @Test
    void disabledByDefaultNeedsNoSecretsAndRegistersNoPublisher() {
        new ApplicationContextRunner().withUserConfiguration(RealtimeConfiguration.class,
                        PahoMqttClientFactory.class, PahoChatEventPublisher.class)
                .run(context -> {
                    assertThat(context).hasNotFailed().doesNotHaveBean(ChatEventPublisher.class);
                    var properties = context.getBean(RealtimeMqttProperties.class);
                    assertThat(properties.isEnabled()).isFalse();
                    assertThat(properties.getServerUri()).isEmpty();
                    assertThat(properties.getClientWebsocketUrl()).isEmpty();
                    assertThat(properties.getServicePassword()).isEmpty();
                    assertThat(properties.getInternalCallbackSecret()).isEmpty();
                });
    }

    @Test
    void enablingWithoutExplicitVersionEndpointsOrSecretsFailsStartup() {
        new ApplicationContextRunner().withUserConfiguration(RealtimeConfiguration.class)
                .withPropertyValues("realtime.mqtt.enabled=true")
                .run(context -> assertThat(context).hasFailed());
        var properties = validProperties();
        properties.setServicePassword("");
        assertThatThrownBy(() -> new RealtimeConfiguration(properties, env("dev"))).isInstanceOf(IllegalStateException.class);
        var missingCallback = validProperties();
        missingCallback.setInternalCallbackSecret("");
        assertThatThrownBy(() -> new RealtimeConfiguration(missingCallback, env("dev"))).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void onlyExplicitDevAllowsPlaintextAndTlsUsesIndependentUris() {
        var properties = validProperties();
        assertThatCode(() -> new RealtimeConfiguration(properties, env("dev"))).doesNotThrowAnyException();
        assertThatThrownBy(() -> new RealtimeConfiguration(properties, env("prod"))).isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> new RealtimeConfiguration(properties, env("dev", "prod"))).isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> new RealtimeConfiguration(properties, env())).isInstanceOf(IllegalStateException.class);
        properties.setServerUri("ssl://private-broker.example:8883");
        properties.setClientWebsocketUrl("wss://public-broker.example/mqtt");
        assertThatCode(() -> new RealtimeConfiguration(properties, env("prod"))).doesNotThrowAnyException();
        properties.setClientWebsocketUrl("ws://public-broker.example/mqtt");
        assertThatThrownBy(() -> new RealtimeConfiguration(properties, env("prod"))).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void requiresSupportedExactVersionAndFiniteTimeouts() {
        var properties = validProperties();
        for (String version : new String[]{"", "5", "6", "latest", "4.4.0", "5.7.9", "7.0.0"}) {
            properties.setEmqxVersion(version);
            assertThatThrownBy(() -> new RealtimeConfiguration(properties, env("dev"))).isInstanceOf(IllegalStateException.class);
        }
        for (String version : new String[]{"5.8.0", "5.10.1", "6.0.0", "6.2.1"}) {
            properties.setEmqxVersion(version);
            assertThatCode(() -> new RealtimeConfiguration(properties, env("dev"))).doesNotThrowAnyException();
        }
        properties.setConnectTimeoutSeconds(0);
        assertThatThrownBy(() -> new RealtimeConfiguration(properties, env("dev"))).isInstanceOf(IllegalStateException.class);
        properties.setConnectTimeoutSeconds(5);
        properties.setPublishTimeoutSeconds(0);
        assertThatThrownBy(() -> new RealtimeConfiguration(properties, env("dev"))).isInstanceOf(IllegalStateException.class);
        properties.setPublishTimeoutSeconds(5);
        properties.setCredentialTtlSeconds(3600);
        assertThatThrownBy(() -> new RealtimeConfiguration(properties, env("dev"))).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void rejectsSecretsInUrisAndSharedCredentialsWithoutLeakingTheirValues() {
        var properties = validProperties();
        properties.setServerUri("tcp://user:private-value@localhost:1883");
        assertThatThrownBy(() -> new RealtimeConfiguration(properties, env("dev")))
                .isInstanceOf(IllegalStateException.class).hasMessageNotContaining("private-value");
        properties.setServerUri("tcp://localhost:1883");
        properties.setInternalCallbackSecret(properties.getServicePassword());
        assertThatThrownBy(() -> new RealtimeConfiguration(properties, env("dev")))
                .isInstanceOf(IllegalStateException.class).hasMessageNotContaining(properties.getServicePassword());
    }

    private RealtimeMqttProperties validProperties() {
        var properties = new RealtimeMqttProperties();
        properties.setEnabled(true);
        properties.setEmqxVersion("5.8.0");
        properties.setServerUri("tcp://localhost:1883");
        properties.setClientWebsocketUrl("ws://localhost:8083/mqtt");
        properties.setServiceUsername("test-service");
        properties.setServiceClientId("rts_test-service");
        properties.setServicePassword("unit-test-service-password-not-deployed");
        properties.setInternalCallbackSecret("unit-test-callback-secret-not-deployed");
        return properties;
    }

    private MockEnvironment env(String... profiles) {
        var environment = new MockEnvironment();
        environment.setActiveProfiles(profiles);
        return environment;
    }
}
