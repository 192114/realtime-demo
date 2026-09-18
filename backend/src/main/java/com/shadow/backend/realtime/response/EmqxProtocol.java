package com.shadow.backend.realtime.response;

import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import java.util.OptionalLong;

public final class EmqxProtocol {
    private EmqxProtocol() {
    }

    public static ResponseEntity<String> authentication(OptionalLong expiresAt) {
        // 仅拼接后端生成的 epoch 数字，不经过全局 Long 字符串序列化，也不拼接任何请求输入。
        String body = expiresAt.isPresent() && expiresAt.getAsLong() > 0
                ? "{\"result\":\"allow\",\"is_superuser\":false,\"expire_at\":" + expiresAt.getAsLong() + "}"
                : "{\"result\":\"deny\",\"is_superuser\":false}";
        return json(body);
    }

    public static ResponseEntity<String> authorization(boolean allowed) {
        return json(allowed ? "{\"result\":\"allow\"}" : "{\"result\":\"deny\"}");
    }

    private static ResponseEntity<String> json(String body) {
        return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).cacheControl(CacheControl.noStore()).body(body);
    }
}
