// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ModelConfig {
  /// Maximum context length in tokens.
  ///
  /// Larger values allow longer conversations but require more memory.
  /// If null, uses the model's default context size.
  int? get contextSize;

  /// Number of layers to offload to GPU.
  ///
  /// - `-1`: Automatic detection (offload as many as fit in VRAM)
  /// - `0`: CPU only, no GPU acceleration
  /// - `n > 0`: Offload exactly n layers to GPU
  ///
  /// Default: -1 (automatic)
  int get gpuLayers;

  /// Number of CPU threads for inference.
  ///
  /// - `0`: Automatic detection (uses optimal thread count)
  /// - `n > 0`: Use exactly n threads
  ///
  /// More threads can improve performance but may cause contention.
  /// Default: 0 (automatic)
  int get threads;

  /// Batch size for prompt processing.
  ///
  /// Larger values process prompts faster but use more memory.
  /// Default: 512
  int get batchSize;

  /// RoPE frequency base override.
  ///
  /// Used for context extension techniques. Leave null for model default.
  double? get ropeFrequencyBase;

  /// RoPE frequency scale override.
  ///
  /// Used for context extension techniques. Leave null for model default.
  double? get ropeFrequencyScale;

  /// Whether to memory-map the model file.
  ///
  /// Memory mapping reduces initial load time and memory usage by
  /// loading model weights on demand. Recommended for most use cases.
  /// Default: true
  bool get useMemoryMap;

  /// Whether to lock model memory to prevent swapping.
  ///
  /// Prevents the OS from swapping model memory to disk, ensuring
  /// consistent performance. May require elevated privileges.
  /// Default: false
  bool get lockMemory;

  /// Quantization level for the KV cache.
  ///
  /// Lower precision reduces memory usage at the cost of slight
  /// quality decrease. f16 is full precision, q8_0 and q4_0 are
  /// progressively more aggressive quantization.
  /// Default: f16
  KVCacheType get kvCacheType;

  /// Directory for storing downloaded models.
  ///
  /// If null, uses the platform-specific default cache directory.
  String? get cacheDirectory;

  /// Create a copy of ModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ModelConfigCopyWith<ModelConfig> get copyWith =>
      _$ModelConfigCopyWithImpl<ModelConfig>(this as ModelConfig, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ModelConfig &&
            (identical(other.contextSize, contextSize) ||
                other.contextSize == contextSize) &&
            (identical(other.gpuLayers, gpuLayers) ||
                other.gpuLayers == gpuLayers) &&
            (identical(other.threads, threads) || other.threads == threads) &&
            (identical(other.batchSize, batchSize) ||
                other.batchSize == batchSize) &&
            (identical(other.ropeFrequencyBase, ropeFrequencyBase) ||
                other.ropeFrequencyBase == ropeFrequencyBase) &&
            (identical(other.ropeFrequencyScale, ropeFrequencyScale) ||
                other.ropeFrequencyScale == ropeFrequencyScale) &&
            (identical(other.useMemoryMap, useMemoryMap) ||
                other.useMemoryMap == useMemoryMap) &&
            (identical(other.lockMemory, lockMemory) ||
                other.lockMemory == lockMemory) &&
            (identical(other.kvCacheType, kvCacheType) ||
                other.kvCacheType == kvCacheType) &&
            (identical(other.cacheDirectory, cacheDirectory) ||
                other.cacheDirectory == cacheDirectory));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      contextSize,
      gpuLayers,
      threads,
      batchSize,
      ropeFrequencyBase,
      ropeFrequencyScale,
      useMemoryMap,
      lockMemory,
      kvCacheType,
      cacheDirectory);

  @override
  String toString() {
    return 'ModelConfig(contextSize: $contextSize, gpuLayers: $gpuLayers, threads: $threads, batchSize: $batchSize, ropeFrequencyBase: $ropeFrequencyBase, ropeFrequencyScale: $ropeFrequencyScale, useMemoryMap: $useMemoryMap, lockMemory: $lockMemory, kvCacheType: $kvCacheType, cacheDirectory: $cacheDirectory)';
  }
}

