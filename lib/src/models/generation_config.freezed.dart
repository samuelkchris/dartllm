// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generation_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GenerationConfig {
  /// Maximum number of tokens to generate.
  ///
  /// Generation stops when this limit is reached, even if the response
  /// is incomplete. Set higher for longer responses.
  /// Default: 1024
  int get maxTokens;

  /// Sampling temperature controlling randomness.
  ///
  /// Higher values (e.g., 1.5) produce more creative, varied outputs.
  /// Lower values (e.g., 0.2) produce more focused, deterministic outputs.
  /// Range: 0.0 to 2.0. Default: 0.7
  double get temperature;

  /// Nucleus sampling threshold.
  ///
  /// Only tokens with cumulative probability up to this value are
  /// considered. Lower values focus on more likely tokens.
  /// Range: 0.0 to 1.0. Default: 0.9
  double get topP;

  /// Top-K sampling limit.
  ///
  /// Only the K most likely tokens are considered at each step.
  /// Lower values increase focus, higher values increase variety.
  /// Range: 1 to vocabulary size. Default: 40
  int get topK;

  /// Minimum probability threshold.
  ///
  /// Tokens with probability below this threshold relative to the
  /// most likely token are excluded from sampling.
  /// Range: 0.0 to 1.0. Default: 0.05
  double get minP;

  /// Penalty applied to tokens that have been used recently.
  ///
  /// Values > 1.0 discourage repetition, making the model less
  /// likely to repeat the same phrases.
  /// Range: 1.0 to 2.0. Default: 1.1
  double get repetitionPenalty;

  /// Penalty based on how frequently a token has appeared.
  ///
  /// Applied proportionally to token frequency in the generated text.
  /// Range: 0.0 to 2.0. Default: 0.0
  double get frequencyPenalty;

  /// Penalty for tokens that have appeared at all.
  ///
  /// Applied equally to all tokens that have been generated.
  /// Range: 0.0 to 2.0. Default: 0.0
  double get presencePenalty;

  /// Number of recent tokens to consider for repetition penalty.
  ///
  /// The penalty only applies to tokens within this window.
  /// Default: 64
  int get repeatLastN;

  /// Strings that trigger generation to stop when encountered.
  ///
  /// The stop sequence itself is not included in the output.
  List<String> get stopSequences;

  /// Random seed for reproducible generation.
  ///
  /// Using the same seed with identical inputs produces the same
  /// output. Null uses a random seed each time.
  int? get seed;

  /// GBNF grammar for constrained generation.
  ///
  /// When specified, the model's output is constrained to match
  /// the provided grammar, useful for structured output.
  String? get grammar;

  /// JSON schema for structured output.
  ///
  /// When specified, the model generates valid JSON matching
  /// the schema. Cannot be used with [grammar].
  Map<String, dynamic>? get jsonSchema;

  /// Create a copy of GenerationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GenerationConfigCopyWith<GenerationConfig> get copyWith =>
      _$GenerationConfigCopyWithImpl<GenerationConfig>(
          this as GenerationConfig, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GenerationConfig &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.topP, topP) || other.topP == topP) &&
            (identical(other.topK, topK) || other.topK == topK) &&
            (identical(other.minP, minP) || other.minP == minP) &&
            (identical(other.repetitionPenalty, repetitionPenalty) ||
                other.repetitionPenalty == repetitionPenalty) &&
            (identical(other.frequencyPenalty, frequencyPenalty) ||
                other.frequencyPenalty == frequencyPenalty) &&
            (identical(other.presencePenalty, presencePenalty) ||
                other.presencePenalty == presencePenalty) &&
            (identical(other.repeatLastN, repeatLastN) ||
                other.repeatLastN == repeatLastN) &&
            const DeepCollectionEquality()
                .equals(other.stopSequences, stopSequences) &&
            (identical(other.seed, seed) || other.seed == seed) &&
            (identical(other.grammar, grammar) || other.grammar == grammar) &&
            const DeepCollectionEquality()
                .equals(other.jsonSchema, jsonSchema));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      maxTokens,
      temperature,
      topP,
      topK,
      minP,
      repetitionPenalty,
      frequencyPenalty,
      presencePenalty,
      repeatLastN,
      const DeepCollectionEquality().hash(stopSequences),
      seed,
      grammar,
      const DeepCollectionEquality().hash(jsonSchema));

  @override
  String toString() {
    return 'GenerationConfig(maxTokens: $maxTokens, temperature: $temperature, topP: $topP, topK: $topK, minP: $minP, repetitionPenalty: $repetitionPenalty, frequencyPenalty: $frequencyPenalty, presencePenalty: $presencePenalty, repeatLastN: $repeatLastN, stopSequences: $stopSequences, seed: $seed, grammar: $grammar, jsonSchema: $jsonSchema)';
  }
}

