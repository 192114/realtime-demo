package com.shadow.backend.realtime.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

import java.net.URI;
import java.time.Clock;
import java.util.Arrays;
import java.util.regex.Pattern;

@Configuration
@EnableConfigurationProperties(RealtimeMqttProperties.class)
public class RealtimeConfiguration {
    private static final Pattern VERSION = Pattern.compile("(5|6)\\.(\\d+)\\.(\\d+)(?:[-+][A-Za-z0-9.-]+)?");

    public RealtimeConfiguration(RealtimeMqttProperties properties, Environment environment) {
        if (!properties.isEnabled()) {
            return;
        }
        var version = VERSION.matcher(properties.getEmqxVersion());
        require(version.matches(), "必须明确配置已核实的 EMQX 5.8+ 或 6.x 版本");
        require(!"5".equals(version.group(1)) || Integer.parseInt(version.group(2)) >= 8,
                "EMQX 认证过期强断需要 5.8+ 或 6.x");
        require(properties.getServiceUsername().matches("[A-Za-z0-9_-]{1,64}")
                && !properties.getServiceUsername().startsWith("rtu_"), "服务用户名无效");
        require(properties.getServiceClientId().matches("rts_[A-Za-z0-9_-]{1,100}"), "服务 clientId 必须使用 rts_ 前缀");
        require(properties.getServicePassword().length() >= 32, "服务密码至少需要 32 个字符");
        require(properties.getInternalCallbackSecret().length() >= 32, "内部回调密钥至少需要 32 个字符");
        require(!properties.getServicePassword().equals(properties.getInternalCallbackSecret()), "服务密码和内部回调密钥必须独立");
        require(properties.getCredentialTtlSeconds() >= 30 && properties.getCredentialTtlSeconds() <= 900,
                "客户端凭据有效期必须为 30 至 900 秒");
        require(properties.getServiceSessionTtlSeconds() >= 60 && properties.getServiceSessionTtlSeconds() <= 86400,
                "服务认证有效期必须为 60 至 86400 秒");
        require(properties.getConnectTimeoutSeconds() >= 1 && properties.getConnectTimeoutSeconds() <= 60,
                "连接超时必须为 1 至 60 秒");
        require(properties.getPublishTimeoutSeconds() >= 1 && properties.getPublishTimeoutSeconds() <= 60,
                "发布超时必须为 1 至 60 秒");
        require(properties.getKeepAliveSeconds() >= 5 && properties.getKeepAliveSeconds() <= 300,
                "心跳间隔必须为 5 至 300 秒");
        require(properties.getMaxReconnectDelayMillis() >= 1000 && properties.getMaxReconnectDelayMillis() <= 120000,
                "重连最大间隔必须为 1000 至 120000 毫秒");
        // 只有单独启用 dev 时允许明文；prod 与 dev 同时启用也不能绕过 TLS。
        boolean devOnly = Arrays.equals(environment.getActiveProfiles(), new String[]{"dev"});
        validateUri(properties.getServerUri(), false, devOnly);
        validateUri(properties.getClientWebsocketUrl(), true, devOnly);
    }

    @Bean
    public Clock realtimeClock() {
        return Clock.systemUTC();
    }

    private static void validateUri(String value, boolean websocket, boolean devOnly) {
        try {
            URI uri = URI.create(value);
            String secure = websocket ? "wss" : "ssl";
            String insecure = websocket ? "ws" : "tcp";
            require(secure.equals(uri.getScheme()) || devOnly && insecure.equals(uri.getScheme()),
                    "非 dev 环境必须使用 TLS，且发布地址与客户端地址协议必须匹配");
            require(uri.getHost() != null && uri.getUserInfo() == null && uri.getQuery() == null
                    && uri.getFragment() == null, "MQTT 地址无效或包含敏感参数");
            require(websocket || uri.getPath() == null || uri.getPath().isEmpty(), "TCP 发布地址不能包含路径");
        } catch (IllegalArgumentException ex) {
            // 不传播 URI 解析异常，避免原始配置进入日志。
            throw new IllegalStateException("realtime MQTT 地址配置无效");
        }
    }

    private static void require(boolean condition, String message) {
        if (!condition) {
            throw new IllegalStateException(message);
        }
    }
}