/// @nodoc
abstract mixin class $ModelConfigCopyWith<$Res> {
  factory $ModelConfigCopyWith(
          ModelConfig value, $Res Function(ModelConfig) _then) =
      _$ModelConfigCopyWithImpl;
  @useResult
  $Res call(
      {int? contextSize,
      int gpuLayers,
      int threads,
      int batchSize,
      double? ropeFrequencyBase,
      double? ropeFrequencyScale,
      bool useMemoryMap,
      bool lockMemory,
      KVCacheType kvCacheType,
      String? cacheDirectory});
}

/// @nodoc
class _$ModelConfigCopyWithImpl<$Res> implements $ModelConfigCopyWith<$Res> {
  _$ModelConfigCopyWithImpl(this._self, this._then);

  final ModelConfig _self;
  final $Res Function(ModelConfig) _then;

  /// Create a copy of ModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contextSize = freezed,
    Object? gpuLayers = null,
    Object? threads = null,
    Object? batchSize = null,
    Object? ropeFrequencyBase = freezed,
    Object? ropeFrequencyScale = freezed,
    Object? useMemoryMap = null,
    Object? lockMemory = null,
    Object? kvCacheType = null,
    Object? cacheDirectory = freezed,
  }) {
    return _then(_self.copyWith(
      contextSize: freezed == contextSize
          ? _self.contextSize
          : contextSize // ignore: cast_nullable_to_non_nullable
              as int?,
      gpuLayers: null == gpuLayers
          ? _self.gpuLayers
          : gpuLayers // ignore: cast_nullable_to_non_nullable
              as int,
      threads: null == threads
          ? _self.threads
          : threads // ignore: cast_nullable_to_non_nullable
              as int,
      batchSize: null == batchSize
          ? _self.batchSize
          : batchSize // ignore: cast_nullable_to_non_nullable
              as int,
      ropeFrequencyBase: freezed == ropeFrequencyBase
          ? _self.ropeFrequencyBase
          : ropeFrequencyBase // ignore: cast_nullable_to_non_nullable
              as double?,
      ropeFrequencyScale: freezed == ropeFrequencyScale
          ? _self.ropeFrequencyScale
          : ropeFrequencyScale // ignore: cast_nullable_to_non_nullable
              as double?,
      useMemoryMap: null == useMemoryMap
          ? _self.useMemoryMap
          : useMemoryMap // ignore: cast_nullable_to_non_nullable
              as bool,
      lockMemory: null == lockMemory
          ? _self.lockMemory
          : lockMemory // ignore: cast_nullable_to_non_nullable
              as bool,
      kvCacheType: null == kvCacheType
          ? _self.kvCacheType
          : kvCacheType // ignore: cast_nullable_to_non_nullable
              as KVCacheType,
      cacheDirectory: freezed == cacheDirectory
          ? _self.cacheDirectory
          : cacheDirectory // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ModelConfig].
extension ModelConfigPatterns on ModelConfig {
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
    TResult Function(_ModelConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ModelConfig() when $default != null:
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
    TResult Function(_ModelConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ModelConfig():
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
    TResult? Function(_ModelConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ModelConfig() when $default != null:
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
            int? contextSize,
            int gpuLayers,
            int threads,
            int batchSize,
            double? ropeFrequencyBase,
            double? ropeFrequencyScale,
            bool useMemoryMap,
            bool lockMemory,
            KVCacheType kvCacheType,
            String? cacheDirectory)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ModelConfig() when $default != null:
        return $default(
            _that.contextSize,
            _that.gpuLayers,
            _that.threads,
            _that.batchSize,
            _that.ropeFrequencyBase,
            _that.ropeFrequencyScale,
            _that.useMemoryMap,
            _that.lockMemory,
            _that.kvCacheType,
            _that.cacheDirectory);
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
            int? contextSize,
            int gpuLayers,
            int threads,
            int batchSize,
            double? ropeFrequencyBase,
            double? ropeFrequencyScale,
            bool useMemoryMap,
            bool lockMemory,
            KVCacheType kvCacheType,
            String? cacheDirectory)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ModelConfig():
        return $default(
            _that.contextSize,
            _that.gpuLayers,
            _that.threads,
            _that.batchSize,
            _that.ropeFrequencyBase,
            _that.ropeFrequencyScale,
            _that.useMemoryMap,
            _that.lockMemory,
            _that.kvCacheType,
            _that.cacheDirectory);
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
            int? contextSize,
            int gpuLayers,
            int threads,
            int batchSize,
            double? ropeFrequencyBase,
            double? ropeFrequencyScale,
            bool useMemoryMap,
            bool lockMemory,
            KVCacheType kvCacheType,
            String? cacheDirectory)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ModelConfig() when $default != null:
        return $default(
            _that.contextSize,
            _that.gpuLayers,
            _that.threads,
            _that.batchSize,
            _that.ropeFrequencyBase,
            _that.ropeFrequencyScale,
            _that.useMemoryMap,
            _that.lockMemory,
            _that.kvCacheType,
            _that.cacheDirectory);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ModelConfig extends ModelConfig {
  const _ModelConfig(
      {this.contextSize,
      this.gpuLayers = -1,
      this.threads = 0,
      this.batchSize = 512,
      this.ropeFrequencyBase,
      this.ropeFrequencyScale,
      this.useMemoryMap = true,
      this.lockMemory = false,
      this.kvCacheType = KVCacheType.f16,
      this.cacheDirectory})
      : super._();

  /// Maximum context length in tokens.
  ///
  /// Larger values allow longer conversations but require more memory.
  /// If null, uses the model's default context size.
  @override
  final int? contextSize;

  /// Number of layers to offload to GPU.
  ///
  /// - `-1`: Automatic detection (offload as many as fit in VRAM)
  /// - `0`: CPU only, no GPU acceleration
  /// - `n > 0`: Offload exactly n layers to GPU
  ///
  /// Default: -1 (automatic)
  @override
  @JsonKey()
  final int gpuLayers;

  /// Number of CPU threads for inference.
  ///
  /// - `0`: Automatic detection (uses optimal thread count)
  /// - `n > 0`: Use exactly n threads
  ///
  /// More threads can improve performance but may cause contention.
  /// Default: 0 (automatic)
  @override
  @JsonKey()
  final int threads;

  /// Batch size for prompt processing.
  ///
  /// Larger values process prompts faster but use more memory.
  /// Default: 512
  @override
  @JsonKey()
  final int batchSize;

  /// RoPE frequency base override.
  ///
  /// Used for context extension techniques. Leave null for model default.
  @override
  final double? ropeFrequencyBase;

  /// RoPE frequency scale override.
  ///
  /// Used for context extension techniques. Leave null for model default.
  @override
  final double? ropeFrequencyScale;

  /// Whether to memory-map the model file.
  ///
  /// Memory mapping reduces initial load time and memory usage by
  /// loading model weights on demand. Recommended for most use cases.
  /// Default: true
  @override
  @JsonKey()
  final bool useMemoryMap;

  /// Whether to lock model memory to prevent swapping.
  ///
  /// Prevents the OS from swapping model memory to disk, ensuring
  /// consistent performance. May require elevated privileges.
  /// Default: false
  @override
  @JsonKey()
  final bool lockMemory;

  /// Quantization level for the KV cache.
  ///
  /// Lower precision reduces memory usage at the cost of slight
  /// quality decrease. f16 is full precision, q8_0 and q4_0 are
  /// progressively more aggressive quantization.
  /// Default: f16
  @override
  @JsonKey()
  final KVCacheType kvCacheType;

  /// Directory for storing downloaded models.
  ///
  /// If null, uses the platform-specific default cache directory.
  @override
  final String? cacheDirectory;

  /// Create a copy of ModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ModelConfigCopyWith<_ModelConfig> get copyWith =>
      __$ModelConfigCopyWithImpl<_ModelConfig>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ModelConfig &&
            (identical(other.contextSize, contextSize) ||
                other.contextSize == contextSize) &&
            (identical(other.gpuLayers, gpuLayers) ||
                other.gpuLayers == gpuLayers) &&
            (identical(other.threads, threads) || other.threads == threads) &&
            (identical(other.batchSize, batchSize) ||
                other.batchSize == batchSize) &&
            (identical(other.ropeFrequencyBase, ropeFrequencyBase) ||
                other.ropeFrequencyBase == ropeFrequencyBase) &&
            (identical(other.ropeFrequencyScale, ropeFrequencyScale) ||
                other.ropeFrequencyScale == ropeFrequencyScale) &&
            (identical(other.useMemoryMap, useMemoryMap) ||
                other.useMemoryMap == useMemoryMap) &&
            (identical(other.lockMemory, lockMemory) ||
                other.lockMemory == lockMemory) &&
            (identical(other.kvCacheType, kvCacheType) ||
                other.kvCacheType == kvCacheType) &&
            (identical(other.cacheDirectory, cacheDirectory) ||
                other.cacheDirectory == cacheDirectory));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      contextSize,
      gpuLayers,
      threads,
      batchSize,
      ropeFrequencyBase,
      ropeFrequencyScale,
      useMemoryMap,
      lockMemory,
      kvCacheType,
      cacheDirectory);

  @override
  String toString() {
    return 'ModelConfig(contextSize: $contextSize, gpuLayers: $gpuLayers, threads: $threads, batchSize: $batchSize, ropeFrequencyBase: $ropeFrequencyBase, ropeFrequencyScale: $ropeFrequencyScale, useMemoryMap: $useMemoryMap, lockMemory: $lockMemory, kvCacheType: $kvCacheType, cacheDirectory: $cacheDirectory)';
  }
}

/// @nodoc
abstract mixin class _$ModelConfigCopyWith<$Res>
    implements $ModelConfigCopyWith<$Res> {
  factory _$ModelConfigCopyWith(
          _ModelConfig value, $Res Function(_ModelConfig) _then) =
      __$ModelConfigCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int? contextSize,
      int gpuLayers,
      int threads,
      int batchSize,
      double? ropeFrequencyBase,
      double? ropeFrequencyScale,
      bool useMemoryMap,
      bool lockMemory,
      KVCacheType kvCacheType,
      String? cacheDirectory});
}

