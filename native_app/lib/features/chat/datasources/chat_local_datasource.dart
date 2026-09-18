import 'dart:convert';
import 'dart:math';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/chat_models.dart';

abstract interface class ChatLocalDataSource {
  Future<List<ChatConversation>> conversations();
  Future<List<ChatMessage>> messages(String id, {int limit = 50});
  Future<List<PendingMessage>> pending();
  Future<int> cursor(String id);
  Future<void> savePending(PendingMessage message);
  Future<void> saveConversations(List<ChatConversation> items);
  Future<void> saveMessages(String id, List<ChatMessage> items, {int? syncAfter});
  Future<void> saveRead(String id, int seq);
  Future<void> close();
}

/// 仅增量响应能推进游标，且必须逐条连续。推送/确认/历史不调用此逻辑。
int contiguousCursor(String id, int after, List<ChatMessage> items) {
  var next = after;
  for (final item in items) {
    if (item.conversationId != id || item.seq != next + 1) {
      throw const FormatException('增量消息不连续，请重试同步');
    }
    next = item.seq;
  }
  return next;
}

class SqliteChatLocalDataSource implements ChatLocalDataSource {
  SqliteChatLocalDataSource._(this._db, this.userId, this.isActive);
  final Database _db;
  final String userId;
  final bool Function() isActive;
  bool _closed = false;

  static String databaseName(String userId) => 'chat_v1_${base64Url.encode(utf8.encode(userId))}.db';

  static Future<SqliteChatLocalDataSource> open(String userId, bool Function() isActive) async {
    final db = await openDatabase(path.join(await getDatabasesPath(), databaseName(userId)),
      version: 1, singleInstance: false,
      onConfigure: (db) async { await db.execute('PRAGMA synchronous = FULL'); },
      onCreate: (db, _) async {
        await db.execute('CREATE TABLE conversations (id TEXT PRIMARY KEY, json TEXT NOT NULL)');
        await db.execute('CREATE TABLE messages (id TEXT PRIMARY KEY, conversation TEXT NOT NULL, sender TEXT NOT NULL, client TEXT NOT NULL, seq INTEGER NOT NULL, json TEXT NOT NULL, UNIQUE(conversation, seq), UNIQUE(sender, client))');
        await db.execute('CREATE INDEX message_order ON messages(conversation, seq)');
        await db.execute('CREATE TABLE pending (client TEXT PRIMARY KEY, sender TEXT NOT NULL, json TEXT NOT NULL)');
        await db.execute('CREATE TABLE cursors (conversation TEXT PRIMARY KEY, seq INTEGER NOT NULL)');
      },
    );
    return SqliteChatLocalDataSource._(db, userId, isActive);
  }

  void _check() { if (_closed || !isActive()) throw StateError('账号会话已结束'); }
  Map<String, dynamic> _json(Map<String, Object?> row) => jsonDecode(row['json'] as String) as Map<String, dynamic>;
  Future<T> _transaction<T>(Future<T> Function(Transaction) work) async {
    _check();
    return _db.transaction((tx) async {
      _check();
      final value = await work(tx);
      _check();
      return value;
    });
  }

