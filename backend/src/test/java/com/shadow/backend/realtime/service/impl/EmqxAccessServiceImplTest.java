package com.shadow.backend.realtime.service.impl;

import com.shadow.backend.realtime.config.RealtimeMqttProperties;
import com.shadow.backend.realtime.dto.EmqxAuthenticationRequest;
import com.shadow.backend.realtime.dto.EmqxAuthorizationRequest;
import com.shadow.backend.realtime.dto.StoredMqttCredential;
import com.shadow.backend.realtime.security.RealtimeSecrets;
import com.shadow.backend.realtime.service.MqttCredentialStore;
import com.shadow.backend.realtime.service.RealtimeIdentityService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import tools.jackson.databind.json.JsonMapper;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class EmqxAccessServiceImplTest {
    private static final String SECRET = "unit-test-callback-secret-not-deployed";
    private static final String USERNAME = "rtu_" + "a".repeat(43);
    private static final String CLIENT = "rtu_42_device_0123456789";
    private static final long NOW = 1767225600L;
    private final MqttCredentialStore store = mock(MqttCredentialStore.class);
    private final RealtimeIdentityService identity = mock(RealtimeIdentityService.class);
    private final JsonMapper mapper = JsonMapper.builder().build();
    private RealtimeMqttProperties properties;
    private EmqxAccessServiceImpl service;
    private StoredMqttCredential credential;

    @BeforeEach
    void setup() {
        properties = new RealtimeMqttProperties();
        properties.setEnabled(true);
        properties.setInternalCallbackSecret(SECRET);
        properties.setServiceUsername("test-service");
        properties.setServiceClientId("rts_test-service");
        properties.setServicePassword("unit-test-service-password-not-deployed");
        service = new EmqxAccessServiceImpl(properties, store, identity,
                Clock.fixed(Instant.ofEpochSecond(NOW), ZoneOffset.UTC));
        credential = new StoredMqttCredential(42, CLIENT, RealtimeSecrets.sha256("opaque-password"),
                RealtimeSecrets.sha256("login-token"), NOW + 300);
        when(store.find(USERNAME)).thenReturn(Optional.of(credential));
        when(identity.isAccountEligible(42)).thenReturn(true);
        when(identity.isLoginValid(42, credential.getLoginTokenDigest())).thenReturn(true);
    }

    @Test
    void missingWrongOrUnconfiguredSecretAndDisabledModuleFailClosed() {
        for (String secret : new String[]{null, "", "wrong"}) {
            assertThat(service.authenticate(secret, authn())).isEmpty();
            assertThat(service.authorize(secret, authz())).isFalse();
        }
        properties.setInternalCallbackSecret("");
        assertThat(service.authenticate("", authn())).isEmpty();
        assertThat(service.authorize("", authz())).isFalse();
        properties.setInternalCallbackSecret(SECRET);
        properties.setEnabled(false);
        assertThat(service.authenticate(SECRET, authn())).isEmpty();
        assertThat(service.authorize(SECRET, authz())).isFalse();
        verify(store, never()).find(anyString());
    }

    @Test
    void authenticationRequiresPasswordClientBindingAccountLoginAndUnexpiredCredential() {
        assertThat(service.authenticate(SECRET, authn())).hasValue(NOW + 300);
        var request = authn();
        request.setPassword("login-token");
        assertThat(service.authenticate(SECRET, request)).isEmpty();
        request = authn();
        request.setClientid("rtu_42_other-device-1234");
        assertThat(service.authenticate(SECRET, request)).isEmpty();
        credential.setExpiresAt(NOW);
        assertThat(service.authenticate(SECRET, authn())).isEmpty();
        credential.setExpiresAt(NOW + 300);
        when(identity.isAccountEligible(42)).thenReturn(false);
        assertThat(service.authenticate(SECRET, authn())).isEmpty();
        when(identity.isAccountEligible(42)).thenReturn(true);
        when(identity.isLoginValid(42, credential.getLoginTokenDigest())).thenReturn(false);
        assertThat(service.authenticate(SECRET, authn())).isEmpty();
        when(store.find(USERNAME)).thenReturn(Optional.empty());
        assertThat(service.authenticate(SECRET, authn())).isEmpty();
    }

    @Test
    void usersOnlySubscribeTheirExactTopicsNeverPublishEvenToSelf() {
        var request = authz();
        assertThat(service.authorize(SECRET, request)).isTrue();
        request.setTopic("chat/user/42/calls");
        assertThat(service.authorize(SECRET, request)).isTrue();
        for (String topic : new String[]{"chat/user/43/events", "chat/user/42/+", "chat/user/42/#",
                "$share/group/chat/user/42/events", "$queue/chat/user/42/events", "chat/user/042/events",
                "chat/user/42/events/extra", "chat/user/42/events\n", "chat/user/9223372036854775808/events"}) {
            request.setTopic(topic);
            assertThat(service.authorize(SECRET, request)).as(topic).isFalse();
        }
        request.setTopic("chat/user/42/events");
        for (String action : new String[]{"publish", "all", "SUBSCRIBE", null}) {
            request.setAction(action);
            assertThat(service.authorize(SECRET, request)).isFalse();
        }
    }

    @Test
    void authorizationIndependentlyRejectsForgedBindingsAndRechecksLogoutAccountAndExpiry() {
        var request = authz();
        request.setUsername("42");
        assertThat(service.authorize(SECRET, request)).isFalse();
        request.setUsername("rtu_" + "z".repeat(43));
        assertThat(service.authorize(SECRET, request)).isFalse();
        request.setUsername(USERNAME);
        request.setClientid("rtu_43_device_0123456789");
        assertThat(service.authorize(SECRET, request)).isFalse();
        request.setClientid(CLIENT);
        when(identity.isLoginValid(42, credential.getLoginTokenDigest())).thenReturn(false);
        assertThat(service.authorize(SECRET, request)).isFalse();
        when(identity.isLoginValid(42, credential.getLoginTokenDigest())).thenReturn(true);
        when(identity.isAccountEligible(42)).thenReturn(false);
        assertThat(service.authorize(SECRET, request)).isFalse();
        when(identity.isAccountEligible(42)).thenReturn(true);
        credential.setExpiresAt(NOW - 1);
        assertThat(service.authorize(SECRET, request)).isFalse();
        credential.setExpiresAt(NOW + 300);
        credential.setPasswordDigest("invalid");
        assertThat(service.authorize(SECRET, request)).isFalse();
    }

    @Test
    void strictQosAndRetainTypesSupportOfficialStringPlaceholders() {
        var request = authz();
        for (String json : new String[]{"0", "2", "1.0", "true", "null", "{}", "\"01\""}) {
            request.setQos(mapper.readTree(json));
            assertThat(service.authorize(SECRET, request)).isFalse();
        }
        request.setQos(mapper.readTree("\"1\""));
        request.setRetain(mapper.readTree("\"false\""));
        assertThat(service.authorize(SECRET, request)).isTrue();
        for (String json : new String[]{"true", "\"true\"", "1", "{}", "[]", "\"FALSE\""}) {
            request.setRetain(mapper.readTree(json));
            assertThat(service.authorize(SECRET, request)).isFalse();
        }
        request.setRetain(null);
        assertThat(service.authorize(SECRET, request)).isTrue();
    }

    @Test
    void serviceNeedsAuthenticationBindingAndCanOnlyPublishNonRetainedPersonalTopics() {
        var request = authz();
        request.setUsername(properties.getServiceUsername());
        request.setClientid(properties.getServiceClientId());
        request.setAction("publish");
        assertThat(service.authorize(SECRET, request)).isFalse();
        var authentication = authn();
        authentication.setUsername(properties.getServiceUsername());
        authentication.setClientid(properties.getServiceClientId());
        authentication.setPassword("wrong");
        assertThat(service.authenticate(SECRET, authentication)).isEmpty();
        authentication.setPassword(properties.getServicePassword());
        assertThat(service.authenticate(SECRET, authentication)).hasValue(NOW + 3600);
        var binding = ArgumentCaptor.forClass(StoredMqttCredential.class);
        verify(store).save(eq(properties.getServiceUsername()), binding.capture(), eq(Duration.ofSeconds(3600)));
        when(store.find(properties.getServiceUsername())).thenReturn(Optional.of(binding.getValue()));
        assertThat(service.authorize(SECRET, request)).isTrue();
        request.setTopic("chat/user/999/calls");
        assertThat(service.authorize(SECRET, request)).isTrue();
        for (String topic : new String[]{"chat/user/0/events", "chat/user/+/events", "$share/g/chat/user/42/events", "system/events"}) {
            request.setTopic(topic);
            assertThat(service.authorize(SECRET, request)).isFalse();
        }
        request.setTopic("chat/user/42/events");
        request.setRetain(mapper.readTree("true"));
        assertThat(service.authorize(SECRET, request)).isFalse();
        request.setRetain(null);
        assertThat(service.authorize(SECRET, request)).isFalse();
        request.setRetain(mapper.readTree("false"));
        request.setAction("subscribe");
        assertThat(service.authorize(SECRET, request)).isFalse();
        request.setAction("publish");
        request.setClientid("rts_forged");
        assertThat(service.authorize(SECRET, request)).isFalse();
        request.setClientid(properties.getServiceClientId());
        properties.setServicePassword("rotated-test-password");
        assertThat(service.authorize(SECRET, request)).isFalse();
    }

    @Test
    void dependencyExceptionsAndNullRequestsAlwaysDeny() {
        when(store.find(USERNAME)).thenThrow(new IllegalStateException("sensitive-token-body"));
        assertThat(service.authenticate(SECRET, authn())).isEmpty();
        assertThat(service.authorize(SECRET, authz())).isFalse();
        assertThat(service.authenticate(SECRET, null)).isEmpty();
        assertThat(service.authorize(SECRET, null)).isFalse();
    }

    private EmqxAuthenticationRequest authn() {
        var request = new EmqxAuthenticationRequest();
        request.setUsername(USERNAME);
        request.setClientid(CLIENT);
        request.setPassword("opaque-password");
        return request;
    }

    private EmqxAuthorizationRequest authz() {
        var request = new EmqxAuthorizationRequest();
        request.setUsername(USERNAME);
        request.setClientid(CLIENT);
        request.setAction("subscribe");
        request.setTopic("chat/user/42/events");
        request.setQos(mapper.readTree("1"));
        request.setRetain(mapper.readTree("false"));
        return request;
    }
}
