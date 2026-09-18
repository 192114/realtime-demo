package com.shadow.backend.realtime.service.impl;

import com.shadow.backend.realtime.dto.StoredMqttCredential;
import com.shadow.backend.realtime.security.RealtimeSecrets;
import com.shadow.backend.realtime.service.MqttCredentialStore;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import tools.jackson.databind.json.JsonMapper;

import java.time.Duration;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RedisMqttCredentialStore implements MqttCredentialStore {
    private static final String PREFIX = "realtime:mqtt:credential:";
    private final StringRedisTemplate redisTemplate;
    private final JsonMapper jsonMapper;

    @Override
    public void save(String username, StoredMqttCredential credential, Duration ttl) {
        redisTemplate.opsForValue().set(PREFIX + RealtimeSecrets.sha256(username),
                jsonMapper.writeValueAsString(credential), ttl);
    }

    @Override
    public Optional<StoredMqttCredential> find(String username) {
        String json = redisTemplate.opsForValue().get(PREFIX + RealtimeSecrets.sha256(username));
        return json == null ? Optional.empty() : Optional.of(jsonMapper.readValue(json, StoredMqttCredential.class));
    }
}
