// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_view_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatHomeState {

 ChatRepository? get repository; ChatConnection get connection; bool get initializing; String? get errorMessage; List<ChatConversation> get conversations; String? get actionError; int get errorSeq;
/// Create a copy of ChatHomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatHomeStateCopyWith<ChatHomeState> get copyWith => _$ChatHomeStateCopyWithImpl<ChatHomeState>(this as ChatHomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatHomeState&&(identical(other.repository, repository) || other.repository == repository)&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.initializing, initializing) || other.initializing == initializing)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.conversations, conversations)&&(identical(other.actionError, actionError) || other.actionError == actionError)&&(identical(other.errorSeq, errorSeq) || other.errorSeq == errorSeq));
}


@override
int get hashCode => Object.hash(runtimeType,repository,connection,initializing,errorMessage,const DeepCollectionEquality().hash(conversations),actionError,errorSeq);

@override
String toString() {
  return 'ChatHomeState(repository: $repository, connection: $connection, initializing: $initializing, errorMessage: $errorMessage, conversations: $conversations, actionError: $actionError, errorSeq: $errorSeq)';
}


}

/// @nodoc
abstract mixin class $ChatHomeStateCopyWith<$Res>  {
  factory $ChatHomeStateCopyWith(ChatHomeState value, $Res Function(ChatHomeState) _then) = _$ChatHomeStateCopyWithImpl;
@useResult
$Res call({
 ChatRepository? repository, ChatConnection connection, bool initializing, String? errorMessage, List<ChatConversation> conversations, String? actionError, int errorSeq
});




}
/// @nodoc
class _$ChatHomeStateCopyWithImpl<$Res>
    implements $ChatHomeStateCopyWith<$Res> {
  _$ChatHomeStateCopyWithImpl(this._self, this._then);

  final ChatHomeState _self;
  final $Res Function(ChatHomeState) _then;

/// Create a copy of ChatHomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? repository = freezed,Object? connection = null,Object? initializing = null,Object? errorMessage = freezed,Object? conversations = null,Object? actionError = freezed,Object? errorSeq = null,}) {
  return _then(_self.copyWith(
repository: freezed == repository ? _self.repository : repository // ignore: cast_nullable_to_non_nullable
as ChatRepository?,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as ChatConnection,initializing: null == initializing ? _self.initializing : initializing // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,conversations: null == conversations ? _self.conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<ChatConversation>,actionError: freezed == actionError ? _self.actionError : actionError // ignore: cast_nullable_to_non_nullable
as String?,errorSeq: null == errorSeq ? _self.errorSeq : errorSeq // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatHomeState].
extension ChatHomeStatePatterns on ChatHomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatHomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatHomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatHomeState value)  $default,){
final _that = this;
switch (_that) {
case _ChatHomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatHomeState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatHomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatRepository? repository,  ChatConnection connection,  bool initializing,  String? errorMessage,  List<ChatConversation> conversations,  String? actionError,  int errorSeq)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatHomeState() when $default != null:
return $default(_that.repository,_that.connection,_that.initializing,_that.errorMessage,_that.conversations,_that.actionError,_that.errorSeq);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatRepository? repository,  ChatConnection connection,  bool initializing,  String? errorMessage,  List<ChatConversation> conversations,  String? actionError,  int errorSeq)  $default,) {final _that = this;
switch (_that) {
case _ChatHomeState():
return $default(_that.repository,_that.connection,_that.initializing,_that.errorMessage,_that.conversations,_that.actionError,_that.errorSeq);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatRepository? repository,  ChatConnection connection,  bool initializing,  String? errorMessage,  List<ChatConversation> conversations,  String? actionError,  int errorSeq)?  $default,) {final _that = this;
switch (_that) {
case _ChatHomeState() when $default != null:
return $default(_that.repository,_that.connection,_that.initializing,_that.errorMessage,_that.conversations,_that.actionError,_that.errorSeq);case _:
  return null;

}
}

}

/// @nodoc


class _ChatHomeState implements ChatHomeState {
  const _ChatHomeState({this.repository, this.connection = ChatConnection.background, this.initializing = false, this.errorMessage, final  List<ChatConversation> conversations = const [], this.actionError, this.errorSeq = 0}): _conversations = conversations;
  

@override final  ChatRepository? repository;
@override@JsonKey() final  ChatConnection connection;
@override@JsonKey() final  bool initializing;
@override final  String? errorMessage;
 final  List<ChatConversation> _conversations;
@override@JsonKey() List<ChatConversation> get conversations {
  if (_conversations is EqualUnmodifiableListView) return _conversations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conversations);
}

@override final  String? actionError;
@override@JsonKey() final  int errorSeq;

