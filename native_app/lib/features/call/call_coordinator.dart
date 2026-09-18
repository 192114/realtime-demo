import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:native_app/core/network/dio_client.dart';
import 'package:native_app/core/network/token_manager.dart';
import 'package:native_app/features/chat/chat_session_manager.dart';

import 'datasources/call_remote_datasource.dart';
import 'models/call_models.dart';

/// 通话协调器
///
/// 订阅 MQTT 通话信令事件维护来电信号与最近通话状态，前台时以 HTTP
/// active 轮询兜底（实时连接断开仍能发现来电）；页面通过 [remote]
/// 获取绑定当前登录代际的数据源执行通话操作，事件流由页面自行过滤。
class CallCoordinator extends ChangeNotifier {
  CallCoordinator({ChatSessionManager? sessionManager, DioClient? client,
    this.pollInterval = const Duration(seconds: 20)})
      : _sessionManager = sessionManager ?? chatSessionManager,
        _client = client ?? dioClient;

  final ChatSessionManager _sessionManager;
  final DioClient _client;
  final Duration pollInterval;

  CallSession? _incoming;
  final Map<String, CallSession> _known = {};
  StreamSubscription<Map<String, dynamic>>? _events;
  Timer? _poll;
  bool _foreground = false;
  bool _disposed = false;

  /// 当前待处理的来电（被叫视角）；UI 导航后调用 [consumeIncoming] 清除
  CallSession? get incoming => _incoming;

  /// 最近一次已知通话状态；页面初始化时可查询，未收到事件为 null
  CallSession? known(String callId) => _known[callId];

  /// 当前登录用户 ID；聊天会话就绪前为 null
  String? get myUserId => _sessionManager.repository?.userId;

  /// 注册通话事件订阅（幂等）
  void attach() {
    _events ??= _sessionManager.callEvents.listen(_handle);
  }

  /// 前台时启动来电轮询兜底，后台停止；遵循后台不保活原则
  void setForeground(bool foreground) {
    if (_disposed || _foreground == foreground) return;
    _foreground = foreground;
    _poll?.cancel();
    _poll = null;
    if (foreground && tokenManager.hasToken) {
      _poll = Timer.periodic(pollInterval, (_) => unawaited(_pollActive()));
    }
  }

  /// 绑定当前登录代际的通话数据源；每次操作独立实例，随请求结束释放
  CallRemoteDataSource remote() {
    if (_disposed) throw StateError('通话协调器已销毁');
    return DioCallRemoteDataSource(_client.dio, tokenManager.sessionEpoch);
  }

  void consumeIncoming() {
    if (_incoming != null) {
      _incoming = null;
      notifyListeners();
    }
  }

  Future<void> _pollActive() async {
    if (_disposed || !_foreground || !tokenManager.hasToken) return;
    try {
      final call = await remote().active();
      if (_disposed || call == null) return;
      _known[call.callId] = call;
      final status = call.callStatus;
      if (status == CallStatus.calling && call.calleeId == myUserId) {
        if (_incoming == null) {
          _incoming = call;
          notifyListeners();
        }
      } else if (_incoming?.callId == call.callId) {
        _incoming = null;
        notifyListeners();
      }
    } catch (_) {
      // 轮询失败不影响事件流，下一轮重试。
    }
  }

  void _handle(Map<String, dynamic> raw) {
    if (_disposed) return;
    final CallEvent event;
    final CallSession call;
    try {
      event = CallEvent.fromJson(raw);
      if (event.version != 1) return;
      call = CallSession.fromJson(event.payload);
    } catch (_) {
      return;
    }
    _known[event.callId] = call;
    switch (event.eventType) {
      case 'call.created':
        if (call.callStatus == CallStatus.calling && call.calleeId == myUserId) {
          _incoming = call;
          notifyListeners();
        }
      case 'call.accepted':
      case 'call.rejected':
      case 'call.cancelled':
      case 'call.timeout':
      case 'call.ended':
        if (_incoming?.callId == event.callId) {
          _incoming = null;
          notifyListeners();
        }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _events?.cancel();
    _poll?.cancel();
    super.dispose();
  }
}

/// 全局通话协调器单例
final callCoordinator = CallCoordinator();
