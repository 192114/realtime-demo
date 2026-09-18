import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:native_app/features/chat/datasources/chat_local_datasource.dart';
import 'package:native_app/features/chat/datasources/chat_remote_datasource.dart';
import 'package:native_app/features/chat/models/chat_models.dart';
import 'package:native_app/features/chat/repositories/chat_repository.dart';
import 'package:native_app/features/chat/repositories/chat_repository_impl.dart';

final time = DateTime.utc(2026);
ChatMessage message(int seq, {String sender = 'peer', String? client}) => ChatMessage(
  messageId: 'm$seq', conversationId: 'c', senderId: sender,
  clientMsgId: client ?? 'uuid-$seq', seq: seq, text: '消息$seq', createdAt: time);
ChatConversation conversation() => ChatConversation(conversationId: 'c', peerUserId: 'peer', updatedAt: time);
ChatEvent event(ChatMessage m) => ChatEvent(eventId: 'event-${m.seq}', eventType: 'message.created', version: 1,
  conversationId: 'c', messageId: m.messageId, seq: m.seq, occurredAt: time, payload: m.toJson());

class MemoryChatStore implements ChatLocalDataSource {
  final rows = <String, ChatMessage>{};
  final outbox = <String, PendingMessage>{};
  final summaries = <String, ChatConversation>{};
  final cursors = <String, int>{};
  bool failWrite = false;
  bool closed = false;
  void check() { if (failWrite || closed) throw StateError('写入失败'); }
  @override
  Future<List<ChatConversation>> conversations() async => summaries.values.toList();
  @override
  Future<List<ChatMessage>> messages(String id, {int limit = 50}) async =>
    (rows.values.where((m) => m.conversationId == id).toList()..sort((a, b) => b.seq.compareTo(a.seq))).take(limit).toList();
  @override
  Future<List<PendingMessage>> pending() async => outbox.values.toList();
  @override
  Future<int> cursor(String id) async => cursors[id] ?? 0;
  @override
  Future<void> savePending(PendingMessage m) async {
    check();
    if (!rows.values.any((r) => r.senderId == m.senderId && r.clientMsgId == m.clientMsgId)) outbox.putIfAbsent(m.clientMsgId, () => m);
  }
  @override
  Future<void> saveConversations(List<ChatConversation> items) async {
    check();
    for (final c in items) { summaries[c.conversationId] = c; }
  }
  @override
  Future<void> saveMessages(String id, List<ChatMessage> items, {int? syncAfter}) async {
    check();
    final next = syncAfter == null ? null : contiguousCursor(id, syncAfter, items);
    for (final m in items) {
      rows.putIfAbsent(m.messageId, () => m);
      outbox.removeWhere((_, p) => p.clientMsgId == m.clientMsgId && p.senderId == m.senderId);
    }
    if (next != null) cursors[id] = next;
  }
  @override
  Future<void> saveRead(String id, int seq) async {
    summaries[id] = summaries[id]!.copyWith(readSeq: seq);
  }
  @override
  Future<void> close() async { closed = true; }
}

class FakeChatRemote implements ChatRemoteDataSource {
  final server = <ChatMessage>[];
  final afters = <int>[];
  final sentIds = <String>[];
  final reads = <int>[];
  bool offline = false;
  bool cancelled = false;
  bool loseAck = false;
  Completer<void>? barrier;
  Completer<void>? requested;
  @override
  Future<String> verifyUser() async => 'me';
  @override
  Future<ChatConversation> direct(String peerUserId) async => conversation();
  @override
  Future<ChatConversationPage> conversations({String? beforeId}) async => ChatConversationPage(items: [conversation()], hasMore: false);
  @override
  Future<ChatMessagePage> history(String id, {String? beforeSeq}) async => ChatMessagePage(items: server.reversed.toList(), hasMore: false);
  @override
  Future<ChatMessagePage> sync(String id, int afterSeq) async {
    afters.add(afterSeq);
    requested?.complete(); requested = null;
    await barrier?.future;
    if (offline) throw StateError('离线');
    final items = server.where((m) => m.seq > afterSeq).take(2).toList();
    final more = server.where((m) => m.seq > afterSeq).length > 2;
    return ChatMessagePage(items: items, hasMore: more, nextCursor: items.isEmpty ? null : '${items.last.seq}');
  }
  @override
  Future<ChatMessage> send(PendingMessage m) async {
    sentIds.add(m.clientMsgId);
    if (offline) throw StateError('离线');
    final response = server.where((s) => s.clientMsgId == m.clientMsgId).firstOrNull ??
      message(server.length + 1, sender: m.senderId, client: m.clientMsgId);
    if (!server.contains(response)) server.add(response);
    if (loseAck) throw StateError('确认丢失');
    return response;
  }
  @override
  Future<int> read(String id, int seq) async { reads.add(seq); return seq; }
  @override
  Future<MqttCredentials> credentials(String deviceId) => throw UnimplementedError();
  @override
  void cancel() { cancelled = true; }
}