/// Create a copy of ChatHomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatHomeStateCopyWith<_ChatHomeState> get copyWith => __$ChatHomeStateCopyWithImpl<_ChatHomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatHomeState&&(identical(other.repository, repository) || other.repository == repository)&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.initializing, initializing) || other.initializing == initializing)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other._conversations, _conversations)&&(identical(other.actionError, actionError) || other.actionError == actionError)&&(identical(other.errorSeq, errorSeq) || other.errorSeq == errorSeq));
}


@override
int get hashCode => Object.hash(runtimeType,repository,connection,initializing,errorMessage,const DeepCollectionEquality().hash(_conversations),actionError,errorSeq);

@override
String toString() {
  return 'ChatHomeState(repository: $repository, connection: $connection, initializing: $initializing, errorMessage: $errorMessage, conversations: $conversations, actionError: $actionError, errorSeq: $errorSeq)';
}


}

/// @nodoc
abstract mixin class _$ChatHomeStateCopyWith<$Res> implements $ChatHomeStateCopyWith<$Res> {
  factory _$ChatHomeStateCopyWith(_ChatHomeState value, $Res Function(_ChatHomeState) _then) = __$ChatHomeStateCopyWithImpl;
@override @useResult
$Res call({
 ChatRepository? repository, ChatConnection connection, bool initializing, String? errorMessage, List<ChatConversation> conversations, String? actionError, int errorSeq
});




}
/// @nodoc
class __$ChatHomeStateCopyWithImpl<$Res>
    implements _$ChatHomeStateCopyWith<$Res> {
  __$ChatHomeStateCopyWithImpl(this._self, this._then);

  final _ChatHomeState _self;
  final $Res Function(_ChatHomeState) _then;

/// Create a copy of ChatHomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? repository = freezed,Object? connection = null,Object? initializing = null,Object? errorMessage = freezed,Object? conversations = null,Object? actionError = freezed,Object? errorSeq = null,}) {
  return _then(_ChatHomeState(
repository: freezed == repository ? _self.repository : repository // ignore: cast_nullable_to_non_nullable
as ChatRepository?,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as ChatConnection,initializing: null == initializing ? _self.initializing : initializing // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,conversations: null == conversations ? _self._conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<ChatConversation>,actionError: freezed == actionError ? _self.actionError : actionError // ignore: cast_nullable_to_non_nullable
as String?,errorSeq: null == errorSeq ? _self.errorSeq : errorSeq // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ChatDetailState {

 ChatRepository? get repository; String? get myUserId; String? get peerUserId; String? get peerNickname; int get peerReadSeq; ChatConnection get connection; List<ChatMessage> get messages; List<PendingMessage> get pending; Set<String> get sending; bool get hasMore; bool get loadingMore; String? get actionError; int get errorSeq;
/// Create a copy of ChatDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatDetailStateCopyWith<ChatDetailState> get copyWith => _$ChatDetailStateCopyWithImpl<ChatDetailState>(this as ChatDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatDetailState&&(identical(other.repository, repository) || other.repository == repository)&&(identical(other.myUserId, myUserId) || other.myUserId == myUserId)&&(identical(other.peerUserId, peerUserId) || other.peerUserId == peerUserId)&&(identical(other.peerNickname, peerNickname) || other.peerNickname == peerNickname)&&(identical(other.peerReadSeq, peerReadSeq) || other.peerReadSeq == peerReadSeq)&&(identical(other.connection, connection) || other.connection == connection)&&const DeepCollectionEquality().equals(other.messages, messages)&&const DeepCollectionEquality().equals(other.pending, pending)&&const DeepCollectionEquality().equals(other.sending, sending)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore)&&(identical(other.actionError, actionError) || other.actionError == actionError)&&(identical(other.errorSeq, errorSeq) || other.errorSeq == errorSeq));
}


@override
int get hashCode => Object.hash(runtimeType,repository,myUserId,peerUserId,peerNickname,peerReadSeq,connection,const DeepCollectionEquality().hash(messages),const DeepCollectionEquality().hash(pending),const DeepCollectionEquality().hash(sending),hasMore,loadingMore,actionError,errorSeq);

@override
String toString() {
  return 'ChatDetailState(repository: $repository, myUserId: $myUserId, peerUserId: $peerUserId, peerNickname: $peerNickname, peerReadSeq: $peerReadSeq, connection: $connection, messages: $messages, pending: $pending, sending: $sending, hasMore: $hasMore, loadingMore: $loadingMore, actionError: $actionError, errorSeq: $errorSeq)';
}


}

/// @nodoc
abstract mixin class $ChatDetailStateCopyWith<$Res>  {
  factory $ChatDetailStateCopyWith(ChatDetailState value, $Res Function(ChatDetailState) _then) = _$ChatDetailStateCopyWithImpl;
@useResult
$Res call({
 ChatRepository? repository, String? myUserId, String? peerUserId, String? peerNickname, int peerReadSeq, ChatConnection connection, List<ChatMessage> messages, List<PendingMessage> pending, Set<String> sending, bool hasMore, bool loadingMore, String? actionError, int errorSeq
});




}
/// @nodoc
class _$ChatDetailStateCopyWithImpl<$Res>
    implements $ChatDetailStateCopyWith<$Res> {
  _$ChatDetailStateCopyWithImpl(this._self, this._then);

  final ChatDetailState _self;
  final $Res Function(ChatDetailState) _then;

/// Create a copy of ChatDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? repository = freezed,Object? myUserId = freezed,Object? peerUserId = freezed,Object? peerNickname = freezed,Object? peerReadSeq = null,Object? connection = null,Object? messages = null,Object? pending = null,Object? sending = null,Object? hasMore = null,Object? loadingMore = null,Object? actionError = freezed,Object? errorSeq = null,}) {
  return _then(_self.copyWith(
repository: freezed == repository ? _self.repository : repository // ignore: cast_nullable_to_non_nullable
as ChatRepository?,myUserId: freezed == myUserId ? _self.myUserId : myUserId // ignore: cast_nullable_to_non_nullable
as String?,peerUserId: freezed == peerUserId ? _self.peerUserId : peerUserId // ignore: cast_nullable_to_non_nullable
as String?,peerNickname: freezed == peerNickname ? _self.peerNickname : peerNickname // ignore: cast_nullable_to_non_nullable
as String?,peerReadSeq: null == peerReadSeq ? _self.peerReadSeq : peerReadSeq // ignore: cast_nullable_to_non_nullable
as int,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as ChatConnection,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as List<PendingMessage>,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as Set<String>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,actionError: freezed == actionError ? _self.actionError : actionError // ignore: cast_nullable_to_non_nullable
as String?,errorSeq: null == errorSeq ? _self.errorSeq : errorSeq // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatDetailState].
extension ChatDetailStatePatterns on ChatDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatDetailState value)  $default,){
final _that = this;
switch (_that) {
case _ChatDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatRepository? repository,  String? myUserId,  String? peerUserId,  String? peerNickname,  int peerReadSeq,  ChatConnection connection,  List<ChatMessage> messages,  List<PendingMessage> pending,  Set<String> sending,  bool hasMore,  bool loadingMore,  String? actionError,  int errorSeq)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatDetailState() when $default != null:
return $default(_that.repository,_that.myUserId,_that.peerUserId,_that.peerNickname,_that.peerReadSeq,_that.connection,_that.messages,_that.pending,_that.sending,_that.hasMore,_that.loadingMore,_that.actionError,_that.errorSeq);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatRepository? repository,  String? myUserId,  String? peerUserId,  String? peerNickname,  int peerReadSeq,  ChatConnection connection,  List<ChatMessage> messages,  List<PendingMessage> pending,  Set<String> sending,  bool hasMore,  bool loadingMore,  String? actionError,  int errorSeq)  $default,) {final _that = this;
switch (_that) {
case _ChatDetailState():
return $default(_that.repository,_that.myUserId,_that.peerUserId,_that.peerNickname,_that.peerReadSeq,_that.connection,_that.messages,_that.pending,_that.sending,_that.hasMore,_that.loadingMore,_that.actionError,_that.errorSeq);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatRepository? repository,  String? myUserId,  String? peerUserId,  String? peerNickname,  int peerReadSeq,  ChatConnection connection,  List<ChatMessage> messages,  List<PendingMessage> pending,  Set<String> sending,  bool hasMore,  bool loadingMore,  String? actionError,  int errorSeq)?  $default,) {final _that = this;
switch (_that) {
case _ChatDetailState() when $default != null:
return $default(_that.repository,_that.myUserId,_that.peerUserId,_that.peerNickname,_that.peerReadSeq,_that.connection,_that.messages,_that.pending,_that.sending,_that.hasMore,_that.loadingMore,_that.actionError,_that.errorSeq);case _:
  return null;

}
}

}

