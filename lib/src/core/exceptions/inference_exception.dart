import 'package:dartllm/src/core/exceptions/dartllm_exception.dart';

/// Base exception for inference-related errors.
///
/// Thrown when errors occur during the inference process, including
/// text generation, tokenization, and sampling operations.
class InferenceException extends DartLLMException {
  /// Creates an inference exception with the given [message].
  ///
  /// Optionally provide a [cause] to preserve the original error.
  const InferenceException(super.message, {super.cause});

  @override
  String toString() {
    if (cause != null) {
      return 'InferenceException: $message (caused by: $cause)';
    }
    return 'InferenceException: $message';
  }
}

/// Thrown when text generation fails.
///
/// This exception indicates that the model encountered an error
/// while generating tokens. This may occur due to:
/// - Internal model errors
/// - Invalid generation configuration
/// - Native code failures
/// - Resource exhaustion during generation
class GenerationException extends InferenceException {
  /// The number of tokens successfully generated before the error.
  final int? tokensGenerated;

  /// Creates an exception indicating generation failure.
  ///
  /// Optionally provide [tokensGenerated] to indicate how many
  /// tokens were successfully produced before the failure.
  const GenerationException(
    super.message, {
    this.tokensGenerated,
    super.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('GenerationException: $message');
    if (tokensGenerated != null) {
      buffer.write(' (generated $tokensGenerated tokens before failure)');
    }
    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }
    return buffer.toString();
  }
}

/// Thrown when tokenization fails.
///
/// This exception indicates that the text could not be converted
/// to tokens or that tokens could not be decoded back to text.
/// This may occur due to:
/// - Invalid Unicode sequences
/// - Characters not in the model's vocabulary
/// - Corrupted token data
class TokenizationException extends InferenceException {
  /// The text that failed to tokenize, if available.
  ///
  /// May be truncated for very long inputs.
  final String? inputText;

  /// The position in the input where tokenization failed.
  final int? failurePosition;

  /// Creates an exception indicating tokenization failure.
  ///
  /// Optionally provide [inputText] (the text being tokenized) and
  /// [failurePosition] (where in the text the error occurred).
  const TokenizationException(
    super.message, {
    this.inputText,
    this.failurePosition,
    super.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('TokenizationException: $message');
    if (failurePosition != null) {
      buffer.write(' (at position $failurePosition)');
    }
    if (inputText != null) {
      final truncated = inputText!.length > 50
          ? '${inputText!.substring(0, 50)}...'
          : inputText;
      buffer.write(' [input: "$truncated"]');
    }
    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }
    return buffer.toString();
  }
}

/// Thrown when token sampling fails.
///
/// This exception indicates that the sampler could not select
/// the next token from the model's probability distribution.
/// This may occur due to:
/// - Invalid sampling parameters
/// - Numerical instability (NaN or infinity in logits)
/// - All tokens having zero probability after filtering
class SamplingException extends InferenceException {
  /// The sampling parameter that caused the issue, if known.
  final String? parameterName;

  /// The problematic value of the parameter.
  final Object? parameterValue;

  /// Creates an exception indicating sampling failure.
  ///
  /// Optionally provide [parameterName] and [parameterValue] if
  /// the error is related to a specific sampling configuration.
  const SamplingException(
    super.message, {
    this.parameterName,
    this.parameterValue,
    super.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('SamplingException: $message');
    if (parameterName != null && parameterValue != null) {
      buffer.write(' ($parameterName=$parameterValue)');
    }
    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }
    return buffer.toString();
  }
}
