package com.shadow.backend.realtime.service.impl;

import com.shadow.backend.realtime.config.RealtimeMqttProperties;
import com.shadow.backend.realtime.dto.EmqxAuthenticationRequest;
import com.shadow.backend.realtime.dto.EmqxAuthorizationRequest;
import com.shadow.backend.realtime.dto.StoredMqttCredential;
import com.shadow.backend.realtime.security.RealtimeSecrets;
import com.shadow.backend.realtime.security.RealtimeTopics;
import com.shadow.backend.realtime.service.EmqxAccessService;
import com.shadow.backend.realtime.service.MqttCredentialStore;
import com.shadow.backend.realtime.service.RealtimeIdentityService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import tools.jackson.databind.JsonNode;

import java.time.Clock;
import java.time.Duration;
import java.util.Optional;
import java.util.OptionalLong;

@Service
@RequiredArgsConstructor
public class EmqxAccessServiceImpl implements EmqxAccessService {
    private final RealtimeMqttProperties properties;
    private final MqttCredentialStore credentialStore;
    private final RealtimeIdentityService identityService;
    private final Clock realtimeClock;

    @Override
    public OptionalLong authenticate(String callbackSecret, EmqxAuthenticationRequest request) {
        try {
            if (!trusted(callbackSecret) || request == null) {
                return OptionalLong.empty();
            }
            if (isServiceIdentity(request.getUsername(), request.getClientid())) {
                if (!RealtimeSecrets.sameSecret(properties.getServicePassword(), request.getPassword())) {
                    return OptionalLong.empty();
                }
                long expiresAt = realtimeClock.instant().getEpochSecond() + properties.getServiceSessionTtlSeconds();
                // 授权必须存在成功认证写入的服务绑定，不能仅凭静态用户名放行。
                credentialStore.save(request.getUsername(), new StoredMqttCredential(0, request.getClientid(),
                        RealtimeSecrets.sha256(properties.getServicePassword()), "", expiresAt),
                        Duration.ofSeconds(properties.getServiceSessionTtlSeconds()));
                return OptionalLong.of(expiresAt);
            }
            Optional<StoredMqttCredential> found = userCredential(request.getUsername(), request.getClientid());
            if (found.isEmpty() || !RealtimeSecrets.matches(found.get().getPasswordDigest(), request.getPassword())) {
                return OptionalLong.empty();
            }
            return OptionalLong.of(found.get().getExpiresAt());
        } catch (Exception ex) {
            // 外部协议必须 HTTP 200 deny；不传播或记录包含凭据的下游异常。
            return OptionalLong.empty();
        }
    }

    @Override
    public boolean authorize(String callbackSecret, EmqxAuthorizationRequest request) {
        try {
            if (!trusted(callbackSecret) || request == null || !isQosOne(request.getQos())
                    || !isNonRetained(request) || !RealtimeTopics.isPersonalTopic(request.getTopic())) {
                return false;
            }
            if (isServiceIdentity(request.getUsername(), request.getClientid())) {
                if (!"publish".equals(request.getAction())) {
                    return false;
                }
                return credentialStore.find(request.getUsername())
                        .filter(credential -> credential.getUserId() == 0 && validBinding(credential, request.getClientid()))
                        .filter(credential -> RealtimeSecrets.matches(credential.getPasswordDigest(), properties.getServicePassword()))
                        .isPresent();
            }
            if (!"subscribe".equals(request.getAction())) {
                return false;
            }
            return userCredential(request.getUsername(), request.getClientid())
                    .filter(credential -> RealtimeTopics.forUser(credential.getUserId()).contains(request.getTopic()))
                    .isPresent();
        } catch (Exception ex) {
            return false;
        }
    }

    private boolean trusted(String secret) {
        return properties.isEnabled() && RealtimeSecrets.sameSecret(properties.getInternalCallbackSecret(), secret);
    }

    private boolean isServiceIdentity(String username, String clientId) {
        return !properties.getServiceUsername().isBlank() && !properties.getServiceClientId().isBlank()
                && !properties.getServicePassword().isBlank()
                && properties.getServiceUsername().equals(username) && properties.getServiceClientId().equals(clientId);
    }

    private Optional<StoredMqttCredential> userCredential(String username, String clientId) {
        if (username == null || !username.matches("rtu_[A-Za-z0-9_-]{43}") || clientId == null) {
            return Optional.empty();
        }
        return credentialStore.find(username)
                .filter(credential -> credential.getUserId() > 0 && validBinding(credential, clientId))
                .filter(credential -> clientId.matches("rtu_" + credential.getUserId() + "_[A-Za-z0-9_-]{16,64}"))
                .filter(credential -> credential.getPasswordDigest() != null && credential.getPasswordDigest().matches("[a-f0-9]{64}"))
                .filter(credential -> identityService.isAccountEligible(credential.getUserId()))
                .filter(credential -> identityService.isLoginValid(credential.getUserId(), credential.getLoginTokenDigest()));
    }

    private boolean validBinding(StoredMqttCredential credential, String clientId) {
        return clientId.equals(credential.getClientId()) && credential.getExpiresAt() > realtimeClock.instant().getEpochSecond();
    }

    private boolean isQosOne(JsonNode qos) {
        return qos != null && (qos.isIntegralNumber() || qos.isString()) && "1".equals(qos.asString());
    }

    private boolean isNonRetained(EmqxAuthorizationRequest request) {
        JsonNode retain = request.getRetain();
        // MQTT v3 SUBSCRIBE 没有 retain 标志，EMQX 可省略此占位符；PUBLISH 必须明确 false。
        if (retain == null || retain.isNull() || retain.isString() && retain.asString().isEmpty()) {
            return "subscribe".equals(request.getAction());
        }
        return (retain.isBoolean() || retain.isString()) && "false".equals(retain.asString());
    }
}
