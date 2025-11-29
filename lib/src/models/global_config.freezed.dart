// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GlobalConfig {
  /// Base directory for the model cache.
  ///
  /// Downloaded models are stored here. If null, uses the
  /// platform-specific default:
  /// - Android: app's external cache directory
  /// - iOS/macOS: app's caches directory
  /// - Windows/Linux: user's cache directory
  String? get defaultCacheDirectory;

  /// Default GPU layer count for new models.
  ///
  /// Applied when loading models without explicit gpuLayers config.
  /// - `-1`: Automatic detection
  /// - `0`: CPU only
  /// - `n > 0`: Offload n layers
  ///
  /// Default: -1 (automatic)
  int get defaultGpuLayers;

  /// Default CPU thread count for new models.
  ///
  /// Applied when loading models without explicit thread config.
  /// - `0`: Automatic detection
  /// - `n > 0`: Use n threads
  ///
  /// Default: 0 (automatic)
  int get defaultThreadCount;

  /// Whether to enable internal debug logging.
  ///
  /// When enabled, DartLLM outputs diagnostic information through
  /// the logging system. Useful for debugging but may impact performance.
  /// Default: false
  bool get enableLogging;

  /// Minimum log level to output.
  ///
  /// Only messages at this level or higher are logged.
  /// Default: LogLevel.warning
  LogLevel get logLevel;

  /// HuggingFace API token for accessing private repositories.
  ///
  /// Required when downloading models from private HuggingFace repos.
  /// Keep this value secure and never log it.
  String? get huggingFaceToken;

  /// Create a copy of GlobalConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GlobalConfigCopyWith<GlobalConfig> get copyWith =>
      _$GlobalConfigCopyWithImpl<GlobalConfig>(
          this as GlobalConfig, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GlobalConfig &&
            (identical(other.defaultCacheDirectory, defaultCacheDirectory) ||
                other.defaultCacheDirectory == defaultCacheDirectory) &&
            (identical(other.defaultGpuLayers, defaultGpuLayers) ||
                other.defaultGpuLayers == defaultGpuLayers) &&
            (identical(other.defaultThreadCount, defaultThreadCount) ||
                other.defaultThreadCount == defaultThreadCount) &&
            (identical(other.enableLogging, enableLogging) ||
                other.enableLogging == enableLogging) &&
            (identical(other.logLevel, logLevel) ||
                other.logLevel == logLevel) &&
            (identical(other.huggingFaceToken, huggingFaceToken) ||
                other.huggingFaceToken == huggingFaceToken));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      defaultCacheDirectory,
      defaultGpuLayers,
      defaultThreadCount,
      enableLogging,
      logLevel,
      huggingFaceToken);

  @override
  String toString() {
    return 'GlobalConfig(defaultCacheDirectory: $defaultCacheDirectory, defaultGpuLayers: $defaultGpuLayers, defaultThreadCount: $defaultThreadCount, enableLogging: $enableLogging, logLevel: $logLevel, huggingFaceToken: $huggingFaceToken)';
  }
}

/// @nodoc
abstract mixin class $GlobalConfigCopyWith<$Res> {
  factory $GlobalConfigCopyWith(
          GlobalConfig value, $Res Function(GlobalConfig) _then) =
      _$GlobalConfigCopyWithImpl;
  @useResult
  $Res call(
      {String? defaultCacheDirectory,
      int defaultGpuLayers,
      int defaultThreadCount,
      bool enableLogging,
      LogLevel logLevel,
      String? huggingFaceToken});
}

/// @nodoc
class _$GlobalConfigCopyWithImpl<$Res> implements $GlobalConfigCopyWith<$Res> {
  _$GlobalConfigCopyWithImpl(this._self, this._then);

  final GlobalConfig _self;
  final $Res Function(GlobalConfig) _then;

