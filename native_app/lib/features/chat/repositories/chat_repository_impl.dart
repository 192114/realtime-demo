import 'dart:async';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../datasources/chat_local_datasource.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_models.dart';
import 'chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required this.userId, required this.local, required this.remote,
    required this._sessionActive});
  @override
  final String userId;
  final ChatLocalDataSource local;
  final ChatRemoteDataSource remote;
  final bool Function() _sessionActive;
  final _changes = StreamController<void>.broadcast();
  final _syncing = <String, Future<void>>{};
  final _syncAgain = <String>{};
  final _sending = <String, Future<void>>{};
  Future<void>? _refreshing;
  bool _closed = false;
  @override
  bool get isActive => !_closed && _sessionActive();
  @override
  Stream<void> get changes => _changes.stream;
  void _check() { if (!isActive) throw StateError('账号会话已结束'); }
  void _notify() { if (isActive) _changes.add(null); }
  @override
  Future<List<ChatConversation>> conversations() { _check(); return local.conversations(); }
  @override
  Future<List<ChatMessage>> messages(String id, {int limit = 50}) { _check(); return local.messages(id, limit: limit); }
  @override
  Future<List<PendingMessage>> pending() { _check(); return local.pending(); }
  @override
  Future<int> cursor(String id) { _check(); return local.cursor(id); }

  @override
  Future<ChatConversation> direct(String peerUserId) async {
    _check();
    if (peerUserId.trim().isEmpty || peerUserId == userId) throw ArgumentError('请输入其他用户的 ID');
    final item = await remote.direct(peerUserId.trim());
    _check();
    await local.saveConversations([item]);
    _notify();
    return item;
  }

  @override
  Future<void> refreshConversations() {
    _check();
    return _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
  }
  Future<void> _refresh() async {
    String? before;
    final visited = <String>{};
    do {
      final page = await remote.conversations(beforeId: before);
      _check();
      await local.saveConversations(page.items);
      _notify();
      if (!page.hasMore) return;
      before = page.nextCursor;
      if (before == null || !visited.add(before) || page.items.isEmpty) {
        throw const FormatException('会话分页游标无效');
      }
    } while (isActive);
  }

  @override
  Future<void> catchUp() async {
    await refreshConversations();
    final items = await conversations();
    Object? failure;
    for (final item in items) {
      _check();
      try { await sync(item.conversationId); } catch (error) { failure = error; }
    }
    if (failure != null) throw failure;
  }

  @override
  Future<void> sync(String id) {
    _check();
    final running = _syncing[id];
    if (running != null) { _syncAgain.add(id); return running; }
    final future = _syncLoop(id).whenComplete(() { _syncing.remove(id); });
    _syncing[id] = future;
    return future;
  }
  Future<void> _syncLoop(String id) async {
    do {
      _syncAgain.remove(id);
      var after = await local.cursor(id);
      while (isActive) {
        final page = await remote.sync(id, after);
        _check();
        final next = contiguousCursor(id, after, page.items);
        if (page.hasMore && (next == after || page.nextCursor != '$next')) {
          throw const FormatException('增量分页游标无效');
        }
        await local.saveMessages(id, page.items, syncAfter: after);
        _notify();
        after = next;
        if (!page.hasMore) break;
      }
    } while (isActive && _syncAgain.remove(id));
  }

  @override
  Future<bool> history(String id, {String? beforeSeq}) async {
    _check();
    final page = await remote.history(id, beforeSeq: beforeSeq);
    _check();
    await local.saveMessages(id, page.items);
    _notify();
    return page.hasMore;
  }

  @override
  PendingMessage draft(String id, String text) {
    _check();
    if (text.trim().isEmpty) throw ArgumentError('请输入消息');
    return PendingMessage(clientMsgId: const Uuid().v4(), conversationId: id,
      senderId: userId, text: text.trim(), createdAt: DateTime.now().toUtc());
  }
  @override
  Future<void> send(PendingMessage message) {
    _check();
    if (message.senderId != userId) throw StateError('账号不匹配');
    return _sending[message.clientMsgId] ??= _send(message).whenComplete(() { _sending.remove(message.clientMsgId); });
  }
  Future<void> _send(PendingMessage message) async {
    try { await local.savePending(message); } catch (_) { throw const ChatPersistenceException(); }
    _check();
    _notify();
    final saved = await local.pending();
    _check();
    if (!saved.any((m) => m.clientMsgId == message.clientMsgId)) return;
    final confirmed = await remote.send(message);
    _check();
    if (confirmed.senderId != userId || confirmed.clientMsgId != message.clientMsgId ||
        confirmed.conversationId != message.conversationId) {
      throw const FormatException('发送确认不匹配');
    }
    await local.saveMessages(message.conversationId, [confirmed]);
    _notify();
    // 确认仅归并消息，缺口由 sync 补齐，不能用确认的高 seq 跳游标。
    try { await sync(message.conversationId); } catch (_) { /* 保留已确认状态，稍后补拉。 */ }
  }

  @override
  Future<void> onEvent(ChatEvent event) async {
    _check();
    if (event.version != 1) return;
    if (event.eventType == 'message.created') {
      // payload 不完整时依赖 HTTP 补拉；MQTT 只是提示，不是游标来源。
      ChatMessage? message;
      try { message = ChatMessage.fromJson(event.payload); } catch (_) { /* 兼容提示型事件。 */ }
      if (message != null && message.conversationId == event.conversationId &&
          message.messageId == event.messageId && message.seq == event.seq) {
        await local.saveMessages(event.conversationId, [message]);
        _notify();
      }
      await sync(event.conversationId);
      await refreshConversations();
    } else if (event.eventType == 'conversation.read') {
      // 使用服务端会话摘要确认 readSeq/peerReadSeq，不猜测 payload 的参与者。
      await refreshConversations();
    }
  }

  @override
  Future<void> markRead(String id, int visibleSeq, {required bool Function() stillVisible}) async {
    _check();
    final synced = await local.cursor(id);
    final target = min(synced, visibleSeq);
    final items = await conversations();
    final item = items.where((c) => c.conversationId == id).firstOrNull;
    if (!isActive || !stillVisible() || target <= (item?.readSeq ?? 0)) return;
    final confirmed = await remote.read(id, target);
    _check();
    await local.saveRead(id, confirmed);
    _notify();
  }

  @override
  Future<void> dispose() async {
    if (_closed) return;
    _closed = true;
    remote.cancel();
    await _changes.close();
    await local.close();
  }
}
