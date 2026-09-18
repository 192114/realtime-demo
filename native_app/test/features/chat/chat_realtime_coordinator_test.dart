import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:native_app/features/chat/datasources/chat_mqtt_datasource.dart';
import 'package:native_app/features/chat/models/chat_models.dart';
import 'package:native_app/features/chat/repositories/chat_realtime_coordinator.dart';
import 'package:native_app/features/chat/repositories/chat_repository.dart';

class ProbeRepository extends Fake implements ChatRepository {
  final actions = <String>[];
  bool active = true;
  bool offline = false;
  @override
  bool get isActive => active;
  @override
  Future<void> catchUp() async {
    actions.add('sync');
    if (offline) throw StateError('离线');
  }
  @override
  Future<void> onEvent(ChatEvent event) async { actions.add('event'); }
}

class ProbeTransport implements ChatMqttDataSource {
  ProbeTransport(this.actions);
  final List<String> actions;
  Completer<void>? subscription;
  bool fail = false;
  bool closed = false;
  void Function()? disconnect;
  @override
  Future<void> subscribe(MqttCredentials credentials, {required void Function(ChatEvent) onEvent,
    void Function(Map<String, dynamic>)? onCallEvent,
    required void Function() onDisconnected}) async {
    actions.add('subscribe:${credentials.password}');
    disconnect = onDisconnected;
    if (fail) throw StateError('MQTT 不可达');
    await subscription?.future;
    actions.add('suback');
  }
  @override
  void close() { closed = true; }
}

void main() {
  testWidgets('等待 SUBACK 才补拉，断开后获取新凭据并再次先订阅', (tester) async {
    final repo = ProbeRepository();
    final transports = <ProbeTransport>[];
    var fetches = 0;
    final gate = Completer<void>();
    final service = ChatRealtimeCoordinator(repository: repo, random: Random(1),
      credentials: () async {
        fetches++;
        return MqttCredentials(url: 'ws://localhost/mqtt', clientId: 'device', username: 'u',
          password: 'p$fetches', expiresAt: DateTime.now().add(const Duration(minutes: 2)), topics: ['events', 'calls'], qos: 1);
      },
      createTransport: () {
        final transport = ProbeTransport(repo.actions);
        if (transports.isEmpty) transport.subscription = gate;
        transports.add(transport);
        return transport;
      });
    service.setForeground(true);
    await tester.pump();
    expect(repo.actions, ['subscribe:p1']);
    gate.complete();
    await tester.pump();
    expect(repo.actions, ['subscribe:p1', 'suback', 'sync']);
    transports.single.disconnect!();
    await tester.pump(const Duration(seconds: 3));
    expect(fetches, 2);
    expect(repo.actions.sublist(3), ['subscribe:p2', 'suback', 'sync']);
    service.dispose();
  });

  testWidgets('凭据到期前主动取新密码，后台取消连接和续期定时器', (tester) async {
    final repo = ProbeRepository();
    final transports = <ProbeTransport>[];
    var clock = DateTime.utc(2026);
    var fetches = 0;
    final service = ChatRealtimeCoordinator(repository: repo, now: () => clock,
      credentials: () async => MqttCredentials(url: 'ws://localhost/mqtt', clientId: 'd', username: 'u',
        password: 'p${++fetches}', expiresAt: clock.add(const Duration(seconds: 10)), topics: ['events'], qos: 1),
      createTransport: () { final t = ProbeTransport(repo.actions); transports.add(t); return t; });
    service.setForeground(true);
    await tester.pump();
    expect(fetches, 1);
    clock = clock.add(const Duration(seconds: 8));
    await tester.pump(const Duration(seconds: 8));
    expect(fetches, 2);
    expect(transports.first.closed, isTrue);
    service.setForeground(false);
    await tester.pump(const Duration(minutes: 5));
    expect(fetches, 2);
    expect(transports.last.closed, isTrue);
    expect(service.state, ChatConnection.background);
    service.dispose();
  });

  testWidgets('MQTT 不可达仍补拉，HTTP 离线恢复后再次同步', (tester) async {
    final repo = ProbeRepository();
    final service = ChatRealtimeCoordinator(repository: repo,
      credentials: () async => MqttCredentials(url: 'ws://localhost/mqtt', clientId: 'd', username: 'u',
        password: 'p', expiresAt: DateTime.now().add(const Duration(minutes: 2)), topics: ['events'], qos: 1),
      createTransport: () => ProbeTransport(repo.actions)..fail = true);
    service.setForeground(true);
    await tester.pump();
    expect(service.state, ChatConnection.httpOnly);
    expect(repo.actions, contains('sync'));
    repo.offline = true;
    service.retry();
    await tester.pump();
    expect(service.state, ChatConnection.offline);
    repo.offline = false;
    service.retry();
    await tester.pump();
    expect(service.state, ChatConnection.httpOnly);
    service.dispose();
  });
}
