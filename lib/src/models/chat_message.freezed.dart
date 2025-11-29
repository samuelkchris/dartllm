// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessage {
  String get content;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatMessage &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content);

  @override
  String toString() {
    return 'ChatMessage(content: $content)';
  }
}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) _then) =
      _$ChatMessageCopyWithImpl;
  @useResult
  $Res call({String content});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res> implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
  }) {
    return _then(_self.copyWith(
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SystemMessage value)? system,
    TResult Function(UserMessage value)? user,
    TResult Function(UserImageMessage value)? userWithImage,
    TResult Function(AssistantMessage value)? assistant,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SystemMessage() when system != null:
        return system(_that);
      case UserMessage() when user != null:
        return user(_that);
      case UserImageMessage() when userWithImage != null:
        return userWithImage(_that);
      case AssistantMessage() when assistant != null:
        return assistant(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SystemMessage value) system,
    required TResult Function(UserMessage value) user,
    required TResult Function(UserImageMessage value) userWithImage,
    required TResult Function(AssistantMessage value) assistant,
  }) {
    final _that = this;
    switch (_that) {
      case SystemMessage():
        return system(_that);
      case UserMessage():
        return user(_that);
      case UserImageMessage():
        return userWithImage(_that);
      case AssistantMessage():
        return assistant(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SystemMessage value)? system,
    TResult? Function(UserMessage value)? user,
    TResult? Function(UserImageMessage value)? userWithImage,
    TResult? Function(AssistantMessage value)? assistant,
  }) {
    final _that = this;
    switch (_that) {
      case SystemMessage() when system != null:
        return system(_that);
      case UserMessage() when user != null:
        return user(_that);
      case UserImageMessage() when userWithImage != null:
        return userWithImage(_that);
      case AssistantMessage() when assistant != null:
        return assistant(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String content)? system,
    TResult Function(String content)? user,
    TResult Function(String content, Uint8List imageData, String mimeType)?
        userWithImage,
    TResult Function(String content)? assistant,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SystemMessage() when system != null:
        return system(_that.content);
      case UserMessage() when user != null:
        return user(_that.content);
      case UserImageMessage() when userWithImage != null:
        return userWithImage(_that.content, _that.imageData, _that.mimeType);
      case AssistantMessage() when assistant != null:
        return assistant(_that.content);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String content) system,
    required TResult Function(String content) user,
    required TResult Function(
            String content, Uint8List imageData, String mimeType)
        userWithImage,
    required TResult Function(String content) assistant,
  }) {
    final _that = this;
    switch (_that) {
      case SystemMessage():
        return system(_that.content);
      case UserMessage():
        return user(_that.content);
      case UserImageMessage():
        return userWithImage(_that.content, _that.imageData, _that.mimeType);
      case AssistantMessage():
        return assistant(_that.content);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String content)? system,
    TResult? Function(String content)? user,
    TResult? Function(String content, Uint8List imageData, String mimeType)?
        userWithImage,
    TResult? Function(String content)? assistant,
  }) {
    final _that = this;
    switch (_that) {
      case SystemMessage() when system != null:
        return system(_that.content);
      case UserMessage() when user != null:
        return user(_that.content);
      case UserImageMessage() when userWithImage != null:
        return userWithImage(_that.content, _that.imageData, _that.mimeType);
      case AssistantMessage() when assistant != null:
        return assistant(_that.content);
      case _:
        return null;
    }
  }
}

/// @nodoc

class SystemMessage extends ChatMessage {
  const SystemMessage(this.content) : super._();

  @override
  final String content;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SystemMessageCopyWith<SystemMessage> get copyWith =>
      _$SystemMessageCopyWithImpl<SystemMessage>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SystemMessage &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content);

  @override
  String toString() {
    return 'ChatMessage.system(content: $content)';
  }
}

/// @nodoc
abstract mixin class $SystemMessageCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory $SystemMessageCopyWith(
          SystemMessage value, $Res Function(SystemMessage) _then) =
      _$SystemMessageCopyWithImpl;
  @override
  @useResult
  $Res call({String content});
}

