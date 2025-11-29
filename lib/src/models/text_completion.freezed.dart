// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_completion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TextCompletion {
  /// The generated text continuation.
  String get text;

  /// Token usage statistics for this request.
  UsageStats get usage;

  /// The reason generation stopped.
  FinishReason get finishReason;

  /// Time spent generating the response in milliseconds.
  int get generationTimeMs;

  /// Create a copy of TextCompletion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TextCompletionCopyWith<TextCompletion> get copyWith =>
      _$TextCompletionCopyWithImpl<TextCompletion>(
          this as TextCompletion, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TextCompletion &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.usage, usage) || other.usage == usage) &&
            (identical(other.finishReason, finishReason) ||
                other.finishReason == finishReason) &&
            (identical(other.generationTimeMs, generationTimeMs) ||
                other.generationTimeMs == generationTimeMs));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, text, usage, finishReason, generationTimeMs);

  @override
  String toString() {
    return 'TextCompletion(text: $text, usage: $usage, finishReason: $finishReason, generationTimeMs: $generationTimeMs)';
  }
}

/// @nodoc
abstract mixin class $TextCompletionCopyWith<$Res> {
  factory $TextCompletionCopyWith(
          TextCompletion value, $Res Function(TextCompletion) _then) =
      _$TextCompletionCopyWithImpl;
  @useResult
  $Res call(
      {String text,
      UsageStats usage,
      FinishReason finishReason,
      int generationTimeMs});

  $UsageStatsCopyWith<$Res> get usage;
}

/// @nodoc
class _$TextCompletionCopyWithImpl<$Res>
    implements $TextCompletionCopyWith<$Res> {
  _$TextCompletionCopyWithImpl(this._self, this._then);

  final TextCompletion _self;
  final $Res Function(TextCompletion) _then;

  /// Create a copy of TextCompletion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? usage = null,
    Object? finishReason = null,
    Object? generationTimeMs = null,
  }) {
    return _then(_self.copyWith(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
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

  /// Create a copy of TextCompletion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UsageStatsCopyWith<$Res> get usage {
    return $UsageStatsCopyWith<$Res>(_self.usage, (value) {
      return _then(_self.copyWith(usage: value));
    });
  }
}

/// Adds pattern-matching-related methods to [TextCompletion].
extension TextCompletionPatterns on TextCompletion {
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
    TResult Function(_TextCompletion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TextCompletion() when $default != null:
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
    TResult Function(_TextCompletion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextCompletion():
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
    TResult? Function(_TextCompletion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextCompletion() when $default != null:
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
    TResult Function(String text, UsageStats usage, FinishReason finishReason,
            int generationTimeMs)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TextCompletion() when $default != null:
        return $default(_that.text, _that.usage, _that.finishReason,
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
    TResult Function(String text, UsageStats usage, FinishReason finishReason,
            int generationTimeMs)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextCompletion():
        return $default(_that.text, _that.usage, _that.finishReason,
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
    TResult? Function(String text, UsageStats usage, FinishReason finishReason,
            int generationTimeMs)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextCompletion() when $default != null:
        return $default(_that.text, _that.usage, _that.finishReason,
            _that.generationTimeMs);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _TextCompletion extends TextCompletion {
  const _TextCompletion(
      {required this.text,
      required this.usage,
      required this.finishReason,
      required this.generationTimeMs})
      : super._();

  /// The generated text continuation.
  @override
  final String text;

  /// Token usage statistics for this request.
  @override
  final UsageStats usage;

  /// The reason generation stopped.
  @override
  final FinishReason finishReason;

  /// Time spent generating the response in milliseconds.
  @override
  final int generationTimeMs;

  /// Create a copy of TextCompletion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TextCompletionCopyWith<_TextCompletion> get copyWith =>
      __$TextCompletionCopyWithImpl<_TextCompletion>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TextCompletion &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.usage, usage) || other.usage == usage) &&
            (identical(other.finishReason, finishReason) ||
                other.finishReason == finishReason) &&
            (identical(other.generationTimeMs, generationTimeMs) ||
                other.generationTimeMs == generationTimeMs));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, text, usage, finishReason, generationTimeMs);

  @override
  String toString() {
    return 'TextCompletion(text: $text, usage: $usage, finishReason: $finishReason, generationTimeMs: $generationTimeMs)';
  }
}

/// @nodoc
abstract mixin class _$TextCompletionCopyWith<$Res>
    implements $TextCompletionCopyWith<$Res> {
  factory _$TextCompletionCopyWith(
          _TextCompletion value, $Res Function(_TextCompletion) _then) =
      __$TextCompletionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String text,
      UsageStats usage,
      FinishReason finishReason,
      int generationTimeMs});

  @override
  $UsageStatsCopyWith<$Res> get usage;
}

/// @nodoc
class __$TextCompletionCopyWithImpl<$Res>
    implements _$TextCompletionCopyWith<$Res> {
  __$TextCompletionCopyWithImpl(this._self, this._then);

  final _TextCompletion _self;
  final $Res Function(_TextCompletion) _then;

  /// Create a copy of TextCompletion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? text = null,
    Object? usage = null,
    Object? finishReason = null,
    Object? generationTimeMs = null,
  }) {
    return _then(_TextCompletion(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
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

  /// Create a copy of TextCompletion
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
mixin _$TextCompletionChunk {
  /// The new text generated in this chunk.
  String get text;

  /// The reason generation stopped, if this is the final chunk.
  ///
  /// Null for all chunks except the last one.
  FinishReason? get finishReason;

  /// Create a copy of TextCompletionChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TextCompletionChunkCopyWith<TextCompletionChunk> get copyWith =>
      _$TextCompletionChunkCopyWithImpl<TextCompletionChunk>(
          this as TextCompletionChunk, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TextCompletionChunk &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.finishReason, finishReason) ||
                other.finishReason == finishReason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text, finishReason);

  @override
  String toString() {
    return 'TextCompletionChunk(text: $text, finishReason: $finishReason)';
  }
}

/// @nodoc
abstract mixin class $TextCompletionChunkCopyWith<$Res> {
  factory $TextCompletionChunkCopyWith(
          TextCompletionChunk value, $Res Function(TextCompletionChunk) _then) =
      _$TextCompletionChunkCopyWithImpl;
  @useResult
  $Res call({String text, FinishReason? finishReason});
}

/// @nodoc
class _$TextCompletionChunkCopyWithImpl<$Res>
    implements $TextCompletionChunkCopyWith<$Res> {
  _$TextCompletionChunkCopyWithImpl(this._self, this._then);

  final TextCompletionChunk _self;
  final $Res Function(TextCompletionChunk) _then;

  /// Create a copy of TextCompletionChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? finishReason = freezed,
  }) {
    return _then(_self.copyWith(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      finishReason: freezed == finishReason
          ? _self.finishReason
          : finishReason // ignore: cast_nullable_to_non_nullable
              as FinishReason?,
    ));
  }
}

