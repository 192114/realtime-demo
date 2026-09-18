package com.shadow.backend.realtime.service.impl;

import com.shadow.backend.common.config.JacksonConfig;
import com.shadow.backend.realtime.dto.StoredMqttCredential;
import com.shadow.backend.realtime.security.RealtimeSecrets;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import tools.jackson.databind.json.JsonMapper;

import java.time.Duration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class RedisMqttCredentialStoreTest {
    @Test
    @SuppressWarnings("unchecked")
    void storesDigestOnlyWithTtlAndRoundTripsUnderGlobalLongSerialization() {
        StringRedisTemplate redis = mock(StringRedisTemplate.class);
        ValueOperations<String, String> values = mock(ValueOperations.class);
        when(redis.opsForValue()).thenReturn(values);
        var builder = JsonMapper.builder();
        new JacksonConfig().jsonMapperBuilderCustomizer().customize(builder);
        var store = new RedisMqttCredentialStore(redis, builder.build());
        var credential = new StoredMqttCredential(42, "rtu_42_device_0123456789",
                RealtimeSecrets.sha256("opaque-test-password"), RealtimeSecrets.sha256("test-access-token"), 1800000000L);
        store.save("random-test-username", credential, Duration.ofSeconds(300));
        var key = ArgumentCaptor.forClass(String.class);
        var json = ArgumentCaptor.forClass(String.class);
        verify(values).set(key.capture(), json.capture(), eq(Duration.ofSeconds(300)));
        assertThat(key.getValue()).isEqualTo("realtime:mqtt:credential:" + RealtimeSecrets.sha256("random-test-username"));
        assertThat(json.getValue()).doesNotContain("opaque-test-password", "test-access-token", "random-test-username");
        when(values.get(key.getValue())).thenReturn(json.getValue());
        assertThat(store.find("random-test-username")).contains(credential);
        assertThat(store.find("missing")).isEmpty();
    }
}
