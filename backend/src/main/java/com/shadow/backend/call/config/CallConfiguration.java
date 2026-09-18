package com.shadow.backend.call.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

import java.net.URI;
import java.util.Arrays;

@Configuration
@EnableConfigurationProperties(LiveKitProperties.class)
public class CallConfiguration {
    public CallConfiguration(LiveKitProperties properties, Environment environment) {
        if (!properties.isEnabled()) {
            return;
        }
        require(properties.getApiKey().matches("[A-Za-z0-9_-]{1,64}"), "LiveKit API Key 无效");
        require(properties.getApiSecret().length() >= 8, "LiveKit API Secret 至少需要 8 个字符");
        require(!properties.getApiKey().equals(properties.getApiSecret()), "LiveKit API Key 和 Secret 必须独立");
        require(properties.getTokenTtlSeconds() >= 60 && properties.getTokenTtlSeconds() <= 3600,
                "通话 Token 有效期必须为 60 至 3600 秒");
        require(properties.getCallTimeoutSeconds() >= 10 && properties.getCallTimeoutSeconds() <= 300,
                "呼叫超时必须为 10 至 300 秒");
        require(properties.getTimeoutBatchSize() >= 1 && properties.getTimeoutBatchSize() <= 1000,
                "超时扫描批量必须为 1 至 1000");
        // 只有单独启用 dev 时允许明文；prod 与 dev 同时启用也不能绕过 TLS。
        boolean devOnly = Arrays.equals(environment.getActiveProfiles(), new String[]{"dev"});
        validateUrl(properties.getUrl(), devOnly);
    }

    private static void validateUrl(String value, boolean devOnly) {
        try {
            URI uri = URI.create(value);
            require("wss".equals(uri.getScheme()) || devOnly && "ws".equals(uri.getScheme()),
                    "非 dev 环境必须使用 TLS 访问 LiveKit");
            require(uri.getHost() != null && uri.getUserInfo() == null && uri.getQuery() == null
                    && uri.getFragment() == null, "LiveKit 地址无效或包含敏感参数");
        } catch (IllegalArgumentException ex) {
            // 不传播 URI 解析异常，避免原始配置进入日志。
            throw new IllegalStateException("realtime LiveKit 地址配置无效");
        }
    }

    private static void require(boolean condition, String message) {
        if (!condition) {
            throw new IllegalStateException(message);
        }
    }
}
