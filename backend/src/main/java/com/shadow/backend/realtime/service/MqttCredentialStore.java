package com.shadow.backend.realtime.service;

import com.shadow.backend.realtime.dto.StoredMqttCredential;

import java.time.Duration;
import java.util.Optional;

public interface MqttCredentialStore {
    void save(String username, StoredMqttCredential credential, Duration ttl);

    Optional<StoredMqttCredential> find(String username);
}