/// @nodoc
class __$ModelConfigCopyWithImpl<$Res> implements _$ModelConfigCopyWith<$Res> {
  __$ModelConfigCopyWithImpl(this._self, this._then);

  final _ModelConfig _self;
  final $Res Function(_ModelConfig) _then;

  /// Create a copy of ModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? contextSize = freezed,
    Object? gpuLayers = null,
    Object? threads = null,
    Object? batchSize = null,
    Object? ropeFrequencyBase = freezed,
    Object? ropeFrequencyScale = freezed,
    Object? useMemoryMap = null,
    Object? lockMemory = null,
    Object? kvCacheType = null,
    Object? cacheDirectory = freezed,
  }) {
    return _then(_ModelConfig(
      contextSize: freezed == contextSize
          ? _self.contextSize
          : contextSize // ignore: cast_nullable_to_non_nullable
              as int?,
      gpuLayers: null == gpuLayers
          ? _self.gpuLayers
          : gpuLayers // ignore: cast_nullable_to_non_nullable
              as int,
      threads: null == threads
          ? _self.threads
          : threads // ignore: cast_nullable_to_non_nullable
              as int,
      batchSize: null == batchSize
          ? _self.batchSize
          : batchSize // ignore: cast_nullable_to_non_nullable
              as int,
      ropeFrequencyBase: freezed == ropeFrequencyBase
          ? _self.ropeFrequencyBase
          : ropeFrequencyBase // ignore: cast_nullable_to_non_nullable
              as double?,
      ropeFrequencyScale: freezed == ropeFrequencyScale
          ? _self.ropeFrequencyScale
          : ropeFrequencyScale // ignore: cast_nullable_to_non_nullable
              as double?,
      useMemoryMap: null == useMemoryMap
          ? _self.useMemoryMap
          : useMemoryMap // ignore: cast_nullable_to_non_nullable
              as bool,
      lockMemory: null == lockMemory
          ? _self.lockMemory
          : lockMemory // ignore: cast_nullable_to_non_nullable
              as bool,
      kvCacheType: null == kvCacheType
          ? _self.kvCacheType
          : kvCacheType // ignore: cast_nullable_to_non_nullable
              as KVCacheType,
      cacheDirectory: freezed == cacheDirectory
          ? _self.cacheDirectory
          : cacheDirectory // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
