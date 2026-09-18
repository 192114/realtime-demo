package com.shadow.backend.realtime.controller;

import com.shadow.backend.realtime.dto.EmqxAuthenticationRequest;
import com.shadow.backend.realtime.dto.EmqxAuthorizationRequest;
import com.shadow.backend.realtime.response.EmqxProtocol;
import com.shadow.backend.realtime.service.EmqxAccessService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.OptionalLong;

@RestController
@RequestMapping("/internal/realtime/emqx")
@RequiredArgsConstructor
public class EmqxCallbackController {
    private final EmqxAccessService accessService;

    @PostMapping(value = "/authenticate", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> authenticate(@RequestHeader(value = "X-Realtime-Secret", required = false) String secret,
                                              @RequestBody(required = false) EmqxAuthenticationRequest request) {
        try {
            return EmqxProtocol.authentication(accessService.authenticate(secret, request));
        } catch (Exception ex) {
            return EmqxProtocol.authentication(OptionalLong.empty());
        }
    }

    @PostMapping(value = "/authorize", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> authorize(@RequestHeader(value = "X-Realtime-Secret", required = false) String secret,
                                           @RequestBody(required = false) EmqxAuthorizationRequest request) {
        try {
            return EmqxProtocol.authorization(accessService.authorize(secret, request));
        } catch (Exception ex) {
            return EmqxProtocol.authorization(false);
        }
    }
}
