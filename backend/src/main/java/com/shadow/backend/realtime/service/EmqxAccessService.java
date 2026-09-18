package com.shadow.backend.realtime.service;

import com.shadow.backend.realtime.dto.EmqxAuthenticationRequest;
import com.shadow.backend.realtime.dto.EmqxAuthorizationRequest;

import java.util.OptionalLong;

public interface EmqxAccessService {
    OptionalLong authenticate(String callbackSecret, EmqxAuthenticationRequest request);

    boolean authorize(String callbackSecret, EmqxAuthorizationRequest request);
}
