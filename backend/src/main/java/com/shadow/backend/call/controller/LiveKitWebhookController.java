package com.shadow.backend.call.controller;

import com.shadow.backend.call.config.LiveKitProperties;
import com.shadow.backend.call.service.CallService;
import io.livekit.server.WebhookReceiver;
import lombok.RequiredArgsConstructor;
import livekit.LivekitWebhook;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class LiveKitWebhookController {
    private final LiveKitProperties properties;
    private final CallService callService;

    @PostMapping(value = "/internal/realtime/livekit/webhook", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Void> webhook(@RequestHeader(value = "Authorization", required = false) String authorization,
                                        @RequestBody String body) {
        if (!properties.isEnabled()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        try {
            String jwt = authorization == null ? null : authorization.replaceFirst("(?i)^Bearer\\s+", "");
            LivekitWebhook.WebhookEvent event = new WebhookReceiver(properties.getApiKey(), properties.getApiSecret())
                    .receive(body, jwt);
            if ("room_finished".equals(event.getEvent()) && event.hasRoom()) {
                String room = event.getRoom().getName();
                // 仅处理本服务创建的通话房间；未知房间幂等忽略，不回错给 LiveKit。
                if (room != null && room.startsWith("call_") && room.length() > "call_".length()) {
                    callService.onRoomFinished(room.substring("call_".length()));
                }
            }
            return ResponseEntity.ok().build();
        } catch (Exception ex) {
            // 验签或解析失败一律 401；不记录请求体或异常消息，避免事件内容进入日志。
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }
}