/// @nodoc
class _$SystemMessageCopyWithImpl<$Res>
    implements $SystemMessageCopyWith<$Res> {
  _$SystemMessageCopyWithImpl(this._self, this._then);

  final SystemMessage _self;
  final $Res Function(SystemMessage) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? content = null,
  }) {
    return _then(SystemMessage(
      null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class UserMessage extends ChatMessage {
  const UserMessage(this.content) : super._();

  @override
  final String content;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserMessageCopyWith<UserMessage> get copyWith =>
      _$UserMessageCopyWithImpl<UserMessage>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserMessage &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content);

  @override
  String toString() {
    return 'ChatMessage.user(content: $content)';
  }
}

/// @nodoc
abstract mixin class $UserMessageCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory $UserMessageCopyWith(
          UserMessage value, $Res Function(UserMessage) _then) =
      _$UserMessageCopyWithImpl;
  @override
  @useResult
  $Res call({String content});
}

/// @nodoc
class _$UserMessageCopyWithImpl<$Res> implements $UserMessageCopyWith<$Res> {
  _$UserMessageCopyWithImpl(this._self, this._then);

  final UserMessage _self;
  final $Res Function(UserMessage) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? content = null,
  }) {
    return _then(UserMessage(
      null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class UserImageMessage extends ChatMessage {
  const UserImageMessage(this.content, this.imageData,
      {this.mimeType = 'image/jpeg'})
      : super._();

  @override
  final String content;
  final Uint8List imageData;
  @JsonKey()
  final String mimeType;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserImageMessageCopyWith<UserImageMessage> get copyWith =>
      _$UserImageMessageCopyWithImpl<UserImageMessage>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserImageMessage &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other.imageData, imageData) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content,
      const DeepCollectionEquality().hash(imageData), mimeType);

  @override
  String toString() {
    return 'ChatMessage.userWithImage(content: $content, imageData: $imageData, mimeType: $mimeType)';
  }
}

/// @nodoc
abstract mixin class $UserImageMessageCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory $UserImageMessageCopyWith(
          UserImageMessage value, $Res Function(UserImageMessage) _then) =
      _$UserImageMessageCopyWithImpl;
  @override
  @useResult
  $Res call({String content, Uint8List imageData, String mimeType});
}

/// @nodoc
class _$UserImageMessageCopyWithImpl<$Res>
    implements $UserImageMessageCopyWith<$Res> {
  _$UserImageMessageCopyWithImpl(this._self, this._then);

  final UserImageMessage _self;
  final $Res Function(UserImageMessage) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? content = null,
    Object? imageData = null,
    Object? mimeType = null,
  }) {
    return _then(UserImageMessage(
      null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      null == imageData
          ? _self.imageData
          : imageData // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      mimeType: null == mimeType
          ? _self.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class AssistantMessage extends ChatMessage {
  const AssistantMessage(this.content) : super._();

  @override
  final String content;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AssistantMessageCopyWith<AssistantMessage> get copyWith =>
      _$AssistantMessageCopyWithImpl<AssistantMessage>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AssistantMessage &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content);

  @override
  String toString() {
    return 'ChatMessage.assistant(content: $content)';
  }
}

/// @nodoc
abstract mixin class $AssistantMessageCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory $AssistantMessageCopyWith(
          AssistantMessage value, $Res Function(AssistantMessage) _then) =
      _$AssistantMessageCopyWithImpl;
  @override
  @useResult
  $Res call({String content});
}

/// @nodoc
class _$AssistantMessageCopyWithImpl<$Res>
    implements $AssistantMessageCopyWith<$Res> {
  _$AssistantMessageCopyWithImpl(this._self, this._then);

  final AssistantMessage _self;
  final $Res Function(AssistantMessage) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? content = null,
  }) {
    return _then(AssistantMessage(
      null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
