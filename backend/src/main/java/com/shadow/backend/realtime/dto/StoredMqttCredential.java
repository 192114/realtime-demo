package com.shadow.backend.realtime.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(onlyExplicitlyIncluded = true)
public class StoredMqttCredential {
    private long userId;
    private String clientId;
    private String passwordDigest;
    private String loginTokenDigest;
    private long expiresAt;
}
