import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_models.freezed.dart';
part 'chat_models.g.dart';

String wireId(Object? value) {
  if (value is String && value.isNotEmpty) return value;
  if (value is num) return value.toInt().toString();
  throw const FormatException('缺少有效 ID');
}

String? wireCursor(Object? value) => value == null ? null : wireId(value);
int wireSeq(Object? value) => value == null ? 0 : int.parse(wireId(value));
String seqToWire(int value) => value.toString();
String? wirePreview(Object? value) => value is Map ? value['text'] as String? : value as String?;

const String messageTypeText = 'TEXT';
const String messageTypeCall = 'CALL';

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    @JsonKey(fromJson: wireId) required String messageId,
    @JsonKey(fromJson: wireId) required String conversationId,
    @JsonKey(fromJson: wireId) required String senderId,
    required String clientMsgId,
    // 服务端旧版本可能不回传 type，本地旧缓存也依赖默认值兼容。
    @Default(messageTypeText) String type,
    @JsonKey(fromJson: wireCursor) String? callId,
    @JsonKey(fromJson: wireSeq, toJson: seqToWire) required int seq,
    required String text,
    required DateTime createdAt,
  }) = _ChatMessage;
  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}

@freezed
abstract class ChatConversation with _$ChatConversation {
  const factory ChatConversation({
    @JsonKey(fromJson: wireId) required String conversationId,
    @JsonKey(fromJson: wireId) required String peerUserId,
    String? peerNickname,
    @JsonKey(fromJson: wireSeq, toJson: seqToWire) @Default(0) int lastSeq,
    @JsonKey(fromJson: wireSeq, toJson: seqToWire) @Default(0) int readSeq,
    @JsonKey(fromJson: wireSeq, toJson: seqToWire) @Default(0) int peerReadSeq,
    @JsonKey(fromJson: wireSeq) @Default(0) int unreadCount,
    @JsonKey(fromJson: wirePreview) String? lastMessage,
    required DateTime updatedAt,
  }) = _ChatConversation;
  factory ChatConversation.fromJson(Map<String, dynamic> json) => _$ChatConversationFromJson(json);
}

@freezed
abstract class ChatMessagePage with _$ChatMessagePage {
  const factory ChatMessagePage({
    required List<ChatMessage> items,
    required bool hasMore,
    @JsonKey(fromJson: wireCursor) String? nextCursor,
  }) = _ChatMessagePage;
  factory ChatMessagePage.fromJson(Map<String, dynamic> json) => _$ChatMessagePageFromJson(json);
}

@freezed
abstract class ChatConversationPage with _$ChatConversationPage {
  const factory ChatConversationPage({
    required List<ChatConversation> items,
    required bool hasMore,
    @JsonKey(fromJson: wireCursor) String? nextCursor,
  }) = _ChatConversationPage;
  factory ChatConversationPage.fromJson(Map<String, dynamic> json) => _$ChatConversationPageFromJson(json);
}

@freezed
abstract class PendingMessage with _$PendingMessage {
  const factory PendingMessage({
    required String clientMsgId,
    required String conversationId,
    required String senderId,
    required String text,
    required DateTime createdAt,
  }) = _PendingMessage;
  factory PendingMessage.fromJson(Map<String, dynamic> json) => _$PendingMessageFromJson(json);
}

@freezed
abstract class MqttCredentials with _$MqttCredentials {
  const factory MqttCredentials({
    required String url,
    required String clientId,
    required String username,
    required String password,
    required DateTime expiresAt,
    required List<String> topics,
    required int qos,
  }) = _MqttCredentials;
  factory MqttCredentials.fromJson(Map<String, dynamic> json) => _$MqttCredentialsFromJson(json);
}

@freezed
abstract class ChatEvent with _$ChatEvent {
  const factory ChatEvent({
    @JsonKey(fromJson: wireId) required String eventId,
    required String eventType,
    required int version,
    @JsonKey(fromJson: wireId) required String conversationId,
    @JsonKey(fromJson: wireCursor) String? messageId,
    @JsonKey(fromJson: wireSeq, toJson: seqToWire) @Default(0) int seq,
    required DateTime occurredAt,
    required Map<String, dynamic> payload,
  }) = _ChatEvent;
  factory ChatEvent.fromJson(Map<String, dynamic> json) => _$ChatEventFromJson(json);
}
