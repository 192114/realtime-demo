import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:native_app/core/network/api_exception.dart';
import 'package:native_app/core/network/dio_client.dart';
import 'package:native_app/core/network/token_manager.dart';
import 'package:native_app/core/storage/secure_storage.dart';

import 'datasources/chat_local_datasource.dart';
import 'datasources/chat_mqtt_datasource.dart';
import 'datasources/chat_remote_datasource.dart';
import 'models/chat_models.dart';
import 'repositories/chat_realtime_coordinator.dart';
import 'repositories/chat_repository.dart';
import 'repositories/chat_repository_impl.dart';

/// 聊天会话管理器
///
/// 绑定登录代际（sessionEpoch）管理仓库与实时协调器的生命周期：
/// - 登录后惰性创建；退出或切换账号时销毁，本地库随会话关闭
/// - 前后台事件转发给协调器：后台主动断开实时连接，不模拟保活
/// - 聚合连接状态与仓库数据变化通知，供 UI 通过单一监听刷新
class ChatSessionManager extends ChangeNotifier {
  ChatSessionManager({SecureStorage? storage}) : _storage = storage ?? secureStorage;

  final SecureStorage _storage;
  static const _deviceIdKey = 'chat_device_id';

  ActiveChatSession? _session;
  Future<ChatRepository?>? _starting;
  int _startSeq = 0;
  bool _foreground = false;
  bool _attached = false;
  ChatConnection _connection = ChatConnection.background;
  String? _errorMessage;
  String? _deviceId;
  final _callEvents = StreamController<Map<String, dynamic>>.broadcast();

  /// 当前登录用户的通话信令事件（跨会话代际的稳定流）
  Stream<Map<String, dynamic>> get callEvents => _callEvents.stream;

  /// 当前会话仓库；未登录或未就绪时为 null
  ChatRepository? get repository => _session?.repository;

  /// 实时连接状态
  ChatConnection get connection => _connection;

  /// 初始化失败原因（会话就绪后自动清除）
  String? get errorMessage => _errorMessage;

  /// 是否正在初始化会话
  bool get initializing => _starting != null;

  /// 注册登录代际监听（幂等）
  ChatSessionManager attach() {
    if (!_attached) {
      _attached = true;
      tokenManager.addSessionListener(_onEpochChanged);
    }
    return this;
  }

  /// 确保聊天会话已创建；未登录返回 null。幂等且并发安全。
  Future<ChatRepository?> ensure() {
    attach();
    if (!tokenManager.hasToken) return Future.value(null);
    final current = _session;
    if (current != null && current.repository.isActive) {
      return Future.value(current.repository);
    }
    return _starting ??= _start(++_startSeq);
  }

  Future<ChatRepository?> _start(int seq) async {
    final epoch = tokenManager.sessionEpoch;
    _errorMessage = null;
    notifyListeners();
    try {
      final remote = DioChatRemoteDataSource(dioClient.dio, epoch);
      // 以服务端身份确认当前用户，不信任本地缓存
      final userId = await remote.verifyUser();
      if (!_valid(epoch)) return null;
      final local = await SqliteChatLocalDataSource.open(userId, () => _valid(epoch));
      if (!_valid(epoch)) {
        await local.close();
        return null;
      }
      final repository = ChatRepositoryImpl(
        userId: userId,
        local: local,
        remote: remote,
        sessionActive: () => _valid(epoch),
      );
      final coordinator = ChatRealtimeCoordinator(
        repository: repository,
        credentials: () => _fetchCredentials(remote, epoch),
        createTransport: () => WebSocketChatMqttDataSource(),
      );
      final session = ActiveChatSession._(repository: repository, coordinator: coordinator);
      _session = session;
      _connection = coordinator.state;
      session.states = coordinator.states.listen((value) {
        _connection = value;
        notifyListeners();
      });
      session.changes = repository.changes.listen((_) => notifyListeners());
      session.callEvents = coordinator.callEvents.listen(_callEvents.add);
      coordinator.setForeground(_foreground);
      notifyListeners();
      return repository;
    } catch (error) {
      if (!_valid(epoch)) return null;
      _errorMessage = error is ApiException ? error.message : '聊天服务初始化失败，请稍后重试';
      notifyListeners();
      return null;
    } finally {
      if (seq == _startSeq) _starting = null;
    }
  }

  bool _valid(int epoch) => tokenManager.hasToken && tokenManager.sessionEpoch == epoch;

  /// 每次连接都重新获取短时凭据，不缓存、不重用过期密码
  Future<MqttCredentials> _fetchCredentials(ChatRemoteDataSource remote, int epoch) async {
    final deviceId = await _loadDeviceId();
    final credentials = await remote.credentials(deviceId);
    if (!_valid(epoch)) throw StateError('账号会话已结束');
    return credentials;
  }

  /// 设备标识：首次生成并持久化；32 位十六进制加密安全随机字符
  Future<String> _loadDeviceId() async {
    final cached = _deviceId ?? await _storage.read(key: _deviceIdKey);
    if (cached != null && cached.isNotEmpty) {
      _deviceId = cached;
      return cached;
    }
    final random = Random.secure();
    final id = List<int>.generate(16, (_) => random.nextInt(256))
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    await _storage.write(key: _deviceIdKey, value: id);
    _deviceId = id;
    return id;
  }

  /// 前后台切换：转发给协调器，后台断开实时连接
  void setForeground(bool foreground) {
    if (_foreground == foreground) return;
    _foreground = foreground;
    _session?.coordinator.setForeground(foreground);
  }

  /// 手动触发重连与补拉
  void retry() => _session?.coordinator.retry();

  Future<void> _onEpochChanged() async {
    final previous = _session;
    _session = null;
    _connection = ChatConnection.background;
    _startSeq++;
    _starting = null;
    if (previous != null) {
      previous.disposeSubscriptions();
      previous.coordinator.dispose();
      await previous.repository.dispose();
    }
    notifyListeners();
    if (tokenManager.hasToken) {
      unawaited(ensure());
    }
  }
}

/// 当前活跃的聊天会话（仓库 + 实时协调器 + 通知订阅）
class ActiveChatSession {
  ActiveChatSession._({required this.repository, required this.coordinator});

  final ChatRepositoryImpl repository;
  final ChatRealtimeCoordinator coordinator;
  StreamSubscription<ChatConnection>? states;
  StreamSubscription<void>? changes;
  StreamSubscription<Map<String, dynamic>>? callEvents;

  void disposeSubscriptions() {
    states?.cancel();
    states = null;
    changes?.cancel();
    changes = null;
    callEvents?.cancel();
    callEvents = null;
  }
}

/// 全局聊天会话管理器单例
final chatSessionManager = ChatSessionManager();