/// @nodoc
abstract mixin class $GenerationConfigCopyWith<$Res> {
  factory $GenerationConfigCopyWith(
          GenerationConfig value, $Res Function(GenerationConfig) _then) =
      _$GenerationConfigCopyWithImpl;
  @useResult
  $Res call(
      {int maxTokens,
      double temperature,
      double topP,
      int topK,
      double minP,
      double repetitionPenalty,
      double frequencyPenalty,
      double presencePenalty,
      int repeatLastN,
      List<String> stopSequences,
      int? seed,
      String? grammar,
      Map<String, dynamic>? jsonSchema});
}

/// @nodoc
class _$GenerationConfigCopyWithImpl<$Res>
    implements $GenerationConfigCopyWith<$Res> {
  _$GenerationConfigCopyWithImpl(this._self, this._then);

  final GenerationConfig _self;
  final $Res Function(GenerationConfig) _then;

  /// Create a copy of GenerationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxTokens = null,
    Object? temperature = null,
    Object? topP = null,
    Object? topK = null,
    Object? minP = null,
    Object? repetitionPenalty = null,
    Object? frequencyPenalty = null,
    Object? presencePenalty = null,
    Object? repeatLastN = null,
    Object? stopSequences = null,
    Object? seed = freezed,
    Object? grammar = freezed,
    Object? jsonSchema = freezed,
  }) {
    return _then(_self.copyWith(
      maxTokens: null == maxTokens
          ? _self.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      temperature: null == temperature
          ? _self.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      topP: null == topP
          ? _self.topP
          : topP // ignore: cast_nullable_to_non_nullable
              as double,
      topK: null == topK
          ? _self.topK
          : topK // ignore: cast_nullable_to_non_nullable
              as int,
      minP: null == minP
          ? _self.minP
          : minP // ignore: cast_nullable_to_non_nullable
              as double,
      repetitionPenalty: null == repetitionPenalty
          ? _self.repetitionPenalty
          : repetitionPenalty // ignore: cast_nullable_to_non_nullable
              as double,
      frequencyPenalty: null == frequencyPenalty
          ? _self.frequencyPenalty
          : frequencyPenalty // ignore: cast_nullable_to_non_nullable
              as double,
      presencePenalty: null == presencePenalty
          ? _self.presencePenalty
          : presencePenalty // ignore: cast_nullable_to_non_nullable
              as double,
      repeatLastN: null == repeatLastN
          ? _self.repeatLastN
          : repeatLastN // ignore: cast_nullable_to_non_nullable
              as int,
      stopSequences: null == stopSequences
          ? _self.stopSequences
          : stopSequences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      seed: freezed == seed
          ? _self.seed
          : seed // ignore: cast_nullable_to_non_nullable
              as int?,
      grammar: freezed == grammar
          ? _self.grammar
          : grammar // ignore: cast_nullable_to_non_nullable
              as String?,
      jsonSchema: freezed == jsonSchema
          ? _self.jsonSchema
          : jsonSchema // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// Adds pattern-matching-related methods to [GenerationConfig].
extension GenerationConfigPatterns on GenerationConfig {
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
    TResult Function(_GenerationConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GenerationConfig() when $default != null:
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
    TResult Function(_GenerationConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GenerationConfig():
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
    TResult? Function(_GenerationConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GenerationConfig() when $default != null:
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
            int maxTokens,
            double temperature,
            double topP,
            int topK,
            double minP,
            double repetitionPenalty,
            double frequencyPenalty,
            double presencePenalty,
            int repeatLastN,
            List<String> stopSequences,
            int? seed,
            String? grammar,
            Map<String, dynamic>? jsonSchema)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GenerationConfig() when $default != null:
        return $default(
            _that.maxTokens,
            _that.temperature,
            _that.topP,
            _that.topK,
            _that.minP,
            _that.repetitionPenalty,
            _that.frequencyPenalty,
            _that.presencePenalty,
            _that.repeatLastN,
            _that.stopSequences,
            _that.seed,
            _that.grammar,
            _that.jsonSchema);
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
            int maxTokens,
            double temperature,
            double topP,
            int topK,
            double minP,
            double repetitionPenalty,
            double frequencyPenalty,
            double presencePenalty,
            int repeatLastN,
            List<String> stopSequences,
            int? seed,
            String? grammar,
            Map<String, dynamic>? jsonSchema)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GenerationConfig():
        return $default(
            _that.maxTokens,
            _that.temperature,
            _that.topP,
            _that.topK,
            _that.minP,
            _that.repetitionPenalty,
            _that.frequencyPenalty,
            _that.presencePenalty,
            _that.repeatLastN,
            _that.stopSequences,
            _that.seed,
            _that.grammar,
            _that.jsonSchema);
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
            int maxTokens,
            double temperature,
            double topP,
            int topK,
            double minP,
            double repetitionPenalty,
            double frequencyPenalty,
            double presencePenalty,
            int repeatLastN,
            List<String> stopSequences,
            int? seed,
            String? grammar,
            Map<String, dynamic>? jsonSchema)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GenerationConfig() when $default != null:
        return $default(
            _that.maxTokens,
            _that.temperature,
            _that.topP,
            _that.topK,
            _that.minP,
            _that.repetitionPenalty,
            _that.frequencyPenalty,
            _that.presencePenalty,
            _that.repeatLastN,
            _that.stopSequences,
            _that.seed,
            _that.grammar,
            _that.jsonSchema);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GenerationConfig extends GenerationConfig {
  const _GenerationConfig(
      {this.maxTokens = 1024,
      this.temperature = 0.7,
      this.topP = 0.9,
      this.topK = 40,
      this.minP = 0.05,
      this.repetitionPenalty = 1.1,
      this.frequencyPenalty = 0.0,
      this.presencePenalty = 0.0,
      this.repeatLastN = 64,
      final List<String> stopSequences = const [],
      this.seed,
      this.grammar,
      final Map<String, dynamic>? jsonSchema})
      : _stopSequences = stopSequences,
        _jsonSchema = jsonSchema,
        super._();

  /// Maximum number of tokens to generate.
  ///
  /// Generation stops when this limit is reached, even if the response
  /// is incomplete. Set higher for longer responses.
  /// Default: 1024
  @override
  @JsonKey()
  final int maxTokens;

  /// Sampling temperature controlling randomness.
  ///
  /// Higher values (e.g., 1.5) produce more creative, varied outputs.
  /// Lower values (e.g., 0.2) produce more focused, deterministic outputs.
  /// Range: 0.0 to 2.0. Default: 0.7
  @override
  @JsonKey()
  final double temperature;

  /// Nucleus sampling threshold.
  ///
  /// Only tokens with cumulative probability up to this value are
  /// considered. Lower values focus on more likely tokens.
  /// Range: 0.0 to 1.0. Default: 0.9
  @override
  @JsonKey()
  final double topP;

  /// Top-K sampling limit.
  ///
  /// Only the K most likely tokens are considered at each step.
  /// Lower values increase focus, higher values increase variety.
  /// Range: 1 to vocabulary size. Default: 40
  @override
  @JsonKey()
  final int topK;

  /// Minimum probability threshold.
  ///
  /// Tokens with probability below this threshold relative to the
  /// most likely token are excluded from sampling.
  /// Range: 0.0 to 1.0. Default: 0.05
  @override
  @JsonKey()
  final double minP;

  /// Penalty applied to tokens that have been used recently.
  ///
  /// Values > 1.0 discourage repetition, making the model less
  /// likely to repeat the same phrases.
  /// Range: 1.0 to 2.0. Default: 1.1
  @override
  @JsonKey()
  final double repetitionPenalty;

  /// Penalty based on how frequently a token has appeared.
  ///
  /// Applied proportionally to token frequency in the generated text.
  /// Range: 0.0 to 2.0. Default: 0.0
  @override
  @JsonKey()
  final double frequencyPenalty;

  /// Penalty for tokens that have appeared at all.
  ///
  /// Applied equally to all tokens that have been generated.
  /// Range: 0.0 to 2.0. Default: 0.0
  @override
  @JsonKey()
  final double presencePenalty;

  /// Number of recent tokens to consider for repetition penalty.
  ///
  /// The penalty only applies to tokens within this window.
  /// Default: 64
  @override
  @JsonKey()
  final int repeatLastN;

  /// Strings that trigger generation to stop when encountered.
  ///
  /// The stop sequence itself is not included in the output.
  final List<String> _stopSequences;

  /// Strings that trigger generation to stop when encountered.
  ///
  /// The stop sequence itself is not included in the output.
  @override
  @JsonKey()
  List<String> get stopSequences {
    if (_stopSequences is EqualUnmodifiableListView) return _stopSequences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stopSequences);
  }

  /// Random seed for reproducible generation.
  ///
  /// Using the same seed with identical inputs produces the same
  /// output. Null uses a random seed each time.
  @override
  final int? seed;

  /// GBNF grammar for constrained generation.
  ///
  /// When specified, the model's output is constrained to match
  /// the provided grammar, useful for structured output.
  @override
  final String? grammar;

  /// JSON schema for structured output.
  ///
  /// When specified, the model generates valid JSON matching
  /// the schema. Cannot be used with [grammar].
  final Map<String, dynamic>? _jsonSchema;

  /// JSON schema for structured output.
  ///
  /// When specified, the model generates valid JSON matching
  /// the schema. Cannot be used with [grammar].
  @override
  Map<String, dynamic>? get jsonSchema {
    final value = _jsonSchema;
    if (value == null) return null;
    if (_jsonSchema is EqualUnmodifiableMapView) return _jsonSchema;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of GenerationConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GenerationConfigCopyWith<_GenerationConfig> get copyWith =>
      __$GenerationConfigCopyWithImpl<_GenerationConfig>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GenerationConfig &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.topP, topP) || other.topP == topP) &&
            (identical(other.topK, topK) || other.topK == topK) &&
            (identical(other.minP, minP) || other.minP == minP) &&
            (identical(other.repetitionPenalty, repetitionPenalty) ||
                other.repetitionPenalty == repetitionPenalty) &&
            (identical(other.frequencyPenalty, frequencyPenalty) ||
                other.frequencyPenalty == frequencyPenalty) &&
            (identical(other.presencePenalty, presencePenalty) ||
                other.presencePenalty == presencePenalty) &&
            (identical(other.repeatLastN, repeatLastN) ||
                other.repeatLastN == repeatLastN) &&
            const DeepCollectionEquality()
                .equals(other._stopSequences, _stopSequences) &&
            (identical(other.seed, seed) || other.seed == seed) &&
            (identical(other.grammar, grammar) || other.grammar == grammar) &&
            const DeepCollectionEquality()
                .equals(other._jsonSchema, _jsonSchema));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      maxTokens,
      temperature,
      topP,
      topK,
      minP,
      repetitionPenalty,
      frequencyPenalty,
      presencePenalty,
      repeatLastN,
      const DeepCollectionEquality().hash(_stopSequences),
      seed,
      grammar,
      const DeepCollectionEquality().hash(_jsonSchema));

  @override
  String toString() {
    return 'GenerationConfig(maxTokens: $maxTokens, temperature: $temperature, topP: $topP, topK: $topK, minP: $minP, repetitionPenalty: $repetitionPenalty, frequencyPenalty: $frequencyPenalty, presencePenalty: $presencePenalty, repeatLastN: $repeatLastN, stopSequences: $stopSequences, seed: $seed, grammar: $grammar, jsonSchema: $jsonSchema)';
  }
}

