import 'package:freezed_annotation/freezed_annotation.dart';

part 'usage_stats.freezed.dart';

/// Token usage statistics for a generation request.
///
/// Provides information about how many tokens were used in the prompt
/// and generation, useful for monitoring usage and costs.
@Freezed(toJson: false, fromJson: false)
sealed class UsageStats with _$UsageStats {
  /// Creates usage statistics with the given token counts.
  const factory UsageStats({
    /// Number of tokens in the input prompt.
    ///
    /// For chat completions, this includes all messages in the
    /// conversation history after chat template formatting.
    required int promptTokens,

    /// Number of tokens generated in the response.
    required int completionTokens,
  }) = _UsageStats;

  const UsageStats._();

  /// Total tokens used (prompt + completion).
  int get totalTokens => promptTokens + completionTokens;
}
