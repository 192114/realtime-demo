// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessage {

@JsonKey(fromJson: wireId) String get messageId;@JsonKey(fromJson: wireId) String get conversationId;@JsonKey(fromJson: wireId) String get senderId; String get clientMsgId;// 服务端旧版本可能不回传 type，本地旧缓存也依赖默认值兼容。
 String get type;@JsonKey(fromJson: wireCursor) String? get callId;@JsonKey(fromJson: wireSeq, toJson: seqToWire) int get seq; String get text; DateTime get createdAt;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.clientMsgId, clientMsgId) || other.clientMsgId == clientMsgId)&&(identical(other.type, type) || other.type == type)&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,conversationId,senderId,clientMsgId,type,callId,seq,text,createdAt);

@override
String toString() {
  return 'ChatMessage(messageId: $messageId, conversationId: $conversationId, senderId: $senderId, clientMsgId: $clientMsgId, type: $type, callId: $callId, seq: $seq, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: wireId) String messageId,@JsonKey(fromJson: wireId) String conversationId,@JsonKey(fromJson: wireId) String senderId, String clientMsgId, String type,@JsonKey(fromJson: wireCursor) String? callId,@JsonKey(fromJson: wireSeq, toJson: seqToWire) int seq, String text, DateTime createdAt
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messageId = null,Object? conversationId = null,Object? senderId = null,Object? clientMsgId = null,Object? type = null,Object? callId = freezed,Object? seq = null,Object? text = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,clientMsgId: null == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,callId: freezed == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String?,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: wireId)  String messageId, @JsonKey(fromJson: wireId)  String conversationId, @JsonKey(fromJson: wireId)  String senderId,  String clientMsgId,  String type, @JsonKey(fromJson: wireCursor)  String? callId, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int seq,  String text,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.messageId,_that.conversationId,_that.senderId,_that.clientMsgId,_that.type,_that.callId,_that.seq,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: wireId)  String messageId, @JsonKey(fromJson: wireId)  String conversationId, @JsonKey(fromJson: wireId)  String senderId,  String clientMsgId,  String type, @JsonKey(fromJson: wireCursor)  String? callId, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int seq,  String text,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.messageId,_that.conversationId,_that.senderId,_that.clientMsgId,_that.type,_that.callId,_that.seq,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: wireId)  String messageId, @JsonKey(fromJson: wireId)  String conversationId, @JsonKey(fromJson: wireId)  String senderId,  String clientMsgId,  String type, @JsonKey(fromJson: wireCursor)  String? callId, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int seq,  String text,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.messageId,_that.conversationId,_that.senderId,_that.clientMsgId,_that.type,_that.callId,_that.seq,_that.text,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessage implements ChatMessage {
  const _ChatMessage({@JsonKey(fromJson: wireId) required this.messageId, @JsonKey(fromJson: wireId) required this.conversationId, @JsonKey(fromJson: wireId) required this.senderId, required this.clientMsgId, this.type = messageTypeText, @JsonKey(fromJson: wireCursor) this.callId, @JsonKey(fromJson: wireSeq, toJson: seqToWire) required this.seq, required this.text, required this.createdAt});
  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

@override@JsonKey(fromJson: wireId) final  String messageId;
@override@JsonKey(fromJson: wireId) final  String conversationId;
@override@JsonKey(fromJson: wireId) final  String senderId;
@override final  String clientMsgId;
// 服务端旧版本可能不回传 type，本地旧缓存也依赖默认值兼容。
@override@JsonKey() final  String type;
@override@JsonKey(fromJson: wireCursor) final  String? callId;
@override@JsonKey(fromJson: wireSeq, toJson: seqToWire) final  int seq;
@override final  String text;
@override final  DateTime createdAt;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.clientMsgId, clientMsgId) || other.clientMsgId == clientMsgId)&&(identical(other.type, type) || other.type == type)&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,conversationId,senderId,clientMsgId,type,callId,seq,text,createdAt);