/// Adds pattern-matching-related methods to [TextCompletionChunk].
extension TextCompletionChunkPatterns on TextCompletionChunk {
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
    TResult Function(_TextCompletionChunk value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TextCompletionChunk() when $default != null:
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
    TResult Function(_TextCompletionChunk value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextCompletionChunk():
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
    TResult? Function(_TextCompletionChunk value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextCompletionChunk() when $default != null:
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
    TResult Function(String text, FinishReason? finishReason)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TextCompletionChunk() when $default != null:
        return $default(_that.text, _that.finishReason);
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
    TResult Function(String text, FinishReason? finishReason) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextCompletionChunk():
        return $default(_that.text, _that.finishReason);
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
    TResult? Function(String text, FinishReason? finishReason)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextCompletionChunk() when $default != null:
        return $default(_that.text, _that.finishReason);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _TextCompletionChunk extends TextCompletionChunk {
  const _TextCompletionChunk({required this.text, this.finishReason})
      : super._();

  /// The new text generated in this chunk.
  @override
  final String text;

  /// The reason generation stopped, if this is the final chunk.
  ///
  /// Null for all chunks except the last one.
  @override
  final FinishReason? finishReason;

  /// Create a copy of TextCompletionChunk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TextCompletionChunkCopyWith<_TextCompletionChunk> get copyWith =>
      __$TextCompletionChunkCopyWithImpl<_TextCompletionChunk>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TextCompletionChunk &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.finishReason, finishReason) ||
                other.finishReason == finishReason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text, finishReason);

  @override
  String toString() {
    return 'TextCompletionChunk(text: $text, finishReason: $finishReason)';
  }
}

/// @nodoc
abstract mixin class _$TextCompletionChunkCopyWith<$Res>
    implements $TextCompletionChunkCopyWith<$Res> {
  factory _$TextCompletionChunkCopyWith(_TextCompletionChunk value,
          $Res Function(_TextCompletionChunk) _then) =
      __$TextCompletionChunkCopyWithImpl;
  @override
  @useResult
  $Res call({String text, FinishReason? finishReason});
}

/// @nodoc
class __$TextCompletionChunkCopyWithImpl<$Res>
    implements _$TextCompletionChunkCopyWith<$Res> {
  __$TextCompletionChunkCopyWithImpl(this._self, this._then);

  final _TextCompletionChunk _self;
  final $Res Function(_TextCompletionChunk) _then;

  /// Create a copy of TextCompletionChunk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? text = null,
    Object? finishReason = freezed,
  }) {
    return _then(_TextCompletionChunk(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      finishReason: freezed == finishReason
          ? _self.finishReason
          : finishReason // ignore: cast_nullable_to_non_nullable
              as FinishReason?,
    ));
  }
}

// dart format on