void main() {
  late MemoryChatStore local;
  late FakeChatRemote remote;
  late ChatRepositoryImpl repo;
  var active = true;
  setUp(() {
    active = true;
    local = MemoryChatStore();
    remote = FakeChatRemote();
    repo = ChatRepositoryImpl(userId: 'me', local: local, remote: remote, sessionActive: () => active);
  });
  tearDown(() => repo.dispose());

  test('重复 MQTT / HTTP 投递只保留一条消息', () async {
    remote.server.add(message(1));
    await repo.onEvent(event(message(1)));
    await repo.onEvent(event(message(1)));
    await repo.sync('c');
    expect(local.rows.length, 1);
    expect(await repo.cursor('c'), 1);
  });

  test('MQTT 高 seq 先落盘不能跳游标，重连分页补齐乱序消息', () async {
    remote.offline = true;
    await expectLater(repo.onEvent(event(message(5))), throwsStateError);
    expect(local.rows.length, 1);
    expect(await repo.cursor('c'), 0);
    remote.server.addAll(List.generate(5, (i) => message(i + 1)));
    remote.offline = false;
    await repo.catchUp();
    expect(remote.afters, [0, 0, 2, 4]);
    expect((await repo.messages('c')).map((m) => m.seq), [5, 4, 3, 2, 1]);
    expect(await repo.cursor('c'), 5);
  });

  test('历史与 HTTP 确认不推进增量游标', () async {
    remote.server.addAll([message(8), message(9)]);
    await repo.history('c');
    expect(await repo.cursor('c'), 0);
    final pending = repo.draft('c', '测试');
    await repo.send(pending);
    expect(await repo.cursor('c'), 0);
    expect(local.outbox, isEmpty);
  });

  test('增量缺口或落盘失败不推进游标，恢复后可重新补齐', () async {
    remote.server.add(message(2));
    await expectLater(repo.sync('c'), throwsFormatException);
    expect(await repo.cursor('c'), 0);
    remote.server.insert(0, message(1));
    local.failWrite = true;
    await expectLater(repo.sync('c'), throwsStateError);
    expect(await repo.cursor('c'), 0);
    local.failWrite = false;
    await repo.sync('c');
    expect(await repo.cursor('c'), 2);
  });

  test('发送先落盘，失败和应用重开后重试 UUID 不变', () async {
    final pending = repo.draft('c', '你好');
    local.failWrite = true;
    await expectLater(repo.send(pending), throwsA(isA<ChatPersistenceException>()));
    expect(remote.sentIds, isEmpty);
    local.failWrite = false;
    remote.offline = true;
    await expectLater(repo.send(pending), throwsStateError);
    expect(local.outbox.singleValue.clientMsgId, pending.clientMsgId);
    final reopened = ChatRepositoryImpl(userId: 'me', local: local, remote: remote, sessionActive: () => active);
    remote.offline = false;
    await reopened.send((await reopened.pending()).single);
    expect(remote.sentIds, [pending.clientMsgId, pending.clientMsgId]);
    expect(local.outbox, isEmpty);
    await reopened.dispose();
  });

  test('服务端收到但 ACK 丢失，补拉按 sender/clientMsgId 清除 pending', () async {
    final pending = repo.draft('c', '测试确认丢失');
    remote.loseAck = true;
    await expectLater(repo.send(pending), throwsStateError);
    expect(local.outbox.length, 1);
    await repo.sync('c');
    expect(local.outbox, isEmpty);
    expect(local.rows.length, 1);
  });

  test('相同 clientMsgId 的其他 sender 不清除当前账号 pending', () async {
    final pending = repo.draft('c', '自己');
    await local.savePending(pending);
    remote.server.add(message(1, sender: 'peer', client: pending.clientMsgId));
    await repo.sync('c');
    expect(local.outbox.length, 1);
  });

  test('退出取消连接请求；迟到响应不能落盘到旧/新账号', () async {
    remote.server.add(message(1));
    remote.barrier = Completer<void>();
    remote.requested = Completer<void>();
    final started = remote.requested!.future;
    final request = repo.sync('c');
    final assertion = expectLater(request, throwsStateError);
    await started;
    active = false;
    await repo.dispose();
    final otherStore = MemoryChatStore();
    final other = ChatRepositoryImpl(userId: 'other', local: otherStore, remote: FakeChatRemote(), sessionActive: () => true);
    remote.barrier!.complete();
    await assertion;
    expect(remote.cancelled, isTrue);
    expect(local.rows, isEmpty);
    expect(await other.pending(), isEmpty);
    expect(SqliteChatLocalDataSource.databaseName('me'), isNot(SqliteChatLocalDataSource.databaseName('other')));
    expect(() => other.send(PendingMessage(clientMsgId: 'old', conversationId: 'c', senderId: 'me', text: '旧账号', createdAt: time)), throwsStateError);
    await other.dispose();
  });

  test('仅真实可见时已读，且不超过连续游标', () async {
    await repo.refreshConversations();
    remote.server.addAll([message(1), message(2)]);
    await repo.sync('c');
    await repo.markRead('c', 9, stillVisible: () => false);
    expect(remote.reads, isEmpty);
    await repo.markRead('c', 9, stillVisible: () => true);
    expect(remote.reads, [2]);
  });
}

extension on Map<String, PendingMessage> {
  PendingMessage get singleValue => values.single;
}