  /// Create a copy of GlobalConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? defaultCacheDirectory = freezed,
    Object? defaultGpuLayers = null,
    Object? defaultThreadCount = null,
    Object? enableLogging = null,
    Object? logLevel = null,
    Object? huggingFaceToken = freezed,
  }) {
    return _then(_self.copyWith(
      defaultCacheDirectory: freezed == defaultCacheDirectory
          ? _self.defaultCacheDirectory
          : defaultCacheDirectory // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultGpuLayers: null == defaultGpuLayers
          ? _self.defaultGpuLayers
          : defaultGpuLayers // ignore: cast_nullable_to_non_nullable
              as int,
      defaultThreadCount: null == defaultThreadCount
          ? _self.defaultThreadCount
          : defaultThreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      enableLogging: null == enableLogging
          ? _self.enableLogging
          : enableLogging // ignore: cast_nullable_to_non_nullable
              as bool,
      logLevel: null == logLevel
          ? _self.logLevel
          : logLevel // ignore: cast_nullable_to_non_nullable
              as LogLevel,
      huggingFaceToken: freezed == huggingFaceToken
          ? _self.huggingFaceToken
          : huggingFaceToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [GlobalConfig].
extension GlobalConfigPatterns on GlobalConfig {
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
    TResult Function(_GlobalConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GlobalConfig() when $default != null:
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
    TResult Function(_GlobalConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GlobalConfig():
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
    TResult? Function(_GlobalConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GlobalConfig() when $default != null:
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
    TResult Function(
            String? defaultCacheDirectory,
            int defaultGpuLayers,
            int defaultThreadCount,
            bool enableLogging,
            LogLevel logLevel,
            String? huggingFaceToken)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GlobalConfig() when $default != null:
        return $default(
            _that.defaultCacheDirectory,
            _that.defaultGpuLayers,
            _that.defaultThreadCount,
            _that.enableLogging,
            _that.logLevel,
            _that.huggingFaceToken);
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
    TResult Function(
            String? defaultCacheDirectory,
            int defaultGpuLayers,
            int defaultThreadCount,
            bool enableLogging,
            LogLevel logLevel,
            String? huggingFaceToken)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GlobalConfig():
        return $default(
            _that.defaultCacheDirectory,
            _that.defaultGpuLayers,
            _that.defaultThreadCount,
            _that.enableLogging,
            _that.logLevel,
            _that.huggingFaceToken);
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
    TResult? Function(
            String? defaultCacheDirectory,
            int defaultGpuLayers,
            int defaultThreadCount,
            bool enableLogging,
            LogLevel logLevel,
            String? huggingFaceToken)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GlobalConfig() when $default != null:
        return $default(
            _that.defaultCacheDirectory,
            _that.defaultGpuLayers,
            _that.defaultThreadCount,
            _that.enableLogging,
            _that.logLevel,
            _that.huggingFaceToken);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GlobalConfig extends GlobalConfig {
  const _GlobalConfig(
      {this.defaultCacheDirectory,
      this.defaultGpuLayers = -1,
      this.defaultThreadCount = 0,
      this.enableLogging = false,
      this.logLevel = LogLevel.warning,
      this.huggingFaceToken})
      : super._();

  /// Base directory for the model cache.
  ///
  /// Downloaded models are stored here. If null, uses the
  /// platform-specific default:
  /// - Android: app's external cache directory
  /// - iOS/macOS: app's caches directory
  /// - Windows/Linux: user's cache directory
  @override
  final String? defaultCacheDirectory;

  /// Default GPU layer count for new models.
  ///
  /// Applied when loading models without explicit gpuLayers config.
  /// - `-1`: Automatic detection
  /// - `0`: CPU only
  /// - `n > 0`: Offload n layers
  ///
  /// Default: -1 (automatic)
  @override
  @JsonKey()
  final int defaultGpuLayers;

  /// Default CPU thread count for new models.
  ///
  /// Applied when loading models without explicit thread config.
  /// - `0`: Automatic detection
  /// - `n > 0`: Use n threads
  ///
  /// Default: 0 (automatic)
  @override
  @JsonKey()
  final int defaultThreadCount;

  /// Whether to enable internal debug logging.
  ///
  /// When enabled, DartLLM outputs diagnostic information through
  /// the logging system. Useful for debugging but may impact performance.
  /// Default: false
  @override
  @JsonKey()
  final bool enableLogging;

  /// Minimum log level to output.
  ///
  /// Only messages at this level or higher are logged.
  /// Default: LogLevel.warning
  @override
  @JsonKey()
  final LogLevel logLevel;

  /// HuggingFace API token for accessing private repositories.
  ///
  /// Required when downloading models from private HuggingFace repos.
  /// Keep this value secure and never log it.
  @override
  final String? huggingFaceToken;

  /// Create a copy of GlobalConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GlobalConfigCopyWith<_GlobalConfig> get copyWith =>
      __$GlobalConfigCopyWithImpl<_GlobalConfig>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GlobalConfig &&
            (identical(other.defaultCacheDirectory, defaultCacheDirectory) ||
                other.defaultCacheDirectory == defaultCacheDirectory) &&
            (identical(other.defaultGpuLayers, defaultGpuLayers) ||
                other.defaultGpuLayers == defaultGpuLayers) &&
            (identical(other.defaultThreadCount, defaultThreadCount) ||
                other.defaultThreadCount == defaultThreadCount) &&
            (identical(other.enableLogging, enableLogging) ||
                other.enableLogging == enableLogging) &&
            (identical(other.logLevel, logLevel) ||
                other.logLevel == logLevel) &&
            (identical(other.huggingFaceToken, huggingFaceToken) ||
                other.huggingFaceToken == huggingFaceToken));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      defaultCacheDirectory,
      defaultGpuLayers,
      defaultThreadCount,
      enableLogging,
      logLevel,
      huggingFaceToken);

  @override
  String toString() {
    return 'GlobalConfig(defaultCacheDirectory: $defaultCacheDirectory, defaultGpuLayers: $defaultGpuLayers, defaultThreadCount: $defaultThreadCount, enableLogging: $enableLogging, logLevel: $logLevel, huggingFaceToken: $huggingFaceToken)';
  }
}

/// @nodoc
abstract mixin class _$GlobalConfigCopyWith<$Res>
    implements $GlobalConfigCopyWith<$Res> {
  factory _$GlobalConfigCopyWith(
          _GlobalConfig value, $Res Function(_GlobalConfig) _then) =
      __$GlobalConfigCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? defaultCacheDirectory,
      int defaultGpuLayers,
      int defaultThreadCount,
      bool enableLogging,
      LogLevel logLevel,
      String? huggingFaceToken});
}

/// @nodoc
class __$GlobalConfigCopyWithImpl<$Res>
    implements _$GlobalConfigCopyWith<$Res> {
  __$GlobalConfigCopyWithImpl(this._self, this._then);

  final _GlobalConfig _self;
  final $Res Function(_GlobalConfig) _then;

  /// Create a copy of GlobalConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? defaultCacheDirectory = freezed,
    Object? defaultGpuLayers = null,
    Object? defaultThreadCount = null,
    Object? enableLogging = null,
    Object? logLevel = null,
    Object? huggingFaceToken = freezed,
  }) {
    return _then(_GlobalConfig(
      defaultCacheDirectory: freezed == defaultCacheDirectory
          ? _self.defaultCacheDirectory
          : defaultCacheDirectory // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultGpuLayers: null == defaultGpuLayers
          ? _self.defaultGpuLayers
          : defaultGpuLayers // ignore: cast_nullable_to_non_nullable
              as int,
      defaultThreadCount: null == defaultThreadCount
          ? _self.defaultThreadCount
          : defaultThreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      enableLogging: null == enableLogging
          ? _self.enableLogging
          : enableLogging // ignore: cast_nullable_to_non_nullable
              as bool,
      logLevel: null == logLevel
          ? _self.logLevel
          : logLevel // ignore: cast_nullable_to_non_nullable
              as LogLevel,
      huggingFaceToken: freezed == huggingFaceToken
          ? _self.huggingFaceToken
          : huggingFaceToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
