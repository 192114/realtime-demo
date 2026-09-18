// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CallSession _$CallSessionFromJson(Map<String, dynamic> json) => _CallSession(
  callId: json['callId'] as String,
  conversationId: wireId(json['conversationId']),
  callerId: wireId(json['callerId']),
  callerNickname: json['callerNickname'] as String?,
  calleeId: wireId(json['calleeId']),
  calleeNickname: json['calleeNickname'] as String?,
  status: wireSeq(json['status']),
  mediaType: json['mediaType'] as String,
  endReason: json['endReason'] as String?,
  durationSeconds: _wireOptionalInt(json['durationSeconds']),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  acceptedAt: json['acceptedAt'] == null
      ? null
      : DateTime.parse(json['acceptedAt'] as String),
  endedAt: json['endedAt'] == null
      ? null
      : DateTime.parse(json['endedAt'] as String),
  roomName: json['roomName'] as String?,
  liveKitUrl: json['liveKitUrl'] as String?,
  token: json['token'] as String?,
);

Map<String, dynamic> _$CallSessionToJson(_CallSession instance) =>
    <String, dynamic>{
      'callId': instance.callId,
      'conversationId': instance.conversationId,
      'callerId': instance.callerId,
      'callerNickname': instance.callerNickname,
      'calleeId': instance.calleeId,
      'calleeNickname': instance.calleeNickname,
      'status': seqToWire(instance.status),
      'mediaType': instance.mediaType,
      'endReason': instance.endReason,
      'durationSeconds': instance.durationSeconds,
      'createdAt': instance.createdAt?.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'roomName': instance.roomName,
      'liveKitUrl': instance.liveKitUrl,
      'token': instance.token,
    };

_CallRecordPage _$CallRecordPageFromJson(Map<String, dynamic> json) =>
    _CallRecordPage(
      items: (json['items'] as List<dynamic>)
          .map((e) => CallSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['hasMore'] as bool,
      nextCursor: wireCursor(json['nextCursor']),
    );

Map<String, dynamic> _$CallRecordPageToJson(_CallRecordPage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'hasMore': instance.hasMore,
      'nextCursor': instance.nextCursor,
    };

_CallEvent _$CallEventFromJson(Map<String, dynamic> json) => _CallEvent(
  eventId: json['eventId'] as String,
  eventType: json['eventType'] as String,
  version: (json['version'] as num).toInt(),
  callId: json['callId'] as String,
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  payload: json['payload'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CallEventToJson(_CallEvent instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'eventType': instance.eventType,
      'version': instance.version,
      'callId': instance.callId,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'payload': instance.payload,
    };
