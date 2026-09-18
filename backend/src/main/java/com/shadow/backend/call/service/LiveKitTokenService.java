package com.shadow.backend.call.service;

/**
 * 签发绑定单次通话、单一房间、短有效期的 LiveKit AccessToken。
 * Token 只经 HTTPS 返回给通话参与者，绝不在日志或 MQTT 事件中出现。
 */
public interface LiveKitTokenService {

    String issue(String callId, Long userId, String nickname);

    String roomName(String callId);
}
