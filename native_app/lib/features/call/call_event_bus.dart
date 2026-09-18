import 'dart:async';

import 'package:native_app/features/chat/chat_session_manager.dart';

import 'models/call_models.dart';

/// 按通话 ID 过滤信令事件；解析失败或版本不符的事件被静默忽略。
StreamSubscription<Map<String, dynamic>> listenCallEvents(
    String callId, void Function(CallEvent) onEvent) {
  return chatSessionManager.callEvents.listen((raw) {
    try {
      final event = CallEvent.fromJson(raw);
      if (event.version == 1 && event.callId == callId) onEvent(event);
    } catch (_) {
      // 损坏事件不输出内容；HTTP 状态接口负责收敛。
    }
  });
}

/// 从事件负载解析通话状态；损坏负载返回 null
CallSession? callFromEvent(CallEvent event) {
  try {
    return CallSession.fromJson(event.payload);
  } catch (_) {
    return null;
  }
}
