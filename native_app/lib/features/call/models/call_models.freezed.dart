// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CallSession {

 String get callId;@JsonKey(fromJson: wireId) String get conversationId;@JsonKey(fromJson: wireId) String get callerId; String? get callerNickname;@JsonKey(fromJson: wireId) String get calleeId; String? get calleeNickname;@JsonKey(fromJson: wireSeq, toJson: seqToWire) int get status; String get mediaType; String? get endReason;@JsonKey(fromJson: _wireOptionalInt) int? get durationSeconds; DateTime? get createdAt; DateTime? get acceptedAt; DateTime? get endedAt;// 以下三个字段只经 HTTPS 响应到达参与者，事件负载中恒为 null。
 String? get roomName; String? get liveKitUrl; String? get token;
/// Create a copy of CallSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallSessionCopyWith<CallSession> get copyWith => _$CallSessionCopyWithImpl<CallSession>(this as CallSession, _$identity);

  /// Serializes this CallSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallSession&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.callerId, callerId) || other.callerId == callerId)&&(identical(other.callerNickname, callerNickname) || other.callerNickname == callerNickname)&&(identical(other.calleeId, calleeId) || other.calleeId == calleeId)&&(identical(other.calleeNickname, calleeNickname) || other.calleeNickname == calleeNickname)&&(identical(other.status, status) || other.status == status)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.endReason, endReason) || other.endReason == endReason)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.liveKitUrl, liveKitUrl) || other.liveKitUrl == liveKitUrl)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,callId,conversationId,callerId,callerNickname,calleeId,calleeNickname,status,mediaType,endReason,durationSeconds,createdAt,acceptedAt,endedAt,roomName,liveKitUrl,token);

@override
String toString() {
  return 'CallSession(callId: $callId, conversationId: $conversationId, callerId: $callerId, callerNickname: $callerNickname, calleeId: $calleeId, calleeNickname: $calleeNickname, status: $status, mediaType: $mediaType, endReason: $endReason, durationSeconds: $durationSeconds, createdAt: $createdAt, acceptedAt: $acceptedAt, endedAt: $endedAt, roomName: $roomName, liveKitUrl: $liveKitUrl, token: $token)';
}


}

