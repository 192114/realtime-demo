package com.shadow.backend.realtime.service.impl;

import com.shadow.backend.common.exception.BusinessException;
import com.shadow.backend.common.util.LoginUserUtil;
import com.shadow.backend.common.util.StpAppUtil;
import com.shadow.backend.realtime.config.RealtimeMqttProperties;
import com.shadow.backend.realtime.dto.MqttCredentialsRequest;
import com.shadow.backend.realtime.dto.StoredMqttCredential;
import com.shadow.backend.realtime.security.RealtimeSecrets;
import com.shadow.backend.realtime.service.MqttCredentialStore;
import com.shadow.backend.realtime.service.RealtimeIdentityService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MqttCredentialsServiceImplTest {
    @Mock private MqttCredentialStore store;
    @Mock private RealtimeIdentityService identity;
    private RealtimeMqttProperties properties;
    private MqttCredentialsServiceImpl service;
    private final MqttCredentialsRequest request = new MqttCredentialsRequest();

    @BeforeEach
    void setup() {
        properties = new RealtimeMqttProperties();
        properties.setEnabled(true);
        properties.setClientWebsocketUrl("wss://broker.example/mqtt");
        service = new MqttCredentialsServiceImpl(properties, store, identity,
                Clock.fixed(Instant.parse("2026-01-01T00:00:00Z"), ZoneOffset.UTC));
        request.setDeviceId("device_0123456789");
    }

    @Test
    void issue_usesCurrentAppUserStoresOnlyDigestsAndCapsExpiryByLogin() {
        try (MockedStatic<LoginUserUtil> user = mockStatic(LoginUserUtil.class);
             MockedStatic<StpAppUtil> token = mockStatic(StpAppUtil.class)) {
            user.when(LoginUserUtil::currentUserId).thenReturn(42L);
            token.when(StpAppUtil::getTokenValue).thenReturn("test-access-token");
            when(identity.remainingLoginSeconds(42, "test-access-token")).thenReturn(90L);
            when(identity.isAccountEligible(42)).thenReturn(true);
            var first = service.issue(request);
            var second = service.issue(request);
            request.setDeviceId("device_9876543210");
            var otherDevice = service.issue(request);
            assertThat(first.getUrl()).isEqualTo(properties.getClientWebsocketUrl());
            assertThat(first.getClientId()).isEqualTo("rtu_42_device_0123456789").isEqualTo(second.getClientId());
            assertThat(otherDevice.getClientId()).isNotEqualTo(first.getClientId());
            assertThat(first.getUsername()).isNotEqualTo(second.getUsername());
            assertThat(first.getPassword()).matches("[A-Za-z0-9_-]{43}")
                    .isNotEqualTo(second.getPassword()).isNotEqualTo("test-access-token");
            assertThat(first.getExpiresAt()).isEqualTo("2026-01-01T00:01:30Z");
            assertThat(first.getTopics()).containsExactly("chat/user/42/events", "chat/user/42/calls");
            assertThat(first.getQos()).isEqualTo(1);
            var saved = ArgumentCaptor.forClass(StoredMqttCredential.class);
            verify(store).save(eq(first.getUsername()), saved.capture(), eq(Duration.ofSeconds(90)));
            assertThat(saved.getValue().getPasswordDigest()).isEqualTo(RealtimeSecrets.sha256(first.getPassword()));
            assertThat(saved.getValue().getLoginTokenDigest()).isEqualTo(RealtimeSecrets.sha256("test-access-token"));
            assertThat(saved.getValue().getUserId()).isEqualTo(42);
            assertThat(first.toString()).doesNotContain(first.getPassword(), first.getUsername());
        }
    }

    @Test
    void issue_deniesDisabledMalformedDeviceInvalidAccountAndExpiredLogin() {
        properties.setEnabled(false);
        assertThatThrownBy(() -> service.issue(request)).isInstanceOf(BusinessException.class);
        properties.setEnabled(true);
        for (String device : new String[]{"short", "a".repeat(65), "device/0123456789", "device+0123456789", "设备012345678901234"}) {
            request.setDeviceId(device);
            assertThatThrownBy(() -> service.issue(request)).isInstanceOf(BusinessException.class);
        }
        request.setDeviceId("device_0123456789");
        try (MockedStatic<LoginUserUtil> user = mockStatic(LoginUserUtil.class);
             MockedStatic<StpAppUtil> token = mockStatic(StpAppUtil.class)) {
            user.when(LoginUserUtil::currentUserId).thenReturn(42L);
            token.when(StpAppUtil::getTokenValue).thenReturn("test-access-token");
            when(identity.remainingLoginSeconds(42, "test-access-token")).thenReturn(0L, 300L);
            when(identity.isAccountEligible(42)).thenReturn(true, false);
            assertThatThrownBy(() -> service.issue(request)).isInstanceOf(BusinessException.class);
            assertThatThrownBy(() -> service.issue(request)).isInstanceOf(BusinessException.class);
        }
        verifyNoInteractions(store);
    }

    @Test
    void issue_sanitizesDependencyExceptionsBeforeControllerLogging() {
        try (MockedStatic<LoginUserUtil> user = mockStatic(LoginUserUtil.class)) {
            user.when(LoginUserUtil::currentUserId).thenThrow(new IllegalStateException("secret-token-message"));
            assertThatThrownBy(() -> service.issue(request)).isInstanceOf(BusinessException.class)
                    .hasMessageNotContaining("secret-token-message").hasNoCause();
        }
    }
}
