import '../models/chat_models.dart';

abstract interface class ChatRepository {
  String get userId;
  bool get isActive;
  Stream<void> get changes;
  Future<List<ChatConversation>> conversations();
  Future<List<ChatMessage>> messages(String id, {int limit = 50});
  Future<List<PendingMessage>> pending();
  Future<int> cursor(String id);
  Future<ChatConversation> direct(String peerUserId);
  Future<void> refreshConversations();
  Future<void> catchUp();
  Future<void> sync(String id);
  Future<bool> history(String id, {String? beforeSeq});
  PendingMessage draft(String id, String text);
  Future<void> send(PendingMessage message);
  Future<void> onEvent(ChatEvent event);
  Future<void> markRead(String id, int visibleSeq, {required bool Function() stillVisible});
  Future<void> dispose();
}

class ChatPersistenceException implements Exception {
  const ChatPersistenceException();
  @override
  String toString() => '本地保存失败，消息尚未发送；请保留页面并重试';
}
