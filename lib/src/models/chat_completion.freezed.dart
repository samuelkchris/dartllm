// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_completion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatCompletion {
  /// The generated assistant message.
  AssistantMessage get message;

  /// Token usage statistics for this request.
  UsageStats get usage;

  /// The reason generation stopped.
  FinishReason get finishReason;

  /// Time spent generating the response in milliseconds.
  int get generationTimeMs;

  /// Create a copy of ChatCompletion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatCompletionCopyWith<ChatCompletion> get copyWith =>
      _$ChatCompletionCopyWithImpl<ChatCompletion>(
          this as ChatCompletion, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatCompletion &&
            const DeepCollectionEquality().equals(other.message, message) &&
            (identical(other.usage, usage) || other.usage == usage) &&
            (identical(other.finishReason, finishReason) ||
                other.finishReason == finishReason) &&
            (identical(other.generationTimeMs, generationTimeMs) ||
                other.generationTimeMs == generationTimeMs));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(message),
      usage,
      finishReason,
      generationTimeMs);

  @override
  String toString() {
    return 'ChatCompletion(message: $message, usage: $usage, finishReason: $finishReason, generationTimeMs: $generationTimeMs)';
  }
}

/// @nodoc
abstract mixin class $ChatCompletionCopyWith<$Res> {
  factory $ChatCompletionCopyWith(
          ChatCompletion value, $Res Function(ChatCompletion) _then) =
      _$ChatCompletionCopyWithImpl;
  @useResult
  $Res call(
      {AssistantMessage message,
      UsageStats usage,
      FinishReason finishReason,
      int generationTimeMs});

  $UsageStatsCopyWith<$Res> get usage;
}