/// @nodoc


class _ChatDetailState implements ChatDetailState {
  const _ChatDetailState({this.repository, this.myUserId, this.peerUserId, this.peerNickname, this.peerReadSeq = 0, this.connection = ChatConnection.background, final  List<ChatMessage> messages = const [], final  List<PendingMessage> pending = const [], final  Set<String> sending = const <String>{}, this.hasMore = true, this.loadingMore = false, this.actionError, this.errorSeq = 0}): _messages = messages,_pending = pending,_sending = sending;
  

@override final  ChatRepository? repository;
@override final  String? myUserId;
@override final  String? peerUserId;
@override final  String? peerNickname;
@override@JsonKey() final  int peerReadSeq;
@override@JsonKey() final  ChatConnection connection;
 final  List<ChatMessage> _messages;
@override@JsonKey() List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  List<PendingMessage> _pending;
@override@JsonKey() List<PendingMessage> get pending {
  if (_pending is EqualUnmodifiableListView) return _pending;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pending);
}

 final  Set<String> _sending;
@override@JsonKey() Set<String> get sending {
  if (_sending is EqualUnmodifiableSetView) return _sending;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_sending);
}

@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  bool loadingMore;
@override final  String? actionError;
@override@JsonKey() final  int errorSeq;

/// Create a copy of ChatDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatDetailStateCopyWith<_ChatDetailState> get copyWith => __$ChatDetailStateCopyWithImpl<_ChatDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatDetailState&&(identical(other.repository, repository) || other.repository == repository)&&(identical(other.myUserId, myUserId) || other.myUserId == myUserId)&&(identical(other.peerUserId, peerUserId) || other.peerUserId == peerUserId)&&(identical(other.peerNickname, peerNickname) || other.peerNickname == peerNickname)&&(identical(other.peerReadSeq, peerReadSeq) || other.peerReadSeq == peerReadSeq)&&(identical(other.connection, connection) || other.connection == connection)&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._pending, _pending)&&const DeepCollectionEquality().equals(other._sending, _sending)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore)&&(identical(other.actionError, actionError) || other.actionError == actionError)&&(identical(other.errorSeq, errorSeq) || other.errorSeq == errorSeq));
}


