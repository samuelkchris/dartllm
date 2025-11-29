import 'package:freezed_annotation/freezed_annotation.dart';

part 'generation_config.freezed.dart';

/// Configuration for text generation behavior.
///
/// Controls how the model generates text, including sampling parameters,
/// repetition penalties, and stopping conditions.
///
/// All parameters have sensible defaults suitable for general use.
/// Use [copyWith] to create modified configurations:
///
/// ```dart
/// final config = GenerationConfig(maxTokens: 500);
/// final creative = config.copyWith(temperature: 1.2, topP: 0.95);
/// ```
@Freezed(toJson: false, fromJson: false)
sealed class GenerationConfig with _$GenerationConfig {
  /// Creates a generation configuration with the specified parameters.
  ///
  /// All parameters are optional and have sensible defaults.
  const factory GenerationConfig({
    /// Maximum number of tokens to generate.
    ///
    /// Generation stops when this limit is reached, even if the response
    /// is incomplete. Set higher for longer responses.
    /// Default: 1024
    @Default(1024) int maxTokens,

    /// Sampling temperature controlling randomness.
    ///
    /// Higher values (e.g., 1.5) produce more creative, varied outputs.
    /// Lower values (e.g., 0.2) produce more focused, deterministic outputs.
    /// Range: 0.0 to 2.0. Default: 0.7
    @Default(0.7) double temperature,

    /// Nucleus sampling threshold.
    ///
    /// Only tokens with cumulative probability up to this value are
    /// considered. Lower values focus on more likely tokens.
    /// Range: 0.0 to 1.0. Default: 0.9
    @Default(0.9) double topP,

    /// Top-K sampling limit.
    ///
    /// Only the K most likely tokens are considered at each step.
    /// Lower values increase focus, higher values increase variety.
    /// Range: 1 to vocabulary size. Default: 40
    @Default(40) int topK,

    /// Minimum probability threshold.
    ///
    /// Tokens with probability below this threshold relative to the
    /// most likely token are excluded from sampling.
    /// Range: 0.0 to 1.0. Default: 0.05
    @Default(0.05) double minP,

    /// Penalty applied to tokens that have been used recently.
    ///
    /// Values > 1.0 discourage repetition, making the model less
    /// likely to repeat the same phrases.
    /// Range: 1.0 to 2.0. Default: 1.1
    @Default(1.1) double repetitionPenalty,

    /// Penalty based on how frequently a token has appeared.
    ///
    /// Applied proportionally to token frequency in the generated text.
    /// Range: 0.0 to 2.0. Default: 0.0
    @Default(0.0) double frequencyPenalty,

    /// Penalty for tokens that have appeared at all.
    ///
    /// Applied equally to all tokens that have been generated.
    /// Range: 0.0 to 2.0. Default: 0.0
    @Default(0.0) double presencePenalty,

    /// Number of recent tokens to consider for repetition penalty.
    ///
    /// The penalty only applies to tokens within this window.
    /// Default: 64
    @Default(64) int repeatLastN,

    /// Strings that trigger generation to stop when encountered.
    ///
    /// The stop sequence itself is not included in the output.
    @Default([]) List<String> stopSequences,

    /// Random seed for reproducible generation.
    ///
    /// Using the same seed with identical inputs produces the same
    /// output. Null uses a random seed each time.
    int? seed,

    /// GBNF grammar for constrained generation.
    ///
    /// When specified, the model's output is constrained to match
    /// the provided grammar, useful for structured output.
    String? grammar,

    /// JSON schema for structured output.
    ///
    /// When specified, the model generates valid JSON matching
    /// the schema. Cannot be used with [grammar].
    Map<String, dynamic>? jsonSchema,
  }) = _GenerationConfig;

  const GenerationConfig._();

  /// Creates a configuration optimized for creative writing.
  ///
  /// Higher temperature and top-p for more varied, creative outputs.
  factory GenerationConfig.creative() => const GenerationConfig(
        temperature: 1.2,
        topP: 0.95,
        topK: 100,
        repetitionPenalty: 1.15,
      );

  /// Creates a configuration optimized for factual/precise responses.
  ///
  /// Lower temperature for more focused, deterministic outputs.
  factory GenerationConfig.precise() => const GenerationConfig(
        temperature: 0.3,
        topP: 0.8,
        topK: 20,
        repetitionPenalty: 1.05,
      );

  /// Creates a configuration for code generation.
  ///
  /// Balanced settings optimized for generating code.
  factory GenerationConfig.code() => const GenerationConfig(
        temperature: 0.4,
        topP: 0.9,
        topK: 40,
        repetitionPenalty: 1.0,
        stopSequences: ['```', '// END'],
      );
}