/// @nodoc
class _$ChatCompletionCopyWithImpl<$Res>
    implements $ChatCompletionCopyWith<$Res> {
  _$ChatCompletionCopyWithImpl(this._self, this._then);

  final ChatCompletion _self;
  final $Res Function(ChatCompletion) _then;

  /// Create a copy of ChatCompletion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? usage = null,
    Object? finishReason = null,
    Object? generationTimeMs = null,
  }) {
    return _then(_self.copyWith(
      message: freezed == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as AssistantMessage,
      usage: null == usage
          ? _self.usage
          : usage // ignore: cast_nullable_to_non_nullable
              as UsageStats,
      finishReason: null == finishReason
          ? _self.finishReason
          : finishReason // ignore: cast_nullable_to_non_nullable
              as FinishReason,
      generationTimeMs: null == generationTimeMs
          ? _self.generationTimeMs
          : generationTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of ChatCompletion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UsageStatsCopyWith<$Res> get usage {
    return $UsageStatsCopyWith<$Res>(_self.usage, (value) {
      return _then(_self.copyWith(usage: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ChatCompletion].
extension ChatCompletionPatterns on ChatCompletion {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ChatCompletion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatCompletion() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_ChatCompletion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatCompletion():
        return $default(_that);
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ChatCompletion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatCompletion() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(AssistantMessage message, UsageStats usage,
            FinishReason finishReason, int generationTimeMs)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatCompletion() when $default != null:
        return $default(_that.message, _that.usage, _that.finishReason,
            _that.generationTimeMs);
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
  TResult when<TResult extends Object?>(
    TResult Function(AssistantMessage message, UsageStats usage,
            FinishReason finishReason, int generationTimeMs)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatCompletion():
        return $default(_that.message, _that.usage, _that.finishReason,
            _that.generationTimeMs);
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(AssistantMessage message, UsageStats usage,
            FinishReason finishReason, int generationTimeMs)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatCompletion() when $default != null:
        return $default(_that.message, _that.usage, _that.finishReason,
            _that.generationTimeMs);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ChatCompletion extends ChatCompletion {
  const _ChatCompletion(
      {required this.message,
      required this.usage,
      required this.finishReason,
      required this.generationTimeMs})
      : super._();

  /// The generated assistant message.
  @override
  final AssistantMessage message;

  /// Token usage statistics for this request.
  @override
  final UsageStats usage;

  /// The reason generation stopped.
  @override
  final FinishReason finishReason;

  /// Time spent generating the response in milliseconds.
  @override
  final int generationTimeMs;

  /// Create a copy of ChatCompletion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatCompletionCopyWith<_ChatCompletion> get copyWith =>
      __$ChatCompletionCopyWithImpl<_ChatCompletion>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChatCompletion &&
            const DeepCollectionEquality().equals(other.message, message) &&
            (identical(other.usage, usage) || other.usage == usage) &&
            (identical(other.finishReason, finishReason) ||
                other.finishReason == finishReason) &&
            (identical(other.generationTimeMs, generationTimeMs) ||
                other.generationTimeMs == generationTimeMs));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(message),
      usage,
      finishReason,
      generationTimeMs);

  @override
  String toString() {
    return 'ChatCompletion(message: $message, usage: $usage, finishReason: $finishReason, generationTimeMs: $generationTimeMs)';
  }
}

/// @nodoc
abstract mixin class _$ChatCompletionCopyWith<$Res>
    implements $ChatCompletionCopyWith<$Res> {
  factory _$ChatCompletionCopyWith(
          _ChatCompletion value, $Res Function(_ChatCompletion) _then) =
      __$ChatCompletionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {AssistantMessage message,
      UsageStats usage,
      FinishReason finishReason,
      int generationTimeMs});

  @override
  $UsageStatsCopyWith<$Res> get usage;
}

/// @nodoc
class __$ChatCompletionCopyWithImpl<$Res>
    implements _$ChatCompletionCopyWith<$Res> {
  __$ChatCompletionCopyWithImpl(this._self, this._then);

  final _ChatCompletion _self;
  final $Res Function(_ChatCompletion) _then;

  /// Create a copy of ChatCompletion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = freezed,
    Object? usage = null,
    Object? finishReason = null,
    Object? generationTimeMs = null,
  }) {
    return _then(_ChatCompletion(
      message: freezed == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as AssistantMessage,
      usage: null == usage
          ? _self.usage
          : usage // ignore: cast_nullable_to_non_nullable
              as UsageStats,
      finishReason: null == finishReason
          ? _self.finishReason
          : finishReason // ignore: cast_nullable_to_non_nullable
              as FinishReason,
      generationTimeMs: null == generationTimeMs
          ? _self.generationTimeMs
          : generationTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of ChatCompletion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UsageStatsCopyWith<$Res> get usage {
    return $UsageStatsCopyWith<$Res>(_self.usage, (value) {
      return _then(_self.copyWith(usage: value));
    });
  }
}

/// @nodoc
mixin _$ChatCompletionChunk {
  /// The incremental content in this chunk.
  MessageDelta get delta;

  /// The reason generation stopped, if this is the final chunk.
  ///
  /// Null for all chunks except the last one.
  FinishReason? get finishReason;

  /// Create a copy of ChatCompletionChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatCompletionChunkCopyWith<ChatCompletionChunk> get copyWith =>
      _$ChatCompletionChunkCopyWithImpl<ChatCompletionChunk>(
          this as ChatCompletionChunk, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatCompletionChunk &&
            (identical(other.delta, delta) || other.delta == delta) &&
            (identical(other.finishReason, finishReason) ||
                other.finishReason == finishReason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, delta, finishReason);

  @override
  String toString() {
    return 'ChatCompletionChunk(delta: $delta, finishReason: $finishReason)';
  }
}

/// @nodoc
abstract mixin class $ChatCompletionChunkCopyWith<$Res> {
  factory $ChatCompletionChunkCopyWith(
          ChatCompletionChunk value, $Res Function(ChatCompletionChunk) _then) =
      _$ChatCompletionChunkCopyWithImpl;
  @useResult
  $Res call({MessageDelta delta, FinishReason? finishReason});

  $MessageDeltaCopyWith<$Res> get delta;
}

/// @nodoc
class _$ChatCompletionChunkCopyWithImpl<$Res>
    implements $ChatCompletionChunkCopyWith<$Res> {
  _$ChatCompletionChunkCopyWithImpl(this._self, this._then);

  final ChatCompletionChunk _self;
  final $Res Function(ChatCompletionChunk) _then;

  /// Create a copy of ChatCompletionChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? delta = null,
    Object? finishReason = freezed,
  }) {
    return _then(_self.copyWith(
      delta: null == delta
          ? _self.delta
          : delta // ignore: cast_nullable_to_non_nullable
              as MessageDelta,
      finishReason: freezed == finishReason
          ? _self.finishReason
          : finishReason // ignore: cast_nullable_to_non_nullable
              as FinishReason?,
    ));
  }

  /// Create a copy of ChatCompletionChunk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageDeltaCopyWith<$Res> get delta {
    return $MessageDeltaCopyWith<$Res>(_self.delta, (value) {
      return _then(_self.copyWith(delta: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ChatCompletionChunk].
extension ChatCompletionChunkPatterns on ChatCompletionChunk {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ChatCompletionChunk value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatCompletionChunk() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_ChatCompletionChunk value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatCompletionChunk():
        return $default(_that);
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ChatCompletionChunk value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatCompletionChunk() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(MessageDelta delta, FinishReason? finishReason)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatCompletionChunk() when $default != null:
        return $default(_that.delta, _that.finishReason);
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
  TResult when<TResult extends Object?>(
    TResult Function(MessageDelta delta, FinishReason? finishReason) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatCompletionChunk():
        return $default(_that.delta, _that.finishReason);
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(MessageDelta delta, FinishReason? finishReason)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatCompletionChunk() when $default != null:
        return $default(_that.delta, _that.finishReason);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ChatCompletionChunk extends ChatCompletionChunk {
  const _ChatCompletionChunk({required this.delta, this.finishReason})
      : super._();

  /// The incremental content in this chunk.
  @override
  final MessageDelta delta;

  /// The reason generation stopped, if this is the final chunk.
  ///
  /// Null for all chunks except the last one.
  @override
  final FinishReason? finishReason;

  /// Create a copy of ChatCompletionChunk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatCompletionChunkCopyWith<_ChatCompletionChunk> get copyWith =>
      __$ChatCompletionChunkCopyWithImpl<_ChatCompletionChunk>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChatCompletionChunk &&
            (identical(other.delta, delta) || other.delta == delta) &&
            (identical(other.finishReason, finishReason) ||
                other.finishReason == finishReason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, delta, finishReason);

  @override
  String toString() {
    return 'ChatCompletionChunk(delta: $delta, finishReason: $finishReason)';
  }
}

/// @nodoc
abstract mixin class _$ChatCompletionChunkCopyWith<$Res>
    implements $ChatCompletionChunkCopyWith<$Res> {
  factory _$ChatCompletionChunkCopyWith(_ChatCompletionChunk value,
          $Res Function(_ChatCompletionChunk) _then) =
      __$ChatCompletionChunkCopyWithImpl;
  @override
  @useResult
  $Res call({MessageDelta delta, FinishReason? finishReason});

  @override
  $MessageDeltaCopyWith<$Res> get delta;
}

/// @nodoc
class __$ChatCompletionChunkCopyWithImpl<$Res>
    implements _$ChatCompletionChunkCopyWith<$Res> {
  __$ChatCompletionChunkCopyWithImpl(this._self, this._then);

  final _ChatCompletionChunk _self;
  final $Res Function(_ChatCompletionChunk) _then;

  /// Create a copy of ChatCompletionChunk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? delta = null,
    Object? finishReason = freezed,
  }) {
    return _then(_ChatCompletionChunk(
      delta: null == delta
          ? _self.delta
          : delta // ignore: cast_nullable_to_non_nullable
              as MessageDelta,
      finishReason: freezed == finishReason
          ? _self.finishReason
          : finishReason // ignore: cast_nullable_to_non_nullable
              as FinishReason?,
    ));
  }

  /// Create a copy of ChatCompletionChunk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageDeltaCopyWith<$Res> get delta {
    return $MessageDeltaCopyWith<$Res>(_self.delta, (value) {
      return _then(_self.copyWith(delta: value));
    });
  }
}

/// @nodoc
mixin _$MessageDelta {
  /// The new content generated in this chunk.
  ///
  /// May be empty for the initial chunk or partial tokens.
  String get content;

  /// The role of the message being generated.
  ///
  /// Typically only present in the first chunk.
  MessageRole? get role;

  /// Create a copy of MessageDelta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MessageDeltaCopyWith<MessageDelta> get copyWith =>
      _$MessageDeltaCopyWithImpl<MessageDelta>(
          this as MessageDelta, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MessageDelta &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.role, role) || other.role == role));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content, role);

  @override
  String toString() {
    return 'MessageDelta(content: $content, role: $role)';
  }
}

/// @nodoc
abstract mixin class $MessageDeltaCopyWith<$Res> {
  factory $MessageDeltaCopyWith(
          MessageDelta value, $Res Function(MessageDelta) _then) =
      _$MessageDeltaCopyWithImpl;
  @useResult
  $Res call({String content, MessageRole? role});
}

/// @nodoc
class _$MessageDeltaCopyWithImpl<$Res> implements $MessageDeltaCopyWith<$Res> {
  _$MessageDeltaCopyWithImpl(this._self, this._then);

  final MessageDelta _self;
  final $Res Function(MessageDelta) _then;

  /// Create a copy of MessageDelta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? role = freezed,
  }) {
    return _then(_self.copyWith(
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      role: freezed == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as MessageRole?,
    ));
  }
}

/// Adds pattern-matching-related methods to [MessageDelta].
extension MessageDeltaPatterns on MessageDelta {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MessageDelta value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MessageDelta() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_MessageDelta value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageDelta():
        return $default(_that);
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MessageDelta value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageDelta() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String content, MessageRole? role)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MessageDelta() when $default != null:
        return $default(_that.content, _that.role);
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
  TResult when<TResult extends Object?>(
    TResult Function(String content, MessageRole? role) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageDelta():
        return $default(_that.content, _that.role);
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String content, MessageRole? role)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageDelta() when $default != null:
        return $default(_that.content, _that.role);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MessageDelta extends MessageDelta {
  const _MessageDelta({this.content = '', this.role}) : super._();

  /// The new content generated in this chunk.
  ///
  /// May be empty for the initial chunk or partial tokens.
  @override
  @JsonKey()
  final String content;

  /// The role of the message being generated.
  ///
  /// Typically only present in the first chunk.
  @override
  final MessageRole? role;

  /// Create a copy of MessageDelta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MessageDeltaCopyWith<_MessageDelta> get copyWith =>
      __$MessageDeltaCopyWithImpl<_MessageDelta>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MessageDelta &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.role, role) || other.role == role));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content, role);

  @override
  String toString() {
    return 'MessageDelta(content: $content, role: $role)';
  }
}

/// @nodoc
abstract mixin class _$MessageDeltaCopyWith<$Res>
    implements $MessageDeltaCopyWith<$Res> {
  factory _$MessageDeltaCopyWith(
          _MessageDelta value, $Res Function(_MessageDelta) _then) =
      __$MessageDeltaCopyWithImpl;
  @override
  @useResult
  $Res call({String content, MessageRole? role});
}

/// @nodoc
class __$MessageDeltaCopyWithImpl<$Res>
    implements _$MessageDeltaCopyWith<$Res> {
  __$MessageDeltaCopyWithImpl(this._self, this._then);

  final _MessageDelta _self;
  final $Res Function(_MessageDelta) _then;

  /// Create a copy of MessageDelta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? content = null,
    Object? role = freezed,
  }) {
    return _then(_MessageDelta(
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      role: freezed == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as MessageRole?,
    ));
  }
}

// dart format on