/// @nodoc
abstract mixin class $CallSessionCopyWith<$Res>  {
  factory $CallSessionCopyWith(CallSession value, $Res Function(CallSession) _then) = _$CallSessionCopyWithImpl;
@useResult
$Res call({
 String callId,@JsonKey(fromJson: wireId) String conversationId,@JsonKey(fromJson: wireId) String callerId, String? callerNickname,@JsonKey(fromJson: wireId) String calleeId, String? calleeNickname,@JsonKey(fromJson: wireSeq, toJson: seqToWire) int status, String mediaType, String? endReason,@JsonKey(fromJson: _wireOptionalInt) int? durationSeconds, DateTime? createdAt, DateTime? acceptedAt, DateTime? endedAt, String? roomName, String? liveKitUrl, String? token
});




}
/// @nodoc
class _$CallSessionCopyWithImpl<$Res>
    implements $CallSessionCopyWith<$Res> {
  _$CallSessionCopyWithImpl(this._self, this._then);

  final CallSession _self;
  final $Res Function(CallSession) _then;

/// Create a copy of CallSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? callId = null,Object? conversationId = null,Object? callerId = null,Object? callerNickname = freezed,Object? calleeId = null,Object? calleeNickname = freezed,Object? status = null,Object? mediaType = null,Object? endReason = freezed,Object? durationSeconds = freezed,Object? createdAt = freezed,Object? acceptedAt = freezed,Object? endedAt = freezed,Object? roomName = freezed,Object? liveKitUrl = freezed,Object? token = freezed,}) {
  return _then(_self.copyWith(
callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,callerId: null == callerId ? _self.callerId : callerId // ignore: cast_nullable_to_non_nullable
as String,callerNickname: freezed == callerNickname ? _self.callerNickname : callerNickname // ignore: cast_nullable_to_non_nullable
as String?,calleeId: null == calleeId ? _self.calleeId : calleeId // ignore: cast_nullable_to_non_nullable
as String,calleeNickname: freezed == calleeNickname ? _self.calleeNickname : calleeNickname // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,endReason: freezed == endReason ? _self.endReason : endReason // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,roomName: freezed == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String?,liveKitUrl: freezed == liveKitUrl ? _self.liveKitUrl : liveKitUrl // ignore: cast_nullable_to_non_nullable
as String?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CallSession].
extension CallSessionPatterns on CallSession {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallSession() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallSession value)  $default,){
final _that = this;
switch (_that) {
case _CallSession():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallSession value)?  $default,){
final _that = this;
switch (_that) {
case _CallSession() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String callId, @JsonKey(fromJson: wireId)  String conversationId, @JsonKey(fromJson: wireId)  String callerId,  String? callerNickname, @JsonKey(fromJson: wireId)  String calleeId,  String? calleeNickname, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int status,  String mediaType,  String? endReason, @JsonKey(fromJson: _wireOptionalInt)  int? durationSeconds,  DateTime? createdAt,  DateTime? acceptedAt,  DateTime? endedAt,  String? roomName,  String? liveKitUrl,  String? token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallSession() when $default != null:
return $default(_that.callId,_that.conversationId,_that.callerId,_that.callerNickname,_that.calleeId,_that.calleeNickname,_that.status,_that.mediaType,_that.endReason,_that.durationSeconds,_that.createdAt,_that.acceptedAt,_that.endedAt,_that.roomName,_that.liveKitUrl,_that.token);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String callId, @JsonKey(fromJson: wireId)  String conversationId, @JsonKey(fromJson: wireId)  String callerId,  String? callerNickname, @JsonKey(fromJson: wireId)  String calleeId,  String? calleeNickname, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int status,  String mediaType,  String? endReason, @JsonKey(fromJson: _wireOptionalInt)  int? durationSeconds,  DateTime? createdAt,  DateTime? acceptedAt,  DateTime? endedAt,  String? roomName,  String? liveKitUrl,  String? token)  $default,) {final _that = this;
switch (_that) {
case _CallSession():
return $default(_that.callId,_that.conversationId,_that.callerId,_that.callerNickname,_that.calleeId,_that.calleeNickname,_that.status,_that.mediaType,_that.endReason,_that.durationSeconds,_that.createdAt,_that.acceptedAt,_that.endedAt,_that.roomName,_that.liveKitUrl,_that.token);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String callId, @JsonKey(fromJson: wireId)  String conversationId, @JsonKey(fromJson: wireId)  String callerId,  String? callerNickname, @JsonKey(fromJson: wireId)  String calleeId,  String? calleeNickname, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int status,  String mediaType,  String? endReason, @JsonKey(fromJson: _wireOptionalInt)  int? durationSeconds,  DateTime? createdAt,  DateTime? acceptedAt,  DateTime? endedAt,  String? roomName,  String? liveKitUrl,  String? token)?  $default,) {final _that = this;
switch (_that) {
case _CallSession() when $default != null:
return $default(_that.callId,_that.conversationId,_that.callerId,_that.callerNickname,_that.calleeId,_that.calleeNickname,_that.status,_that.mediaType,_that.endReason,_that.durationSeconds,_that.createdAt,_that.acceptedAt,_that.endedAt,_that.roomName,_that.liveKitUrl,_that.token);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CallSession extends CallSession {
  const _CallSession({required this.callId, @JsonKey(fromJson: wireId) required this.conversationId, @JsonKey(fromJson: wireId) required this.callerId, this.callerNickname, @JsonKey(fromJson: wireId) required this.calleeId, this.calleeNickname, @JsonKey(fromJson: wireSeq, toJson: seqToWire) required this.status, required this.mediaType, this.endReason, @JsonKey(fromJson: _wireOptionalInt) this.durationSeconds, this.createdAt, this.acceptedAt, this.endedAt, this.roomName, this.liveKitUrl, this.token}): super._();
  factory _CallSession.fromJson(Map<String, dynamic> json) => _$CallSessionFromJson(json);

@override final  String callId;
@override@JsonKey(fromJson: wireId) final  String conversationId;
@override@JsonKey(fromJson: wireId) final  String callerId;
@override final  String? callerNickname;
@override@JsonKey(fromJson: wireId) final  String calleeId;
@override final  String? calleeNickname;
@override@JsonKey(fromJson: wireSeq, toJson: seqToWire) final  int status;
@override final  String mediaType;
@override final  String? endReason;
@override@JsonKey(fromJson: _wireOptionalInt) final  int? durationSeconds;
@override final  DateTime? createdAt;
@override final  DateTime? acceptedAt;
@override final  DateTime? endedAt;
// 以下三个字段只经 HTTPS 响应到达参与者，事件负载中恒为 null。
@override final  String? roomName;
@override final  String? liveKitUrl;
@override final  String? token;

/// Create a copy of CallSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallSessionCopyWith<_CallSession> get copyWith => __$CallSessionCopyWithImpl<_CallSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallSession&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.callerId, callerId) || other.callerId == callerId)&&(identical(other.callerNickname, callerNickname) || other.callerNickname == callerNickname)&&(identical(other.calleeId, calleeId) || other.calleeId == calleeId)&&(identical(other.calleeNickname, calleeNickname) || other.calleeNickname == calleeNickname)&&(identical(other.status, status) || other.status == status)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.endReason, endReason) || other.endReason == endReason)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.liveKitUrl, liveKitUrl) || other.liveKitUrl == liveKitUrl)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,callId,conversationId,callerId,callerNickname,calleeId,calleeNickname,status,mediaType,endReason,durationSeconds,createdAt,acceptedAt,endedAt,roomName,liveKitUrl,token);

@override
String toString() {
  return 'CallSession(callId: $callId, conversationId: $conversationId, callerId: $callerId, callerNickname: $callerNickname, calleeId: $calleeId, calleeNickname: $calleeNickname, status: $status, mediaType: $mediaType, endReason: $endReason, durationSeconds: $durationSeconds, createdAt: $createdAt, acceptedAt: $acceptedAt, endedAt: $endedAt, roomName: $roomName, liveKitUrl: $liveKitUrl, token: $token)';
}


}

/// @nodoc
abstract mixin class _$CallSessionCopyWith<$Res> implements $CallSessionCopyWith<$Res> {
  factory _$CallSessionCopyWith(_CallSession value, $Res Function(_CallSession) _then) = __$CallSessionCopyWithImpl;
@override @useResult
$Res call({
 String callId,@JsonKey(fromJson: wireId) String conversationId,@JsonKey(fromJson: wireId) String callerId, String? callerNickname,@JsonKey(fromJson: wireId) String calleeId, String? calleeNickname,@JsonKey(fromJson: wireSeq, toJson: seqToWire) int status, String mediaType, String? endReason,@JsonKey(fromJson: _wireOptionalInt) int? durationSeconds, DateTime? createdAt, DateTime? acceptedAt, DateTime? endedAt, String? roomName, String? liveKitUrl, String? token
});




}
/// @nodoc
class __$CallSessionCopyWithImpl<$Res>
    implements _$CallSessionCopyWith<$Res> {
  __$CallSessionCopyWithImpl(this._self, this._then);

  final _CallSession _self;
  final $Res Function(_CallSession) _then;

/// Create a copy of CallSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? callId = null,Object? conversationId = null,Object? callerId = null,Object? callerNickname = freezed,Object? calleeId = null,Object? calleeNickname = freezed,Object? status = null,Object? mediaType = null,Object? endReason = freezed,Object? durationSeconds = freezed,Object? createdAt = freezed,Object? acceptedAt = freezed,Object? endedAt = freezed,Object? roomName = freezed,Object? liveKitUrl = freezed,Object? token = freezed,}) {
  return _then(_CallSession(
callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,callerId: null == callerId ? _self.callerId : callerId // ignore: cast_nullable_to_non_nullable
as String,callerNickname: freezed == callerNickname ? _self.callerNickname : callerNickname // ignore: cast_nullable_to_non_nullable
as String?,calleeId: null == calleeId ? _self.calleeId : calleeId // ignore: cast_nullable_to_non_nullable
as String,calleeNickname: freezed == calleeNickname ? _self.calleeNickname : calleeNickname // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,endReason: freezed == endReason ? _self.endReason : endReason // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,roomName: freezed == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String?,liveKitUrl: freezed == liveKitUrl ? _self.liveKitUrl : liveKitUrl // ignore: cast_nullable_to_non_nullable
as String?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CallRecordPage {

 List<CallSession> get items; bool get hasMore;@JsonKey(fromJson: wireCursor) String? get nextCursor;
/// Create a copy of CallRecordPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallRecordPageCopyWith<CallRecordPage> get copyWith => _$CallRecordPageCopyWithImpl<CallRecordPage>(this as CallRecordPage, _$identity);

  /// Serializes this CallRecordPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallRecordPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),hasMore,nextCursor);

@override
String toString() {
  return 'CallRecordPage(items: $items, hasMore: $hasMore, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $CallRecordPageCopyWith<$Res>  {
  factory $CallRecordPageCopyWith(CallRecordPage value, $Res Function(CallRecordPage) _then) = _$CallRecordPageCopyWithImpl;
@useResult
$Res call({
 List<CallSession> items, bool hasMore,@JsonKey(fromJson: wireCursor) String? nextCursor
});




}
/// @nodoc
class _$CallRecordPageCopyWithImpl<$Res>
    implements $CallRecordPageCopyWith<$Res> {
  _$CallRecordPageCopyWithImpl(this._self, this._then);

  final CallRecordPage _self;
  final $Res Function(CallRecordPage) _then;

/// Create a copy of CallRecordPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? hasMore = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CallSession>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CallRecordPage].
extension CallRecordPagePatterns on CallRecordPage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallRecordPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallRecordPage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallRecordPage value)  $default,){
final _that = this;
switch (_that) {
case _CallRecordPage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallRecordPage value)?  $default,){
final _that = this;
switch (_that) {
case _CallRecordPage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CallSession> items,  bool hasMore, @JsonKey(fromJson: wireCursor)  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallRecordPage() when $default != null:
return $default(_that.items,_that.hasMore,_that.nextCursor);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CallSession> items,  bool hasMore, @JsonKey(fromJson: wireCursor)  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _CallRecordPage():
return $default(_that.items,_that.hasMore,_that.nextCursor);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CallSession> items,  bool hasMore, @JsonKey(fromJson: wireCursor)  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _CallRecordPage() when $default != null:
return $default(_that.items,_that.hasMore,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CallRecordPage implements CallRecordPage {
  const _CallRecordPage({required final  List<CallSession> items, required this.hasMore, @JsonKey(fromJson: wireCursor) this.nextCursor}): _items = items;
  factory _CallRecordPage.fromJson(Map<String, dynamic> json) => _$CallRecordPageFromJson(json);

 final  List<CallSession> _items;
@override List<CallSession> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  bool hasMore;
@override@JsonKey(fromJson: wireCursor) final  String? nextCursor;

/// Create a copy of CallRecordPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallRecordPageCopyWith<_CallRecordPage> get copyWith => __$CallRecordPageCopyWithImpl<_CallRecordPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallRecordPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallRecordPage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),hasMore,nextCursor);

@override
String toString() {
  return 'CallRecordPage(items: $items, hasMore: $hasMore, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$CallRecordPageCopyWith<$Res> implements $CallRecordPageCopyWith<$Res> {
  factory _$CallRecordPageCopyWith(_CallRecordPage value, $Res Function(_CallRecordPage) _then) = __$CallRecordPageCopyWithImpl;
@override @useResult
$Res call({
 List<CallSession> items, bool hasMore,@JsonKey(fromJson: wireCursor) String? nextCursor
});




}
/// @nodoc
class __$CallRecordPageCopyWithImpl<$Res>
    implements _$CallRecordPageCopyWith<$Res> {
  __$CallRecordPageCopyWithImpl(this._self, this._then);

  final _CallRecordPage _self;
  final $Res Function(_CallRecordPage) _then;

/// Create a copy of CallRecordPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? hasMore = null,Object? nextCursor = freezed,}) {
  return _then(_CallRecordPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CallSession>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CallEvent {

 String get eventId; String get eventType; int get version; String get callId; DateTime get occurredAt; Map<String, dynamic> get payload;
/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallEventCopyWith<CallEvent> get copyWith => _$CallEventCopyWithImpl<CallEvent>(this as CallEvent, _$identity);

  /// Serializes this CallEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.version, version) || other.version == version)&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&const DeepCollectionEquality().equals(other.payload, payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,eventType,version,callId,occurredAt,const DeepCollectionEquality().hash(payload));

@override
String toString() {
  return 'CallEvent(eventId: $eventId, eventType: $eventType, version: $version, callId: $callId, occurredAt: $occurredAt, payload: $payload)';
}


}

/// @nodoc
abstract mixin class $CallEventCopyWith<$Res>  {
  factory $CallEventCopyWith(CallEvent value, $Res Function(CallEvent) _then) = _$CallEventCopyWithImpl;
@useResult
$Res call({
 String eventId, String eventType, int version, String callId, DateTime occurredAt, Map<String, dynamic> payload
});




}
/// @nodoc
class _$CallEventCopyWithImpl<$Res>
    implements $CallEventCopyWith<$Res> {
  _$CallEventCopyWithImpl(this._self, this._then);

  final CallEvent _self;
  final $Res Function(CallEvent) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? eventType = null,Object? version = null,Object? callId = null,Object? occurredAt = null,Object? payload = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [CallEvent].
extension CallEventPatterns on CallEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallEvent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallEvent value)  $default,){
final _that = this;
switch (_that) {
case _CallEvent():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallEvent value)?  $default,){
final _that = this;
switch (_that) {
case _CallEvent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String eventId,  String eventType,  int version,  String callId,  DateTime occurredAt,  Map<String, dynamic> payload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallEvent() when $default != null:
return $default(_that.eventId,_that.eventType,_that.version,_that.callId,_that.occurredAt,_that.payload);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String eventId,  String eventType,  int version,  String callId,  DateTime occurredAt,  Map<String, dynamic> payload)  $default,) {final _that = this;
switch (_that) {
case _CallEvent():
return $default(_that.eventId,_that.eventType,_that.version,_that.callId,_that.occurredAt,_that.payload);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String eventId,  String eventType,  int version,  String callId,  DateTime occurredAt,  Map<String, dynamic> payload)?  $default,) {final _that = this;
switch (_that) {
case _CallEvent() when $default != null:
return $default(_that.eventId,_that.eventType,_that.version,_that.callId,_that.occurredAt,_that.payload);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CallEvent implements CallEvent {
  const _CallEvent({required this.eventId, required this.eventType, required this.version, required this.callId, required this.occurredAt, required final  Map<String, dynamic> payload}): _payload = payload;
  factory _CallEvent.fromJson(Map<String, dynamic> json) => _$CallEventFromJson(json);

@override final  String eventId;
@override final  String eventType;
@override final  int version;
@override final  String callId;
@override final  DateTime occurredAt;
 final  Map<String, dynamic> _payload;
@override Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}


/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallEventCopyWith<_CallEvent> get copyWith => __$CallEventCopyWithImpl<_CallEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.version, version) || other.version == version)&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&const DeepCollectionEquality().equals(other._payload, _payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,eventType,version,callId,occurredAt,const DeepCollectionEquality().hash(_payload));

@override
String toString() {
  return 'CallEvent(eventId: $eventId, eventType: $eventType, version: $version, callId: $callId, occurredAt: $occurredAt, payload: $payload)';
}


}

/// @nodoc
abstract mixin class _$CallEventCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory _$CallEventCopyWith(_CallEvent value, $Res Function(_CallEvent) _then) = __$CallEventCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String eventType, int version, String callId, DateTime occurredAt, Map<String, dynamic> payload
});




}
/// @nodoc
class __$CallEventCopyWithImpl<$Res>
    implements _$CallEventCopyWith<$Res> {
  __$CallEventCopyWithImpl(this._self, this._then);

  final _CallEvent _self;
  final $Res Function(_CallEvent) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? eventType = null,Object? version = null,Object? callId = null,Object? occurredAt = null,Object? payload = null,}) {
  return _then(_CallEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
