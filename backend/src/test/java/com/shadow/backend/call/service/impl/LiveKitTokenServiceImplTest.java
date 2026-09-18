package com.shadow.backend.call.service.impl;

import com.auth0.jwt.JWT;
import com.shadow.backend.call.config.LiveKitProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class LiveKitTokenServiceImplTest {
    private static final String API_KEY = "unit-test-key";
    private static final String API_SECRET = "unit-test-secret-not-deployed";

    private LiveKitProperties properties;
    private LiveKitTokenServiceImpl service;

    @BeforeEach
    void setUp() {
        properties = new LiveKitProperties();
        properties.setEnabled(true);
        properties.setApiKey(API_KEY);
        properties.setApiSecret(API_SECRET);
        properties.setTokenTtlSeconds(600);
        service = new LiveKitTokenServiceImpl(properties);
    }

    @Test
    void roomNameBindsCallId() {
        assertThat(service.roomName("abc-123")).isEqualTo("call_abc-123");
    }

    @Test
    @SuppressWarnings("unchecked")
    void tokenCarriesIdentityRoomJoinOnlyAndShortTtl() {
        String jwt = service.issue("abc-123", 42L, "昵称");
        var decoded = JWT.decode(jwt);
        assertThat(decoded.getIssuer()).isEqualTo(API_KEY);
        assertThat(decoded.getSubject()).isEqualTo("42");
        assertThat(decoded.getClaim("name").asString()).isEqualTo("昵称");
        // SDK 签发的 JWT 只携带 exp，不携带 iat；以 exp 与当前时间差验证短有效期。
        long ttlSeconds = (decoded.getExpiresAt().getTime() - System.currentTimeMillis()) / 1000;
        assertThat(ttlSeconds).isBetween(590L, 600L);
        Map<String, Object> video = decoded.getClaim("video").asMap();
        assertThat(video)
                .containsEntry("roomJoin", true)
                .containsEntry("room", "call_abc-123")
                .containsEntry("canPublish", true)
                .containsEntry("canSubscribe", true)
                .doesNotContainKey("roomCreate")
                .doesNotContainKey("roomAdmin")
                .doesNotContainKey("roomList")
                .doesNotContainKey("ingressAdmin");
    }

    @Test
    void tokenOmitsNameClaimWhenNicknameMissing() {
        var decoded = JWT.decode(service.issue("abc-123", 42L, null));
        // java-jwt 4.x 中缺失 claim 用 isMissing 判断；isNull 表示存在但值为 null。
        assertThat(decoded.getClaim("name").isMissing()).isTrue();
        assertThat(decoded.getSubject()).isEqualTo("42");
    }
}
