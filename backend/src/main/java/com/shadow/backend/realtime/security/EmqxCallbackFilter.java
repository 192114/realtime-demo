package com.shadow.backend.realtime.security;

import com.shadow.backend.realtime.config.RealtimeMqttProperties;
import com.shadow.backend.realtime.response.EmqxProtocol;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.jspecify.annotations.NonNull;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.util.ContentCachingResponseWrapper;

import java.io.IOException;
import java.util.Collections;
import java.util.OptionalLong;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 10)
@RequiredArgsConstructor
public class EmqxCallbackFilter extends OncePerRequestFilter {
    private final RealtimeMqttProperties properties;

    @Override
    protected boolean shouldNotFilter(@NonNull HttpServletRequest request) {
        return !request.getRequestURI().equals("/internal/realtime/emqx/authenticate")
                && !request.getRequestURI().equals("/internal/realtime/emqx/authorize");
    }

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain) throws ServletException, IOException {
        var wrapped = new ContentCachingResponseWrapper(response);
        try {
            var secrets = Collections.list(request.getHeaders("X-Realtime-Secret"));
            boolean trusted = properties.isEnabled() && secrets.size() == 1
                    && RealtimeSecrets.sameSecret(properties.getInternalCallbackSecret(), secrets.getFirst());
            boolean json = request.getContentType() != null
                    && MediaType.APPLICATION_JSON.isCompatibleWith(MediaType.parseMediaType(request.getContentType()));
            if (!trusted || !"POST".equals(request.getMethod()) || !json) {
                deny(request, wrapped);
            } else {
                filterChain.doFilter(request, wrapped);
                if (wrapped.getStatus() != 200) {
                    deny(request, wrapped);
                }
            }
        } catch (Exception ex) {
            // 覆盖参数绑定之前及下游 Filter 异常；不输出错误正文、请求头或异常消息。
            deny(request, wrapped);
        }
        wrapped.copyBodyToResponse();
    }

    private void deny(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.reset();
        response.setStatus(200);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setHeader("Cache-Control", "no-store");
        String body = request.getRequestURI().endsWith("/authenticate")
                ? EmqxProtocol.authentication(OptionalLong.empty()).getBody()
                : EmqxProtocol.authorization(false).getBody();
        response.getWriter().write(body);
    }
}
