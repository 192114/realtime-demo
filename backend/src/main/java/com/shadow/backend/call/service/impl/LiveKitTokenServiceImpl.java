package com.shadow.backend.call.service.impl;

import com.shadow.backend.call.config.LiveKitProperties;
import com.shadow.backend.call.service.LiveKitTokenService;
import io.livekit.server.AccessToken;
import io.livekit.server.CanPublish;
import io.livekit.server.CanSubscribe;
import io.livekit.server.RoomJoin;
import io.livekit.server.RoomName;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class LiveKitTokenServiceImpl implements LiveKitTokenService {
    private final LiveKitProperties properties;

    @Override
    public String roomName(String callId) {
        return "call_" + callId;
    }

    @Override
    public String issue(String callId, Long userId, String nickname) {
        AccessToken token = new AccessToken(properties.getApiKey(), properties.getApiSecret());
        token.setIdentity(String.valueOf(userId));
        if (StringUtils.hasText(nickname)) {
            token.setName(nickname);
        }
        token.setTtl(properties.getTokenTtlSeconds() * 1000L);
        // 最小权限：仅允许加入本通话房间并收发媒体；无建房、管理与跨房权限。
        token.addGrants(new RoomJoin(true), new RoomName(roomName(callId)),
                new CanPublish(true), new CanSubscribe(true));
        return token.toJwt();
    }
}
