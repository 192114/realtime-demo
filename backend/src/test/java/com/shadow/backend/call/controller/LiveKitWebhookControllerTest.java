package com.shadow.backend.call.controller;

import com.shadow.backend.call.config.LiveKitProperties;
import com.shadow.backend.call.service.CallService;
import io.livekit.server.AccessToken;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Base64;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class LiveKitWebhookControllerTest {
    private static final String API_KEY = "unit-test-key";
    private static final String API_SECRET = "unit-test-secret-not-deployed";

    @Mock private CallService callService;
    private LiveKitProperties properties;
    private LiveKitWebhookController controller;

    @BeforeEach
    void setUp() {
        properties = new LiveKitProperties();
        properties.setEnabled(true);
        properties.setApiKey(API_KEY);
        properties.setApiSecret(API_SECRET);
        controller = new LiveKitWebhookController(properties, callService);
    }

    @Test
    void verifiedRoomFinishedEndsCallByRoomName() throws Exception {
        String body = "{\"event\":\"room_finished\",\"room\":{\"name\":\"call_"
                + "11111111-2222-4333-8444-555555555555\",\"sid\":\"RM_x\"}}";
        ResponseEntity<Void> response = controller.webhook("Bearer " + signed(body), body);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        verify(callService).onRoomFinished("11111111-2222-4333-8444-555555555555");
    }

    @Test
    void missingHeaderWrongSecretOrTamperedBodyAreAllRejected() throws Exception {
        String body = roomFinished("call_11111111-2222-4333-8444-555555555555");
        assertThat(controller.webhook(null, body).getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
        assertThat(controller.webhook(signed(body, API_KEY, "wrong-secret-should-fail"), body)
                .getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
        String tampered = roomFinished("call_99999999-2222-4333-8444-555555555555");
        assertThat(controller.webhook(signed(body), tampered).getStatusCode())
                .isEqualTo(HttpStatus.UNAUTHORIZED);
        assertThat(controller.webhook("Bearer garbage", body).getStatusCode())
                .isEqualTo(HttpStatus.UNAUTHORIZED);
        verify(callService, never()).onRoomFinished(anyString());
    }

    @Test
    void disabledFeatureOrNonCallRoomsOrOtherEventsAreIgnoredWithoutError() throws Exception {
        properties.setEnabled(false);
        assertThat(controller.webhook(signed(roomFinished("call_x")), roomFinished("call_x"))
                .getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
        properties.setEnabled(true);
        String foreign = roomFinished("mytestroom");
        assertThat(controller.webhook("Bearer " + signed(foreign), foreign).getStatusCode())
                .isEqualTo(HttpStatus.OK);
        String started = "{\"event\":\"room_started\",\"room\":{\"name\":\"call_11111111-2222-4333-8444-555555555555\"}}";
        assertThat(controller.webhook("Bearer " + signed(started), started).getStatusCode())
                .isEqualTo(HttpStatus.OK);
        String bareRoom = "{\"event\":\"room_finished\",\"room\":{\"name\":\"call_\"}}";
        assertThat(controller.webhook("Bearer " + signed(bareRoom), bareRoom).getStatusCode())
                .isEqualTo(HttpStatus.OK);
        verify(callService, never()).onRoomFinished(anyString());
    }

    private String roomFinished(String room) {
        return "{\"event\":\"room_finished\",\"room\":{\"name\":\"" + room + "\",\"sid\":\"RM_x\"}}";
    }

    private String signed(String body) throws Exception {
        return signed(body, API_KEY, API_SECRET);
    }

    private String signed(String body, String apiKey, String secret) throws Exception {
        AccessToken token = new AccessToken(apiKey, secret);
        token.setSha256(Base64.getEncoder().encodeToString(MessageDigest.getInstance("SHA-256")
                .digest(body.getBytes(StandardCharsets.UTF_8))));
        return token.toJwt();
    }
}
