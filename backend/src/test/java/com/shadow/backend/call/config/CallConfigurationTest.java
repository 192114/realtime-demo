package com.shadow.backend.call.config;

import org.junit.jupiter.api.Test;
import org.springframework.mock.env.MockEnvironment;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class CallConfigurationTest {
    @Test
    void disabledByDefaultNeedsNoConfig() {
        assertThatCode(() -> new CallConfiguration(new LiveKitProperties(), env("dev")))
                .doesNotThrowAnyException();
    }

    @Test
    void enablingWithoutKeySecretOrUrlFailsStartup() {
        assertThatThrownBy(() -> new CallConfiguration(properties("ws://localhost:7880", "", ""),
                env("dev"))).isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> new CallConfiguration(properties("", "devkey", "devsecret-value"),
                env("dev"))).isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> new CallConfiguration(properties("ws://localhost:7880", "devkey", ""),
                env("dev"))).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void onlyExplicitDevAllowsPlaintextAndKeySecretMustDiffer() {
        var properties = properties("ws://localhost:7880", "devkey", "devsecret-value");
        assertThatCode(() -> new CallConfiguration(properties, env("dev"))).doesNotThrowAnyException();
        assertThatThrownBy(() -> new CallConfiguration(properties, env("prod")))
                .isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> new CallConfiguration(properties, env("dev", "prod")))
                .isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> new CallConfiguration(properties, env()))
                .isInstanceOf(IllegalStateException.class);
        assertThatCode(() -> new CallConfiguration(
                properties("wss://livekit.example:7880", "devkey", "devsecret-value"), env("prod")))
                .doesNotThrowAnyException();
        var shared = properties("ws://localhost:7880", "same-value", "same-value");
        assertThatThrownBy(() -> new CallConfiguration(shared, env("dev")))
                .isInstanceOf(IllegalStateException.class);
    }

    @Test
    void rejectsOutOfRangeTtlTimeoutBatchAndSecretsInUrl() {
        for (Runnable check : new Runnable[]{
                () -> invalid(p -> p.setTokenTtlSeconds(59)),
                () -> invalid(p -> p.setTokenTtlSeconds(3601)),
                () -> invalid(p -> p.setCallTimeoutSeconds(9)),
                () -> invalid(p -> p.setCallTimeoutSeconds(301)),
                () -> invalid(p -> p.setTimeoutBatchSize(0)),
                () -> invalid(p -> p.setUrl("ws://user:private-value@localhost:7880")),
        }) {
            check.run();
        }
    }

    private void invalid(java.util.function.Consumer<LiveKitProperties> mutator) {
        var properties = properties("ws://localhost:7880", "devkey", "devsecret-value");
        mutator.accept(properties);
        assertThatThrownBy(() -> new CallConfiguration(properties, env("dev")))
                .isInstanceOf(IllegalStateException.class);
    }

    private LiveKitProperties properties(String url, String apiKey, String apiSecret) {
        var properties = new LiveKitProperties();
        properties.setEnabled(true);
        properties.setUrl(url);
        properties.setApiKey(apiKey);
        properties.setApiSecret(apiSecret);
        return properties;
    }

    private MockEnvironment env(String... profiles) {
        var environment = new MockEnvironment();
        environment.setActiveProfiles(profiles);
        return environment;
    }
}
