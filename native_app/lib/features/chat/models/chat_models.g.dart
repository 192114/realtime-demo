// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  messageId: wireId(json['messageId']),
  conversationId: wireId(json['conversationId']),
  senderId: wireId(json['senderId']),
  clientMsgId: json['clientMsgId'] as String,
  type: json['type'] as String? ?? messageTypeText,
  callId: wireCursor(json['callId']),
  seq: wireSeq(json['seq']),
  text: json['text'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'conversationId': instance.conversationId,
      'senderId': instance.senderId,
      'clientMsgId': instance.clientMsgId,
      'type': instance.type,
      'callId': instance.callId,
      'seq': seqToWire(instance.seq),
      'text': instance.text,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_ChatConversation _$ChatConversationFromJson(
  Map<String, dynamic> json,
) => _ChatConversation(
  conversationId: wireId(json['conversationId']),
  peerUserId: wireId(json['peerUserId']),
  peerNickname: json['peerNickname'] as String?,
  lastSeq: json['lastSeq'] == null ? 0 : wireSeq(json['lastSeq']),
  readSeq: json['readSeq'] == null ? 0 : wireSeq(json['readSeq']),
  peerReadSeq: json['peerReadSeq'] == null ? 0 : wireSeq(json['peerReadSeq']),
  unreadCount: json['unreadCount'] == null ? 0 : wireSeq(json['unreadCount']),
  lastMessage: wirePreview(json['lastMessage']),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ChatConversationToJson(_ChatConversation instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'peerUserId': instance.peerUserId,
      'peerNickname': instance.peerNickname,
      'lastSeq': seqToWire(instance.lastSeq),
      'readSeq': seqToWire(instance.readSeq),
      'peerReadSeq': seqToWire(instance.peerReadSeq),
      'unreadCount': instance.unreadCount,
      'lastMessage': instance.lastMessage,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_ChatMessagePage _$ChatMessagePageFromJson(Map<String, dynamic> json) =>
    _ChatMessagePage(
      items: (json['items'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['hasMore'] as bool,
      nextCursor: wireCursor(json['nextCursor']),
    );

Map<String, dynamic> _$ChatMessagePageToJson(_ChatMessagePage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'hasMore': instance.hasMore,
      'nextCursor': instance.nextCursor,
    };

_ChatConversationPage _$ChatConversationPageFromJson(
  Map<String, dynamic> json,
) => _ChatConversationPage(
  items: (json['items'] as List<dynamic>)
      .map((e) => ChatConversation.fromJson(e as Map<String, dynamic>))
      .toList(),
  hasMore: json['hasMore'] as bool,
  nextCursor: wireCursor(json['nextCursor']),
);

Map<String, dynamic> _$ChatConversationPageToJson(
  _ChatConversationPage instance,
) => <String, dynamic>{
  'items': instance.items,
  'hasMore': instance.hasMore,
  'nextCursor': instance.nextCursor,
};

_PendingMessage _$PendingMessageFromJson(Map<String, dynamic> json) =>
    _PendingMessage(
      clientMsgId: json['clientMsgId'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PendingMessageToJson(_PendingMessage instance) =>
    <String, dynamic>{
      'clientMsgId': instance.clientMsgId,
      'conversationId': instance.conversationId,
      'senderId': instance.senderId,
      'text': instance.text,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_MqttCredentials _$MqttCredentialsFromJson(Map<String, dynamic> json) =>
    _MqttCredentials(
      url: json['url'] as String,
      clientId: json['clientId'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      topics: (json['topics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      qos: (json['qos'] as num).toInt(),
    );

Map<String, dynamic> _$MqttCredentialsToJson(_MqttCredentials instance) =>
    <String, dynamic>{
      'url': instance.url,
      'clientId': instance.clientId,
      'username': instance.username,
      'password': instance.password,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'topics': instance.topics,
      'qos': instance.qos,
    };

_ChatEvent _$ChatEventFromJson(Map<String, dynamic> json) => _ChatEvent(
  eventId: wireId(json['eventId']),
  eventType: json['eventType'] as String,
  version: (json['version'] as num).toInt(),
  conversationId: wireId(json['conversationId']),
  messageId: wireCursor(json['messageId']),
  seq: json['seq'] == null ? 0 : wireSeq(json['seq']),
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  payload: json['payload'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ChatEventToJson(_ChatEvent instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'eventType': instance.eventType,
      'version': instance.version,
      'conversationId': instance.conversationId,
      'messageId': instance.messageId,
      'seq': seqToWire(instance.seq),
      'occurredAt': instance.occurredAt.toIso8601String(),
      'payload': instance.payload,
    };
