package com.shadow.backend.realtime.security;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.HexFormat;

public final class RealtimeSecrets {
    private static final SecureRandom RANDOM = new SecureRandom();

    private RealtimeSecrets() {
    }

    public static String randomOpaque() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    public static String sha256(String value) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                    .digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 不可用");
        }
    }

    public static boolean matches(String expectedDigest, String value) {
        return expectedDigest != null && value != null && value.length() <= 4096
                && MessageDigest.isEqual(expectedDigest.getBytes(StandardCharsets.US_ASCII),
                sha256(value).getBytes(StandardCharsets.US_ASCII));
    }

    public static boolean sameSecret(String configured, String supplied) {
        return configured != null && !configured.isBlank() && supplied != null && !supplied.isBlank()
                && matches(sha256(configured), supplied);
    }
}
