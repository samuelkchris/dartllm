import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/usage_stats.dart';

part 'text_completion.freezed.dart';

/// The complete response from a text completion request.
///
/// Contains the generated text, token usage statistics, and
/// information about why generation stopped.
///
/// Used with [LLMModel.complete] for raw text completion
/// without chat formatting.
///
/// ```dart
/// final completion = await model.complete('Once upon a time');
/// print(completion.text);
/// ```
@Freezed(toJson: false, fromJson: false)
sealed class TextCompletion with _$TextCompletion {
  /// Creates a text completion response.
  const factory TextCompletion({
    /// The generated text continuation.
    required String text,

    /// Token usage statistics for this request.
    required UsageStats usage,

    /// The reason generation stopped.
    required FinishReason finishReason,

    /// Time spent generating the response in milliseconds.
    required int generationTimeMs,
  }) = _TextCompletion;

  const TextCompletion._();

  /// Generation speed in tokens per second.
  double get tokensPerSecond {
    if (generationTimeMs == 0) return 0;
    return usage.completionTokens / (generationTimeMs / 1000);
  }
}

/// An incremental chunk from a streaming text completion.
///
/// Received during [LLMModel.completeStream] as tokens are generated.
///
/// ```dart
/// await for (final chunk in model.completeStream('Once upon a time')) {
///   stdout.write(chunk.text);
/// }
/// ```
@Freezed(toJson: false, fromJson: false)
sealed class TextCompletionChunk with _$TextCompletionChunk {
  /// Creates a text completion chunk.
  const factory TextCompletionChunk({
    /// The new text generated in this chunk.
    required String text,

    /// The reason generation stopped, if this is the final chunk.
    ///
    /// Null for all chunks except the last one.
    FinishReason? finishReason,
  }) = _TextCompletionChunk;

  const TextCompletionChunk._();

  /// Whether this is the final chunk in the stream.
  bool get isLast => finishReason != null;
}
