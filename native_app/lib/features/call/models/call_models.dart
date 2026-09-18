import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:native_app/features/chat/models/chat_models.dart'
    show wireId, wireCursor, wireSeq, seqToWire;

part 'call_models.freezed.dart';
part 'call_models.g.dart';

int? _wireOptionalInt(Object? value) => value == null ? null : wireSeq(value);

/// 服务端通话状态：0 呼叫中、1 通话中、2 已拒绝、3 已取消、4 已超时、5 已结束。
enum CallStatus {
  calling(0),
  inCall(1),
  rejected(2),
  cancelled(3),
  timeout(4),
  ended(5);

  const CallStatus(this.value);
  final int value;

  static CallStatus? fromValue(int? value) =>
      CallStatus.values.where((status) => status.value == value).firstOrNull;

  bool get isTerminal => this == rejected || this == cancelled || this == timeout || this == ended;
}

@freezed
abstract class CallSession with _$CallSession {
  const factory CallSession({
    required String callId,
    @JsonKey(fromJson: wireId) required String conversationId,
    @JsonKey(fromJson: wireId) required String callerId,
    String? callerNickname,
    @JsonKey(fromJson: wireId) required String calleeId,
    String? calleeNickname,
    @JsonKey(fromJson: wireSeq, toJson: seqToWire) required int status,
    required String mediaType,
    String? endReason,
    @JsonKey(fromJson: _wireOptionalInt) int? durationSeconds,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? endedAt,
    // 以下三个字段只经 HTTPS 响应到达参与者，事件负载中恒为 null。
    String? roomName,
    String? liveKitUrl,
    String? token,
  }) = _CallSession;
  factory CallSession.fromJson(Map<String, dynamic> json) => _$CallSessionFromJson(json);

  const CallSession._();

  CallStatus? get callStatus => CallStatus.fromValue(status);
  bool get isVideo => mediaType == 'VIDEO';
}

@freezed
abstract class CallRecordPage with _$CallRecordPage {
  const factory CallRecordPage({
    required List<CallSession> items,
    required bool hasMore,
    @JsonKey(fromJson: wireCursor) String? nextCursor,
  }) = _CallRecordPage;
  factory CallRecordPage.fromJson(Map<String, dynamic> json) => _$CallRecordPageFromJson(json);
}

/// MQTT chat/user/{id}/calls 主题上的通话信令事件。
@freezed
abstract class CallEvent with _$CallEvent {
  const factory CallEvent({
    required String eventId,
    required String eventType,
    required int version,
    required String callId,
    required DateTime occurredAt,
    required Map<String, dynamic> payload,
  }) = _CallEvent;
  factory CallEvent.fromJson(Map<String, dynamic> json) => _$CallEventFromJson(json);
}
