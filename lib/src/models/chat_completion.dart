import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dartllm/src/models/chat_message.dart';
import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/usage_stats.dart';

part 'chat_completion.freezed.dart';

/// The complete response from a chat generation request.
///
/// Contains the generated assistant message, token usage statistics,
/// and information about why generation stopped.
///
/// ```dart
/// final completion = await model.chat(messages);
/// print(completion.message.content);
/// print('Used ${completion.usage.totalTokens} tokens');
/// ```
@Freezed(toJson: false, fromJson: false)
sealed class ChatCompletion with _$ChatCompletion {
  /// Creates a chat completion response.
  const factory ChatCompletion({
    /// The generated assistant message.
    required AssistantMessage message,

    /// Token usage statistics for this request.
    required UsageStats usage,

    /// The reason generation stopped.
    required FinishReason finishReason,

    /// Time spent generating the response in milliseconds.
    required int generationTimeMs,
  }) = _ChatCompletion;

  const ChatCompletion._();

  /// Generation speed in tokens per second.
  double get tokensPerSecond {
    if (generationTimeMs == 0) return 0;
    return usage.completionTokens / (generationTimeMs / 1000);
  }
}

/// An incremental chunk from a streaming chat generation.
///
/// Received during [LLMModel.chatStream] as tokens are generated.
/// Each chunk contains a delta with new content.
///
/// ```dart
/// await for (final chunk in model.chatStream(messages)) {
///   stdout.write(chunk.delta.content);
///   if (chunk.finishReason != null) {
///     print('\nDone: ${chunk.finishReason}');
///   }
/// }
/// ```
@Freezed(toJson: false, fromJson: false)
sealed class ChatCompletionChunk with _$ChatCompletionChunk {
  /// Creates a chat completion chunk.
  const factory ChatCompletionChunk({
    /// The incremental content in this chunk.
    required MessageDelta delta,

    /// The reason generation stopped, if this is the final chunk.
    ///
    /// Null for all chunks except the last one.
    FinishReason? finishReason,
  }) = _ChatCompletionChunk;

  const ChatCompletionChunk._();

  /// Whether this is the final chunk in the stream.
  bool get isLast => finishReason != null;
}

/// Incremental content in a streaming response chunk.
///
/// Contains the new tokens generated since the previous chunk.
@Freezed(toJson: false, fromJson: false)
sealed class MessageDelta with _$MessageDelta {
  /// Creates a message delta with new content.
  const factory MessageDelta({
    /// The new content generated in this chunk.
    ///
    /// May be empty for the initial chunk or partial tokens.
    @Default('') String content,

    /// The role of the message being generated.
    ///
    /// Typically only present in the first chunk.
    MessageRole? role,
  }) = _MessageDelta;

  const MessageDelta._();
}