@override
int get hashCode => Object.hash(runtimeType,repository,myUserId,peerUserId,peerNickname,peerReadSeq,connection,const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_pending),const DeepCollectionEquality().hash(_sending),hasMore,loadingMore,actionError,errorSeq);

@override
String toString() {
  return 'ChatDetailState(repository: $repository, myUserId: $myUserId, peerUserId: $peerUserId, peerNickname: $peerNickname, peerReadSeq: $peerReadSeq, connection: $connection, messages: $messages, pending: $pending, sending: $sending, hasMore: $hasMore, loadingMore: $loadingMore, actionError: $actionError, errorSeq: $errorSeq)';
}


}

/// @nodoc
abstract mixin class _$ChatDetailStateCopyWith<$Res> implements $ChatDetailStateCopyWith<$Res> {
  factory _$ChatDetailStateCopyWith(_ChatDetailState value, $Res Function(_ChatDetailState) _then) = __$ChatDetailStateCopyWithImpl;
@override @useResult
$Res call({
 ChatRepository? repository, String? myUserId, String? peerUserId, String? peerNickname, int peerReadSeq, ChatConnection connection, List<ChatMessage> messages, List<PendingMessage> pending, Set<String> sending, bool hasMore, bool loadingMore, String? actionError, int errorSeq
});




}
/// @nodoc
class __$ChatDetailStateCopyWithImpl<$Res>
    implements _$ChatDetailStateCopyWith<$Res> {
  __$ChatDetailStateCopyWithImpl(this._self, this._then);

  final _ChatDetailState _self;
  final $Res Function(_ChatDetailState) _then;

/// Create a copy of ChatDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? repository = freezed,Object? myUserId = freezed,Object? peerUserId = freezed,Object? peerNickname = freezed,Object? peerReadSeq = null,Object? connection = null,Object? messages = null,Object? pending = null,Object? sending = null,Object? hasMore = null,Object? loadingMore = null,Object? actionError = freezed,Object? errorSeq = null,}) {
  return _then(_ChatDetailState(
repository: freezed == repository ? _self.repository : repository // ignore: cast_nullable_to_non_nullable
as ChatRepository?,myUserId: freezed == myUserId ? _self.myUserId : myUserId // ignore: cast_nullable_to_non_nullable
as String?,peerUserId: freezed == peerUserId ? _self.peerUserId : peerUserId // ignore: cast_nullable_to_non_nullable
as String?,peerNickname: freezed == peerNickname ? _self.peerNickname : peerNickname // ignore: cast_nullable_to_non_nullable
as String?,peerReadSeq: null == peerReadSeq ? _self.peerReadSeq : peerReadSeq // ignore: cast_nullable_to_non_nullable
as int,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as ChatConnection,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,pending: null == pending ? _self._pending : pending // ignore: cast_nullable_to_non_nullable
as List<PendingMessage>,sending: null == sending ? _self._sending : sending // ignore: cast_nullable_to_non_nullable
as Set<String>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,actionError: freezed == actionError ? _self.actionError : actionError // ignore: cast_nullable_to_non_nullable
as String?,errorSeq: null == errorSeq ? _self.errorSeq : errorSeq // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