@override
String toString() {
  return 'ChatMessage(messageId: $messageId, conversationId: $conversationId, senderId: $senderId, clientMsgId: $clientMsgId, type: $type, callId: $callId, seq: $seq, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: wireId) String messageId,@JsonKey(fromJson: wireId) String conversationId,@JsonKey(fromJson: wireId) String senderId, String clientMsgId, String type,@JsonKey(fromJson: wireCursor) String? callId,@JsonKey(fromJson: wireSeq, toJson: seqToWire) int seq, String text, DateTime createdAt
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messageId = null,Object? conversationId = null,Object? senderId = null,Object? clientMsgId = null,Object? type = null,Object? callId = freezed,Object? seq = null,Object? text = null,Object? createdAt = null,}) {
  return _then(_ChatMessage(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,clientMsgId: null == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,callId: freezed == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String?,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ChatConversation {

@JsonKey(fromJson: wireId) String get conversationId;@JsonKey(fromJson: wireId) String get peerUserId; String? get peerNickname;@JsonKey(fromJson: wireSeq, toJson: seqToWire) int get lastSeq;@JsonKey(fromJson: wireSeq, toJson: seqToWire) int get readSeq;@JsonKey(fromJson: wireSeq, toJson: seqToWire) int get peerReadSeq;@JsonKey(fromJson: wireSeq) int get unreadCount;@JsonKey(fromJson: wirePreview) String? get lastMessage; DateTime get updatedAt;
/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatConversationCopyWith<ChatConversation> get copyWith => _$ChatConversationCopyWithImpl<ChatConversation>(this as ChatConversation, _$identity);

  /// Serializes this ChatConversation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatConversation&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.peerUserId, peerUserId) || other.peerUserId == peerUserId)&&(identical(other.peerNickname, peerNickname) || other.peerNickname == peerNickname)&&(identical(other.lastSeq, lastSeq) || other.lastSeq == lastSeq)&&(identical(other.readSeq, readSeq) || other.readSeq == readSeq)&&(identical(other.peerReadSeq, peerReadSeq) || other.peerReadSeq == peerReadSeq)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId,peerUserId,peerNickname,lastSeq,readSeq,peerReadSeq,unreadCount,lastMessage,updatedAt);

@override
String toString() {
  return 'ChatConversation(conversationId: $conversationId, peerUserId: $peerUserId, peerNickname: $peerNickname, lastSeq: $lastSeq, readSeq: $readSeq, peerReadSeq: $peerReadSeq, unreadCount: $unreadCount, lastMessage: $lastMessage, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ChatConversationCopyWith<$Res>  {
  factory $ChatConversationCopyWith(ChatConversation value, $Res Function(ChatConversation) _then) = _$ChatConversationCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: wireId) String conversationId,@JsonKey(fromJson: wireId) String peerUserId, String? peerNickname,@JsonKey(fromJson: wireSeq, toJson: seqToWire) int lastSeq,@JsonKey(fromJson: wireSeq, toJson: seqToWire) int readSeq,@JsonKey(fromJson: wireSeq, toJson: seqToWire) int peerReadSeq,@JsonKey(fromJson: wireSeq) int unreadCount,@JsonKey(fromJson: wirePreview) String? lastMessage, DateTime updatedAt
});




}
/// @nodoc
class _$ChatConversationCopyWithImpl<$Res>
    implements $ChatConversationCopyWith<$Res> {
  _$ChatConversationCopyWithImpl(this._self, this._then);

  final ChatConversation _self;
  final $Res Function(ChatConversation) _then;

/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = null,Object? peerUserId = null,Object? peerNickname = freezed,Object? lastSeq = null,Object? readSeq = null,Object? peerReadSeq = null,Object? unreadCount = null,Object? lastMessage = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,peerUserId: null == peerUserId ? _self.peerUserId : peerUserId // ignore: cast_nullable_to_non_nullable
as String,peerNickname: freezed == peerNickname ? _self.peerNickname : peerNickname // ignore: cast_nullable_to_non_nullable
as String?,lastSeq: null == lastSeq ? _self.lastSeq : lastSeq // ignore: cast_nullable_to_non_nullable
as int,readSeq: null == readSeq ? _self.readSeq : readSeq // ignore: cast_nullable_to_non_nullable
as int,peerReadSeq: null == peerReadSeq ? _self.peerReadSeq : peerReadSeq // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatConversation].
extension ChatConversationPatterns on ChatConversation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatConversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatConversation value)  $default,){
final _that = this;
switch (_that) {
case _ChatConversation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatConversation value)?  $default,){
final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: wireId)  String conversationId, @JsonKey(fromJson: wireId)  String peerUserId,  String? peerNickname, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int lastSeq, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int readSeq, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int peerReadSeq, @JsonKey(fromJson: wireSeq)  int unreadCount, @JsonKey(fromJson: wirePreview)  String? lastMessage,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
return $default(_that.conversationId,_that.peerUserId,_that.peerNickname,_that.lastSeq,_that.readSeq,_that.peerReadSeq,_that.unreadCount,_that.lastMessage,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: wireId)  String conversationId, @JsonKey(fromJson: wireId)  String peerUserId,  String? peerNickname, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int lastSeq, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int readSeq, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int peerReadSeq, @JsonKey(fromJson: wireSeq)  int unreadCount, @JsonKey(fromJson: wirePreview)  String? lastMessage,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ChatConversation():
return $default(_that.conversationId,_that.peerUserId,_that.peerNickname,_that.lastSeq,_that.readSeq,_that.peerReadSeq,_that.unreadCount,_that.lastMessage,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: wireId)  String conversationId, @JsonKey(fromJson: wireId)  String peerUserId,  String? peerNickname, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int lastSeq, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int readSeq, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int peerReadSeq, @JsonKey(fromJson: wireSeq)  int unreadCount, @JsonKey(fromJson: wirePreview)  String? lastMessage,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
return $default(_that.conversationId,_that.peerUserId,_that.peerNickname,_that.lastSeq,_that.readSeq,_that.peerReadSeq,_that.unreadCount,_that.lastMessage,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatConversation implements ChatConversation {
  const _ChatConversation({@JsonKey(fromJson: wireId) required this.conversationId, @JsonKey(fromJson: wireId) required this.peerUserId, this.peerNickname, @JsonKey(fromJson: wireSeq, toJson: seqToWire) this.lastSeq = 0, @JsonKey(fromJson: wireSeq, toJson: seqToWire) this.readSeq = 0, @JsonKey(fromJson: wireSeq, toJson: seqToWire) this.peerReadSeq = 0, @JsonKey(fromJson: wireSeq) this.unreadCount = 0, @JsonKey(fromJson: wirePreview) this.lastMessage, required this.updatedAt});
  factory _ChatConversation.fromJson(Map<String, dynamic> json) => _$ChatConversationFromJson(json);

@override@JsonKey(fromJson: wireId) final  String conversationId;
@override@JsonKey(fromJson: wireId) final  String peerUserId;
@override final  String? peerNickname;
@override@JsonKey(fromJson: wireSeq, toJson: seqToWire) final  int lastSeq;
@override@JsonKey(fromJson: wireSeq, toJson: seqToWire) final  int readSeq;
@override@JsonKey(fromJson: wireSeq, toJson: seqToWire) final  int peerReadSeq;
@override@JsonKey(fromJson: wireSeq) final  int unreadCount;
@override@JsonKey(fromJson: wirePreview) final  String? lastMessage;
@override final  DateTime updatedAt;

/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatConversationCopyWith<_ChatConversation> get copyWith => __$ChatConversationCopyWithImpl<_ChatConversation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatConversationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatConversation&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.peerUserId, peerUserId) || other.peerUserId == peerUserId)&&(identical(other.peerNickname, peerNickname) || other.peerNickname == peerNickname)&&(identical(other.lastSeq, lastSeq) || other.lastSeq == lastSeq)&&(identical(other.readSeq, readSeq) || other.readSeq == readSeq)&&(identical(other.peerReadSeq, peerReadSeq) || other.peerReadSeq == peerReadSeq)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId,peerUserId,peerNickname,lastSeq,readSeq,peerReadSeq,unreadCount,lastMessage,updatedAt);

