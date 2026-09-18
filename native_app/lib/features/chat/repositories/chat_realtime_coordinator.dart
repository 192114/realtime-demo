import 'dart:async';
import 'dart:math';

import '../datasources/chat_mqtt_datasource.dart';
import '../models/chat_models.dart';
import 'chat_repository.dart';

enum ChatConnection { connecting, online, httpOnly, offline, background }

/// 不依赖 Widget；前后台事件由应用层传入，后台主动断开而非模拟保活。
class ChatRealtimeCoordinator {
  ChatRealtimeCoordinator({required this.repository, required this.credentials,
    required this.createTransport, this.pollInterval = const Duration(seconds: 20),
    DateTime Function()? now, Random? random}) : now = now ?? DateTime.now, random = random ?? Random();
  final ChatRepository repository;
  final Future<MqttCredentials> Function() credentials;
  final ChatMqttDataSource Function() createTransport;
  final Duration pollInterval;
  final DateTime Function() now;
  final Random random;
  final _states = StreamController<ChatConnection>.broadcast();
  Stream<ChatConnection> get states => _states.stream;
  final _callEvents = StreamController<Map<String, dynamic>>.broadcast();

  /// chat/user/{id}/calls 主题的原始事件负载；语义解析由通话模块负责。
  Stream<Map<String, dynamic>> get callEvents => _callEvents.stream;
  ChatConnection state = ChatConnection.background;
  bool _foreground = false;
  bool _disposed = false;
  bool _connecting = false;
  bool _subscribed = false;
  int _generation = 0;
  int _failures = 0;
  Timer? _retry;
  Timer? _renew;
  Timer? _poll;
  ChatMqttDataSource? _transport;
  Future<void>? _syncing;

  bool get _active => !_disposed && _foreground && repository.isActive;
  void _state(ChatConnection next) {
    if (_disposed) return;
    state = next;
    _states.add(next);
  }

  void setForeground(bool foreground) {
    if (_disposed || _foreground == foreground) return;
    _foreground = foreground;
    _generation++;
    _stop();
    if (foreground) {
      _poll = Timer.periodic(pollInterval, (_) {
        if (!_connecting) unawaited(_sync());
      });
      unawaited(_connect());
    } else {
      _state(ChatConnection.background);
    }
  }

  void retry() {
    if (!_active) return;
    _retry?.cancel();
    if (_subscribed) { unawaited(_sync()); } else { unawaited(_connect()); }
  }

  Future<void> _connect() async {
    if (!_active || _connecting) return;
    _connecting = true;
    _subscribed = false;
    final generation = ++_generation;
    bool valid() => _active && generation == _generation;
    _transport?.close();
    _renew?.cancel();
    _state(ChatConnection.connecting);
    try {
      // 每次尝试重新获取 HTTP 凭据，绝不无限重用过期密码。
      final auth = await credentials();
      if (!valid()) return;
      if (auth.expiresAt.difference(now()).inSeconds <= 5) throw StateError('凭据有效期不足');
      final transport = createTransport();
      _transport = transport;
      await transport.subscribe(auth, onEvent: (event) {
        if (valid()) unawaited(_event(event));
      }, onCallEvent: (payload) {
        if (valid()) _callEvents.add(payload);
      }, onDisconnected: () {
        if (!valid()) return;
        _subscribed = false;
        _state(ChatConnection.httpOnly);
        _scheduleRetry();
      });
      if (!valid()) { transport.close(); return; }
      _subscribed = true;
      _failures = 0;
      _retry?.cancel();
      final remaining = auth.expiresAt.difference(now());
      if (remaining.inSeconds <= 2) throw StateError('凭据即将到期');
      final margin = min(30, max(1, remaining.inSeconds ~/ 5));
      _renew = Timer(remaining - Duration(seconds: margin), () {
        if (valid()) unawaited(_connect());
      });
      _connecting = false;
      // 等待全部订阅确认之后再补拉，覆盖建立订阅期间的消息窗口。
      await _sync(forceAfterCurrent: true);
    } catch (_) {
      if (!valid()) return;
      _transport?.close();
      _subscribed = false;
      _connecting = false;
      _scheduleRetry();
      await _sync();
    } finally {
      if (generation == _generation) _connecting = false;
    }
  }

  Future<void> _event(ChatEvent event) async {
    try { await repository.onEvent(event); }
    catch (_) { if (_active) _state(ChatConnection.offline); }
  }

  Future<void> _sync({bool forceAfterCurrent = false}) async {
    final running = _syncing;
    if (running != null) {
      await running;
      if (!forceAfterCurrent) return;
    }
    if (!_active) return;
    final future = _doSync();
    _syncing = future;
    await future;
    if (identical(_syncing, future)) _syncing = null;
  }
  Future<void> _doSync() async {
    try {
      await repository.catchUp();
      if (_active) _state(_subscribed ? ChatConnection.online : ChatConnection.httpOnly);
    } catch (_) {
      if (_active) _state(ChatConnection.offline);
    }
  }

  void _scheduleRetry() {
    if (!_active || (_retry?.isActive ?? false)) return;
    final seconds = min(30, 1 << min(_failures++, 5));
    _retry = Timer(Duration(milliseconds: seconds * 1000 + random.nextInt(1000)), () {
      unawaited(_connect());
    });
  }
  void _stop() {
    _retry?.cancel(); _renew?.cancel(); _poll?.cancel();
    _transport?.close(); _transport = null;
    _connecting = false;
    _subscribed = false;
  }
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _generation++;
    _stop();
    unawaited(_states.close());
    unawaited(_callEvents.close());
  }
}