/// @nodoc
abstract mixin class _$GenerationConfigCopyWith<$Res>
    implements $GenerationConfigCopyWith<$Res> {
  factory _$GenerationConfigCopyWith(
          _GenerationConfig value, $Res Function(_GenerationConfig) _then) =
      __$GenerationConfigCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int maxTokens,
      double temperature,
      double topP,
      int topK,
      double minP,
      double repetitionPenalty,
      double frequencyPenalty,
      double presencePenalty,
      int repeatLastN,
      List<String> stopSequences,
      int? seed,
      String? grammar,
      Map<String, dynamic>? jsonSchema});
}

/// @nodoc
class __$GenerationConfigCopyWithImpl<$Res>
    implements _$GenerationConfigCopyWith<$Res> {
  __$GenerationConfigCopyWithImpl(this._self, this._then);

  final _GenerationConfig _self;
  final $Res Function(_GenerationConfig) _then;

  /// Create a copy of GenerationConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? maxTokens = null,
    Object? temperature = null,
    Object? topP = null,
    Object? topK = null,
    Object? minP = null,
    Object? repetitionPenalty = null,
    Object? frequencyPenalty = null,
    Object? presencePenalty = null,
    Object? repeatLastN = null,
    Object? stopSequences = null,
    Object? seed = freezed,
    Object? grammar = freezed,
    Object? jsonSchema = freezed,
  }) {
    return _then(_GenerationConfig(
      maxTokens: null == maxTokens
          ? _self.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      temperature: null == temperature
          ? _self.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      topP: null == topP
          ? _self.topP
          : topP // ignore: cast_nullable_to_non_nullable
              as double,
      topK: null == topK
          ? _self.topK
          : topK // ignore: cast_nullable_to_non_nullable
              as int,
      minP: null == minP
          ? _self.minP
          : minP // ignore: cast_nullable_to_non_nullable
              as double,
      repetitionPenalty: null == repetitionPenalty
          ? _self.repetitionPenalty
          : repetitionPenalty // ignore: cast_nullable_to_non_nullable
              as double,
      frequencyPenalty: null == frequencyPenalty
          ? _self.frequencyPenalty
          : frequencyPenalty // ignore: cast_nullable_to_non_nullable
              as double,
      presencePenalty: null == presencePenalty
          ? _self.presencePenalty
          : presencePenalty // ignore: cast_nullable_to_non_nullable
              as double,
      repeatLastN: null == repeatLastN
          ? _self.repeatLastN
          : repeatLastN // ignore: cast_nullable_to_non_nullable
              as int,
      stopSequences: null == stopSequences
          ? _self._stopSequences
          : stopSequences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      seed: freezed == seed
          ? _self.seed
          : seed // ignore: cast_nullable_to_non_nullable
              as int?,
      grammar: freezed == grammar
          ? _self.grammar
          : grammar // ignore: cast_nullable_to_non_nullable
              as String?,
      jsonSchema: freezed == jsonSchema
          ? _self._jsonSchema
          : jsonSchema // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

// dart format on