@override
String toString() {
  return 'ChatConversation(conversationId: $conversationId, peerUserId: $peerUserId, peerNickname: $peerNickname, lastSeq: $lastSeq, readSeq: $readSeq, peerReadSeq: $peerReadSeq, unreadCount: $unreadCount, lastMessage: $lastMessage, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChatConversationCopyWith<$Res> implements $ChatConversationCopyWith<$Res> {
  factory _$ChatConversationCopyWith(_ChatConversation value, $Res Function(_ChatConversation) _then) = __$ChatConversationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: wireId) String conversationId,@JsonKey(fromJson: wireId) String peerUserId, String? peerNickname,@JsonKey(fromJson: wireSeq, toJson: seqToWire) int lastSeq,@JsonKey(fromJson: wireSeq, toJson: seqToWire) int readSeq,@JsonKey(fromJson: wireSeq, toJson: seqToWire) int peerReadSeq,@JsonKey(fromJson: wireSeq) int unreadCount,@JsonKey(fromJson: wirePreview) String? lastMessage, DateTime updatedAt
});




}
/// @nodoc
class __$ChatConversationCopyWithImpl<$Res>
    implements _$ChatConversationCopyWith<$Res> {
  __$ChatConversationCopyWithImpl(this._self, this._then);

  final _ChatConversation _self;
  final $Res Function(_ChatConversation) _then;

/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? peerUserId = null,Object? peerNickname = freezed,Object? lastSeq = null,Object? readSeq = null,Object? peerReadSeq = null,Object? unreadCount = null,Object? lastMessage = freezed,Object? updatedAt = null,}) {
  return _then(_ChatConversation(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,peerUserId: null == peerUserId ? _self.peerUserId : peerUserId // ignore: cast_nullable_to_non_nullable
as String,peerNickname: freezed == peerNickname ? _self.peerNickname : peerNickname // ignore: cast_nullable_to_non_nullable
as String?,lastSeq: null == lastSeq ? _self.lastSeq : lastSeq // ignore: cast_nullable_to_non_nullable
as int,readSeq: null == readSeq ? _self.readSeq : readSeq // ignore: cast_nullable_to_non_nullable
as int,peerReadSeq: null == peerReadSeq ? _self.peerReadSeq : peerReadSeq // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ChatMessagePage {

 List<ChatMessage> get items; bool get hasMore;@JsonKey(fromJson: wireCursor) String? get nextCursor;
/// Create a copy of ChatMessagePage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessagePageCopyWith<ChatMessagePage> get copyWith => _$ChatMessagePageCopyWithImpl<ChatMessagePage>(this as ChatMessagePage, _$identity);

  /// Serializes this ChatMessagePage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessagePage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),hasMore,nextCursor);

@override
String toString() {
  return 'ChatMessagePage(items: $items, hasMore: $hasMore, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $ChatMessagePageCopyWith<$Res>  {
  factory $ChatMessagePageCopyWith(ChatMessagePage value, $Res Function(ChatMessagePage) _then) = _$ChatMessagePageCopyWithImpl;
@useResult
$Res call({
 List<ChatMessage> items, bool hasMore,@JsonKey(fromJson: wireCursor) String? nextCursor
});




}
/// @nodoc
class _$ChatMessagePageCopyWithImpl<$Res>
    implements $ChatMessagePageCopyWith<$Res> {
  _$ChatMessagePageCopyWithImpl(this._self, this._then);

  final ChatMessagePage _self;
  final $Res Function(ChatMessagePage) _then;

/// Create a copy of ChatMessagePage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? hasMore = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessagePage].
extension ChatMessagePagePatterns on ChatMessagePage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessagePage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessagePage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessagePage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessagePage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessagePage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessagePage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ChatMessage> items,  bool hasMore, @JsonKey(fromJson: wireCursor)  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessagePage() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ChatMessage> items,  bool hasMore, @JsonKey(fromJson: wireCursor)  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _ChatMessagePage():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ChatMessage> items,  bool hasMore, @JsonKey(fromJson: wireCursor)  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessagePage() when $default != null:
return $default(_that.items,_that.hasMore,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessagePage implements ChatMessagePage {
  const _ChatMessagePage({required final  List<ChatMessage> items, required this.hasMore, @JsonKey(fromJson: wireCursor) this.nextCursor}): _items = items;
  factory _ChatMessagePage.fromJson(Map<String, dynamic> json) => _$ChatMessagePageFromJson(json);

 final  List<ChatMessage> _items;
@override List<ChatMessage> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  bool hasMore;
@override@JsonKey(fromJson: wireCursor) final  String? nextCursor;

/// Create a copy of ChatMessagePage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessagePageCopyWith<_ChatMessagePage> get copyWith => __$ChatMessagePageCopyWithImpl<_ChatMessagePage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessagePageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessagePage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),hasMore,nextCursor);

@override
String toString() {
  return 'ChatMessagePage(items: $items, hasMore: $hasMore, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$ChatMessagePageCopyWith<$Res> implements $ChatMessagePageCopyWith<$Res> {
  factory _$ChatMessagePageCopyWith(_ChatMessagePage value, $Res Function(_ChatMessagePage) _then) = __$ChatMessagePageCopyWithImpl;
@override @useResult
$Res call({
 List<ChatMessage> items, bool hasMore,@JsonKey(fromJson: wireCursor) String? nextCursor
});




}
/// @nodoc
class __$ChatMessagePageCopyWithImpl<$Res>
    implements _$ChatMessagePageCopyWith<$Res> {
  __$ChatMessagePageCopyWithImpl(this._self, this._then);

  final _ChatMessagePage _self;
  final $Res Function(_ChatMessagePage) _then;

/// Create a copy of ChatMessagePage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? hasMore = null,Object? nextCursor = freezed,}) {
  return _then(_ChatMessagePage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChatConversationPage {

 List<ChatConversation> get items; bool get hasMore;@JsonKey(fromJson: wireCursor) String? get nextCursor;
/// Create a copy of ChatConversationPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatConversationPageCopyWith<ChatConversationPage> get copyWith => _$ChatConversationPageCopyWithImpl<ChatConversationPage>(this as ChatConversationPage, _$identity);

  /// Serializes this ChatConversationPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatConversationPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),hasMore,nextCursor);

@override
String toString() {
  return 'ChatConversationPage(items: $items, hasMore: $hasMore, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $ChatConversationPageCopyWith<$Res>  {
  factory $ChatConversationPageCopyWith(ChatConversationPage value, $Res Function(ChatConversationPage) _then) = _$ChatConversationPageCopyWithImpl;
@useResult
$Res call({
 List<ChatConversation> items, bool hasMore,@JsonKey(fromJson: wireCursor) String? nextCursor
});




}
/// @nodoc
class _$ChatConversationPageCopyWithImpl<$Res>
    implements $ChatConversationPageCopyWith<$Res> {
  _$ChatConversationPageCopyWithImpl(this._self, this._then);

  final ChatConversationPage _self;
  final $Res Function(ChatConversationPage) _then;

/// Create a copy of ChatConversationPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? hasMore = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ChatConversation>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatConversationPage].
extension ChatConversationPagePatterns on ChatConversationPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatConversationPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatConversationPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatConversationPage value)  $default,){
final _that = this;
switch (_that) {
case _ChatConversationPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatConversationPage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatConversationPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ChatConversation> items,  bool hasMore, @JsonKey(fromJson: wireCursor)  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatConversationPage() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ChatConversation> items,  bool hasMore, @JsonKey(fromJson: wireCursor)  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _ChatConversationPage():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ChatConversation> items,  bool hasMore, @JsonKey(fromJson: wireCursor)  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _ChatConversationPage() when $default != null:
return $default(_that.items,_that.hasMore,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatConversationPage implements ChatConversationPage {
  const _ChatConversationPage({required final  List<ChatConversation> items, required this.hasMore, @JsonKey(fromJson: wireCursor) this.nextCursor}): _items = items;
  factory _ChatConversationPage.fromJson(Map<String, dynamic> json) => _$ChatConversationPageFromJson(json);

 final  List<ChatConversation> _items;
@override List<ChatConversation> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  bool hasMore;
@override@JsonKey(fromJson: wireCursor) final  String? nextCursor;

/// Create a copy of ChatConversationPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatConversationPageCopyWith<_ChatConversationPage> get copyWith => __$ChatConversationPageCopyWithImpl<_ChatConversationPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatConversationPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatConversationPage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),hasMore,nextCursor);

@override
String toString() {
  return 'ChatConversationPage(items: $items, hasMore: $hasMore, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$ChatConversationPageCopyWith<$Res> implements $ChatConversationPageCopyWith<$Res> {
  factory _$ChatConversationPageCopyWith(_ChatConversationPage value, $Res Function(_ChatConversationPage) _then) = __$ChatConversationPageCopyWithImpl;
@override @useResult
$Res call({
 List<ChatConversation> items, bool hasMore,@JsonKey(fromJson: wireCursor) String? nextCursor
});




}
/// @nodoc
class __$ChatConversationPageCopyWithImpl<$Res>
    implements _$ChatConversationPageCopyWith<$Res> {
  __$ChatConversationPageCopyWithImpl(this._self, this._then);

  final _ChatConversationPage _self;
  final $Res Function(_ChatConversationPage) _then;

/// Create a copy of ChatConversationPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? hasMore = null,Object? nextCursor = freezed,}) {
  return _then(_ChatConversationPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ChatConversation>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PendingMessage {

 String get clientMsgId; String get conversationId; String get senderId; String get text; DateTime get createdAt;
/// Create a copy of PendingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingMessageCopyWith<PendingMessage> get copyWith => _$PendingMessageCopyWithImpl<PendingMessage>(this as PendingMessage, _$identity);

  /// Serializes this PendingMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingMessage&&(identical(other.clientMsgId, clientMsgId) || other.clientMsgId == clientMsgId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientMsgId,conversationId,senderId,text,createdAt);

@override
String toString() {
  return 'PendingMessage(clientMsgId: $clientMsgId, conversationId: $conversationId, senderId: $senderId, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PendingMessageCopyWith<$Res>  {
  factory $PendingMessageCopyWith(PendingMessage value, $Res Function(PendingMessage) _then) = _$PendingMessageCopyWithImpl;
@useResult
$Res call({
 String clientMsgId, String conversationId, String senderId, String text, DateTime createdAt
});




}
/// @nodoc
class _$PendingMessageCopyWithImpl<$Res>
    implements $PendingMessageCopyWith<$Res> {
  _$PendingMessageCopyWithImpl(this._self, this._then);

  final PendingMessage _self;
  final $Res Function(PendingMessage) _then;

/// Create a copy of PendingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientMsgId = null,Object? conversationId = null,Object? senderId = null,Object? text = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
clientMsgId: null == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingMessage].
extension PendingMessagePatterns on PendingMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingMessage value)  $default,){
final _that = this;
switch (_that) {
case _PendingMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingMessage value)?  $default,){
final _that = this;
switch (_that) {
case _PendingMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clientMsgId,  String conversationId,  String senderId,  String text,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingMessage() when $default != null:
return $default(_that.clientMsgId,_that.conversationId,_that.senderId,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clientMsgId,  String conversationId,  String senderId,  String text,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PendingMessage():
return $default(_that.clientMsgId,_that.conversationId,_that.senderId,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clientMsgId,  String conversationId,  String senderId,  String text,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PendingMessage() when $default != null:
return $default(_that.clientMsgId,_that.conversationId,_that.senderId,_that.text,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingMessage implements PendingMessage {
  const _PendingMessage({required this.clientMsgId, required this.conversationId, required this.senderId, required this.text, required this.createdAt});
  factory _PendingMessage.fromJson(Map<String, dynamic> json) => _$PendingMessageFromJson(json);

@override final  String clientMsgId;
@override final  String conversationId;
@override final  String senderId;
@override final  String text;
@override final  DateTime createdAt;

/// Create a copy of PendingMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingMessageCopyWith<_PendingMessage> get copyWith => __$PendingMessageCopyWithImpl<_PendingMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingMessage&&(identical(other.clientMsgId, clientMsgId) || other.clientMsgId == clientMsgId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientMsgId,conversationId,senderId,text,createdAt);

@override
String toString() {
  return 'PendingMessage(clientMsgId: $clientMsgId, conversationId: $conversationId, senderId: $senderId, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PendingMessageCopyWith<$Res> implements $PendingMessageCopyWith<$Res> {
  factory _$PendingMessageCopyWith(_PendingMessage value, $Res Function(_PendingMessage) _then) = __$PendingMessageCopyWithImpl;
@override @useResult
$Res call({
 String clientMsgId, String conversationId, String senderId, String text, DateTime createdAt
});




}
/// @nodoc
class __$PendingMessageCopyWithImpl<$Res>
    implements _$PendingMessageCopyWith<$Res> {
  __$PendingMessageCopyWithImpl(this._self, this._then);

  final _PendingMessage _self;
  final $Res Function(_PendingMessage) _then;

/// Create a copy of PendingMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientMsgId = null,Object? conversationId = null,Object? senderId = null,Object? text = null,Object? createdAt = null,}) {
  return _then(_PendingMessage(
clientMsgId: null == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$MqttCredentials {

 String get url; String get clientId; String get username; String get password; DateTime get expiresAt; List<String> get topics; int get qos;
/// Create a copy of MqttCredentials
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MqttCredentialsCopyWith<MqttCredentials> get copyWith => _$MqttCredentialsCopyWithImpl<MqttCredentials>(this as MqttCredentials, _$identity);

  /// Serializes this MqttCredentials to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MqttCredentials&&(identical(other.url, url) || other.url == url)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other.topics, topics)&&(identical(other.qos, qos) || other.qos == qos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,clientId,username,password,expiresAt,const DeepCollectionEquality().hash(topics),qos);

@override
String toString() {
  return 'MqttCredentials(url: $url, clientId: $clientId, username: $username, password: $password, expiresAt: $expiresAt, topics: $topics, qos: $qos)';
}


}

/// @nodoc
abstract mixin class $MqttCredentialsCopyWith<$Res>  {
  factory $MqttCredentialsCopyWith(MqttCredentials value, $Res Function(MqttCredentials) _then) = _$MqttCredentialsCopyWithImpl;
@useResult
$Res call({
 String url, String clientId, String username, String password, DateTime expiresAt, List<String> topics, int qos
});




}
/// @nodoc
class _$MqttCredentialsCopyWithImpl<$Res>
    implements $MqttCredentialsCopyWith<$Res> {
  _$MqttCredentialsCopyWithImpl(this._self, this._then);

  final MqttCredentials _self;
  final $Res Function(MqttCredentials) _then;

/// Create a copy of MqttCredentials
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? clientId = null,Object? username = null,Object? password = null,Object? expiresAt = null,Object? topics = null,Object? qos = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,topics: null == topics ? _self.topics : topics // ignore: cast_nullable_to_non_nullable
as List<String>,qos: null == qos ? _self.qos : qos // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MqttCredentials].
extension MqttCredentialsPatterns on MqttCredentials {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MqttCredentials value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MqttCredentials() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MqttCredentials value)  $default,){
final _that = this;
switch (_that) {
case _MqttCredentials():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MqttCredentials value)?  $default,){
final _that = this;
switch (_that) {
case _MqttCredentials() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String clientId,  String username,  String password,  DateTime expiresAt,  List<String> topics,  int qos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MqttCredentials() when $default != null:
return $default(_that.url,_that.clientId,_that.username,_that.password,_that.expiresAt,_that.topics,_that.qos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String clientId,  String username,  String password,  DateTime expiresAt,  List<String> topics,  int qos)  $default,) {final _that = this;
switch (_that) {
case _MqttCredentials():
return $default(_that.url,_that.clientId,_that.username,_that.password,_that.expiresAt,_that.topics,_that.qos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String clientId,  String username,  String password,  DateTime expiresAt,  List<String> topics,  int qos)?  $default,) {final _that = this;
switch (_that) {
case _MqttCredentials() when $default != null:
return $default(_that.url,_that.clientId,_that.username,_that.password,_that.expiresAt,_that.topics,_that.qos);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MqttCredentials implements MqttCredentials {
  const _MqttCredentials({required this.url, required this.clientId, required this.username, required this.password, required this.expiresAt, required final  List<String> topics, required this.qos}): _topics = topics;
  factory _MqttCredentials.fromJson(Map<String, dynamic> json) => _$MqttCredentialsFromJson(json);

@override final  String url;
@override final  String clientId;
@override final  String username;
@override final  String password;
@override final  DateTime expiresAt;
 final  List<String> _topics;
@override List<String> get topics {
  if (_topics is EqualUnmodifiableListView) return _topics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topics);
}

@override final  int qos;

/// Create a copy of MqttCredentials
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MqttCredentialsCopyWith<_MqttCredentials> get copyWith => __$MqttCredentialsCopyWithImpl<_MqttCredentials>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MqttCredentialsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MqttCredentials&&(identical(other.url, url) || other.url == url)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other._topics, _topics)&&(identical(other.qos, qos) || other.qos == qos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,clientId,username,password,expiresAt,const DeepCollectionEquality().hash(_topics),qos);

@override
String toString() {
  return 'MqttCredentials(url: $url, clientId: $clientId, username: $username, password: $password, expiresAt: $expiresAt, topics: $topics, qos: $qos)';
}


}

/// @nodoc
abstract mixin class _$MqttCredentialsCopyWith<$Res> implements $MqttCredentialsCopyWith<$Res> {
  factory _$MqttCredentialsCopyWith(_MqttCredentials value, $Res Function(_MqttCredentials) _then) = __$MqttCredentialsCopyWithImpl;
@override @useResult
$Res call({
 String url, String clientId, String username, String password, DateTime expiresAt, List<String> topics, int qos
});




}
/// @nodoc
class __$MqttCredentialsCopyWithImpl<$Res>
    implements _$MqttCredentialsCopyWith<$Res> {
  __$MqttCredentialsCopyWithImpl(this._self, this._then);

  final _MqttCredentials _self;
  final $Res Function(_MqttCredentials) _then;

/// Create a copy of MqttCredentials
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? clientId = null,Object? username = null,Object? password = null,Object? expiresAt = null,Object? topics = null,Object? qos = null,}) {
  return _then(_MqttCredentials(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,topics: null == topics ? _self._topics : topics // ignore: cast_nullable_to_non_nullable
as List<String>,qos: null == qos ? _self.qos : qos // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ChatEvent {

@JsonKey(fromJson: wireId) String get eventId; String get eventType; int get version;@JsonKey(fromJson: wireId) String get conversationId;@JsonKey(fromJson: wireCursor) String? get messageId;@JsonKey(fromJson: wireSeq, toJson: seqToWire) int get seq; DateTime get occurredAt; Map<String, dynamic> get payload;
/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatEventCopyWith<ChatEvent> get copyWith => _$ChatEventCopyWithImpl<ChatEvent>(this as ChatEvent, _$identity);

  /// Serializes this ChatEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.version, version) || other.version == version)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&const DeepCollectionEquality().equals(other.payload, payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,eventType,version,conversationId,messageId,seq,occurredAt,const DeepCollectionEquality().hash(payload));

@override
String toString() {
  return 'ChatEvent(eventId: $eventId, eventType: $eventType, version: $version, conversationId: $conversationId, messageId: $messageId, seq: $seq, occurredAt: $occurredAt, payload: $payload)';
}


}

/// @nodoc
abstract mixin class $ChatEventCopyWith<$Res>  {
  factory $ChatEventCopyWith(ChatEvent value, $Res Function(ChatEvent) _then) = _$ChatEventCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: wireId) String eventId, String eventType, int version,@JsonKey(fromJson: wireId) String conversationId,@JsonKey(fromJson: wireCursor) String? messageId,@JsonKey(fromJson: wireSeq, toJson: seqToWire) int seq, DateTime occurredAt, Map<String, dynamic> payload
});




}
/// @nodoc
class _$ChatEventCopyWithImpl<$Res>
    implements $ChatEventCopyWith<$Res> {
  _$ChatEventCopyWithImpl(this._self, this._then);

  final ChatEvent _self;
  final $Res Function(ChatEvent) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? eventType = null,Object? version = null,Object? conversationId = null,Object? messageId = freezed,Object? seq = null,Object? occurredAt = null,Object? payload = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,messageId: freezed == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String?,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatEvent].
extension ChatEventPatterns on ChatEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatEvent value)  $default,){
final _that = this;
switch (_that) {
case _ChatEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatEvent value)?  $default,){
final _that = this;
switch (_that) {
case _ChatEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: wireId)  String eventId,  String eventType,  int version, @JsonKey(fromJson: wireId)  String conversationId, @JsonKey(fromJson: wireCursor)  String? messageId, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int seq,  DateTime occurredAt,  Map<String, dynamic> payload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatEvent() when $default != null:
return $default(_that.eventId,_that.eventType,_that.version,_that.conversationId,_that.messageId,_that.seq,_that.occurredAt,_that.payload);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: wireId)  String eventId,  String eventType,  int version, @JsonKey(fromJson: wireId)  String conversationId, @JsonKey(fromJson: wireCursor)  String? messageId, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int seq,  DateTime occurredAt,  Map<String, dynamic> payload)  $default,) {final _that = this;
switch (_that) {
case _ChatEvent():
return $default(_that.eventId,_that.eventType,_that.version,_that.conversationId,_that.messageId,_that.seq,_that.occurredAt,_that.payload);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: wireId)  String eventId,  String eventType,  int version, @JsonKey(fromJson: wireId)  String conversationId, @JsonKey(fromJson: wireCursor)  String? messageId, @JsonKey(fromJson: wireSeq, toJson: seqToWire)  int seq,  DateTime occurredAt,  Map<String, dynamic> payload)?  $default,) {final _that = this;
switch (_that) {
case _ChatEvent() when $default != null:
return $default(_that.eventId,_that.eventType,_that.version,_that.conversationId,_that.messageId,_that.seq,_that.occurredAt,_that.payload);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatEvent implements ChatEvent {
  const _ChatEvent({@JsonKey(fromJson: wireId) required this.eventId, required this.eventType, required this.version, @JsonKey(fromJson: wireId) required this.conversationId, @JsonKey(fromJson: wireCursor) this.messageId, @JsonKey(fromJson: wireSeq, toJson: seqToWire) this.seq = 0, required this.occurredAt, required final  Map<String, dynamic> payload}): _payload = payload;
  factory _ChatEvent.fromJson(Map<String, dynamic> json) => _$ChatEventFromJson(json);

@override@JsonKey(fromJson: wireId) final  String eventId;
@override final  String eventType;
@override final  int version;
@override@JsonKey(fromJson: wireId) final  String conversationId;
@override@JsonKey(fromJson: wireCursor) final  String? messageId;
@override@JsonKey(fromJson: wireSeq, toJson: seqToWire) final  int seq;
@override final  DateTime occurredAt;
 final  Map<String, dynamic> _payload;
@override Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}


/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatEventCopyWith<_ChatEvent> get copyWith => __$ChatEventCopyWithImpl<_ChatEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.version, version) || other.version == version)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&const DeepCollectionEquality().equals(other._payload, _payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,eventType,version,conversationId,messageId,seq,occurredAt,const DeepCollectionEquality().hash(_payload));

@override
String toString() {
  return 'ChatEvent(eventId: $eventId, eventType: $eventType, version: $version, conversationId: $conversationId, messageId: $messageId, seq: $seq, occurredAt: $occurredAt, payload: $payload)';
}


}

/// @nodoc
abstract mixin class _$ChatEventCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory _$ChatEventCopyWith(_ChatEvent value, $Res Function(_ChatEvent) _then) = __$ChatEventCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: wireId) String eventId, String eventType, int version,@JsonKey(fromJson: wireId) String conversationId,@JsonKey(fromJson: wireCursor) String? messageId,@JsonKey(fromJson: wireSeq, toJson: seqToWire) int seq, DateTime occurredAt, Map<String, dynamic> payload
});




}
/// @nodoc
class __$ChatEventCopyWithImpl<$Res>
    implements _$ChatEventCopyWith<$Res> {
  __$ChatEventCopyWithImpl(this._self, this._then);

  final _ChatEvent _self;
  final $Res Function(_ChatEvent) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? eventType = null,Object? version = null,Object? conversationId = null,Object? messageId = freezed,Object? seq = null,Object? occurredAt = null,Object? payload = null,}) {
  return _then(_ChatEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,messageId: freezed == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String?,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
