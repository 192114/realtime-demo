package com.shadow.backend.realtime.service;

public interface RealtimeIdentityService {
    boolean isAccountEligible(long userId);

    boolean isLoginValid(long userId, String loginTokenDigest);

    long remainingLoginSeconds(long userId, String token);
}
