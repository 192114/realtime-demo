package com.shadow.backend.realtime.service.impl;

import com.shadow.backend.common.exception.BusinessException;
import com.shadow.backend.common.response.ResultCode;
import com.shadow.backend.common.util.LoginUserUtil;
import com.shadow.backend.common.util.StpAppUtil;
import com.shadow.backend.realtime.config.RealtimeMqttProperties;
import com.shadow.backend.realtime.dto.MqttCredentialsRequest;
import com.shadow.backend.realtime.dto.StoredMqttCredential;
import com.shadow.backend.realtime.security.RealtimeSecrets;
import com.shadow.backend.realtime.security.RealtimeTopics;
import com.shadow.backend.realtime.service.MqttCredentialStore;
import com.shadow.backend.realtime.service.MqttCredentialsService;
import com.shadow.backend.realtime.service.RealtimeIdentityService;
import com.shadow.backend.realtime.vo.MqttCredentialsVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;

@Service
@RequiredArgsConstructor
public class MqttCredentialsServiceImpl implements MqttCredentialsService {
    private final RealtimeMqttProperties properties;
    private final MqttCredentialStore credentialStore;
    private final RealtimeIdentityService identityService;
    private final Clock realtimeClock;

    @Override
    public MqttCredentialsVO issue(MqttCredentialsRequest request) {
        if (!properties.isEnabled()) {
            throw new BusinessException(503, "实时消息服务未启用");
        }
        if (request == null || request.getDeviceId() == null
                || !request.getDeviceId().matches("[A-Za-z0-9_-]{16,64}")) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "设备标识格式无效");
        }
        try {
            long userId = LoginUserUtil.currentUserId();
            String loginToken = StpAppUtil.getTokenValue();
            long loginTtl = identityService.remainingLoginSeconds(userId, loginToken);
            if (!identityService.isAccountEligible(userId) || loginTtl <= 0) {
                throw new BusinessException(ResultCode.FORBIDDEN);
            }
            long ttl = Math.min(properties.getCredentialTtlSeconds(), loginTtl);
            long expiresAt = realtimeClock.instant().getEpochSecond() + ttl;
            String username = "rtu_" + RealtimeSecrets.randomOpaque();
            String password = RealtimeSecrets.randomOpaque();
            String clientId = "rtu_" + userId + "_" + request.getDeviceId();
            StoredMqttCredential credential = new StoredMqttCredential(userId, clientId,
                    RealtimeSecrets.sha256(password), RealtimeSecrets.sha256(loginToken), expiresAt);
            credentialStore.save(username, credential, Duration.ofSeconds(ttl));
            return new MqttCredentialsVO(properties.getClientWebsocketUrl(), clientId, username, password,
                    Instant.ofEpochSecond(expiresAt).toString(), RealtimeTopics.forUser(userId), 1);
        } catch (Exception ex) {
            // Controller 的公共切面会记录异常消息，因此只能向外传播固定安全消息，不保留 cause。
            throw new BusinessException(ResultCode.FORBIDDEN, "实时凭据申请失败，请确认登录和账号状态后重试");
        }
    }
}