  @override
  Future<List<ChatConversation>> conversations() async {
    _check();
    final rows = await _db.query('conversations');
    _check();
    return rows.map((r) => ChatConversation.fromJson(_json(r))).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
  @override
  Future<List<ChatMessage>> messages(String id, {int limit = 50}) async {
    _check();
    final rows = await _db.query('messages', where: 'conversation = ?', whereArgs: [id], orderBy: 'seq DESC', limit: limit);
    _check();
    return rows.map((r) => ChatMessage.fromJson(_json(r))).toList();
  }
  @override
  Future<List<PendingMessage>> pending() async {
    _check();
    final rows = await _db.query('pending', where: 'sender = ?', whereArgs: [userId]);
    _check();
    return rows.map((r) => PendingMessage.fromJson(_json(r))).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }
  @override
  Future<int> cursor(String id) async {
    _check();
    final rows = await _db.query('cursors', where: 'conversation = ?', whereArgs: [id]);
    _check();
    return rows.isEmpty ? 0 : rows.single['seq'] as int;
  }
  @override
  Future<void> savePending(PendingMessage message) => _transaction((tx) async {
    if (message.senderId != userId) throw StateError('账号不匹配');
    // 已确认的 UUID 不会重新插入 pending。
    final sent = await tx.query('messages', where: 'sender = ? AND client = ?', whereArgs: [userId, message.clientMsgId]);
    if (sent.isNotEmpty) return;
    await tx.insert('pending', {'client': message.clientMsgId, 'sender': userId, 'json': jsonEncode(message.toJson())}, conflictAlgorithm: ConflictAlgorithm.ignore);
  });

  Future<ChatConversation?> _conversation(Transaction tx, String id) async {
    final rows = await tx.query('conversations', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : ChatConversation.fromJson(_json(rows.single));
  }
  Future<void> _putConversation(Transaction tx, ChatConversation item) => tx.insert('conversations',
    {'id': item.conversationId, 'json': jsonEncode(item.toJson())}, conflictAlgorithm: ConflictAlgorithm.replace);

  @override
  Future<void> saveConversations(List<ChatConversation> items) => _transaction((tx) async {
    for (var item in items) {
      final old = await _conversation(tx, item.conversationId);
      if (old != null) {
        final source = old.lastSeq > item.lastSeq ? old : item;
        item = source.copyWith(peerNickname: item.peerNickname,
          readSeq: max(old.readSeq, item.readSeq), peerReadSeq: max(old.peerReadSeq, item.peerReadSeq),
          unreadCount: max(old.readSeq, item.readSeq) >= source.lastSeq ? 0 : source.unreadCount);
      }
      await _putConversation(tx, item);
    }
  });

  @override
  Future<void> saveMessages(String id, List<ChatMessage> items, {int? syncAfter}) => _transaction((tx) async {
    int? next;
    if (syncAfter != null) {
      final rows = await tx.query('cursors', where: 'conversation = ?', whereArgs: [id]);
      final current = rows.isEmpty ? 0 : rows.single['seq'] as int;
      if (current != syncAfter) throw StateError('增量游标已改变');
      next = contiguousCursor(id, current, items);
    }
    var conversation = await _conversation(tx, id);
    for (final item in items) {
      if (item.conversationId != id || item.seq <= 0) throw const FormatException('消息会话不匹配');
      final existing = await tx.query('messages', where: 'id = ?', whereArgs: [item.messageId]);
      if (existing.isEmpty) {
        // 唯一键冲突会回滚整批消息及游标，不能静默丢失消息。
        await tx.insert('messages', {'id': item.messageId, 'conversation': id, 'sender': item.senderId,
          'client': item.clientMsgId, 'seq': item.seq, 'json': jsonEncode(item.toJson())});
      }
      await tx.delete('pending', where: 'sender = ? AND client = ?', whereArgs: [item.senderId, item.clientMsgId]);
      if (conversation != null && item.seq > conversation.lastSeq) {
        conversation = conversation.copyWith(lastSeq: item.seq, lastMessage: item.text, updatedAt: item.createdAt,
          unreadCount: conversation.unreadCount + (item.senderId != userId && item.seq > conversation.readSeq ? 1 : 0));
      }
    }
    if (conversation != null) await _putConversation(tx, conversation);
    if (next != null) {
      await tx.insert('cursors', {'conversation': id, 'seq': next}, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  });

  @override
  Future<void> saveRead(String id, int seq) => _transaction((tx) async {
    final item = await _conversation(tx, id);
    if (item != null) {
      await _putConversation(tx, item.copyWith(readSeq: max(item.readSeq, seq),
        unreadCount: seq >= item.lastSeq ? 0 : item.unreadCount));
    }
  });
  @override
  Future<void> close() async { _closed = true; await _db.close(); }
}
