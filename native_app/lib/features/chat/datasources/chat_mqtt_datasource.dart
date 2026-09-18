import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../models/chat_models.dart';

abstract interface class ChatMqttDataSource {
  Future<void> subscribe(MqttCredentials credentials, {
    required void Function(ChatEvent) onEvent,
    void Function(Map<String, dynamic>)? onCallEvent,
    required void Function() onDisconnected,
  });
  void close();
}

/// 只接收服务器授权的 topic；不提供 publish 接口。
class WebSocketChatMqttDataSource implements ChatMqttDataSource {
  MqttServerClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updates;
  bool _closed = false;
  Completer<void>? _subscribed;

  @override
  Future<void> subscribe(MqttCredentials credentials, {
    required void Function(ChatEvent) onEvent,
    void Function(Map<String, dynamic>)? onCallEvent,
    required void Function() onDisconnected,
  }) async {
    final uri = Uri.parse(credentials.url);
    if (!['ws', 'wss'].contains(uri.scheme) || uri.host.isEmpty || credentials.qos != 1 || credentials.topics.isEmpty) {
      throw const FormatException('实时连接配置无效');
    }
    final client = MqttServerClient.withPort(credentials.url, credentials.clientId,
      uri.hasPort ? uri.port : (uri.scheme == 'wss' ? 443 : 80), maxConnectionAttempts: 1)
      ..useWebSocket = true
      ..websocketProtocols = ['mqtt']
      ..autoReconnect = false
      ..keepAlivePeriod = 30
      ..disconnectOnNoResponsePeriod = 15
      ..connectTimeoutPeriod = 10000
      ..connectionMessage = MqttConnectMessage().withClientIdentifier(credentials.clientId).startClean()
      ..setProtocolV311()
      ..logging(on: false, logPayloads: false);
    _client = client;
    client.onDisconnected = () {
      final pending = _subscribed;
      if (pending != null && !pending.isCompleted) pending.completeError(StateError('实时连接中断'));
      if (!_closed) onDisconnected();
    };
    await client.connect(credentials.username, credentials.password).timeout(const Duration(seconds: 12));
    if (_closed || client.connectionStatus?.state != MqttConnectionState.connected) {
      client.disconnect();
      throw StateError('实时连接未建立');
    }
    // 必须先监听消息再订阅，并等待所有 SUBACK，之后才允许增量补拉。
    _updates = client.updates!.listen((events) {
      if (_closed) return;
      for (final received in events) {
        if (!credentials.topics.contains(received.topic)) continue;
        try {
          final publish = received.payload as MqttPublishMessage;
          final json = Map<String, dynamic>.from(
              jsonDecode(utf8.decode(publish.payload.message)) as Map);
          if (received.topic.endsWith('/calls')) {
            // 通话信令事件不在此解析，原始负载由通话模块按其契约处理。
            onCallEvent?.call(json);
            continue;
          }
          final event = ChatEvent.fromJson(json);
          if (event.version == 1) onEvent(event);
        } catch (_) {
          // 非文本聊天事件或损坏事件不输出内容；定时 HTTP 补拉负责收敛。
        }
      }
    });
    final remaining = credentials.topics.toSet();
    final subscribed = Completer<void>();
    _subscribed = subscribed;
    client.onSubscribed = (topic) {
      remaining.remove(topic);
      if (remaining.isEmpty && !subscribed.isCompleted) subscribed.complete();
    };
    client.onSubscribeFail = (_) {
      if (!subscribed.isCompleted) subscribed.completeError(StateError('订阅被拒绝'));
    };
    for (final topic in remaining.toList()) {
      if (client.subscribe(topic, MqttQos.atLeastOnce) == null && !subscribed.isCompleted) {
        subscribed.completeError(StateError('订阅失败'));
      }
    }
    await subscribed.future.timeout(const Duration(seconds: 10));
    if (_closed) throw StateError('实时连接已关闭');
  }

  @override
  void close() {
    _closed = true;
    unawaited(_updates?.cancel());
    _client?.onDisconnected = null;
    _client?.disconnect();
    final pending = _subscribed;
    if (pending != null && !pending.isCompleted) pending.completeError(StateError('实时连接已关闭'));
    _client = null;
  }
}
