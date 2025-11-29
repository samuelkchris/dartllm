/// Enumerations used throughout DartLLM.
///
/// This library contains all enum types used by the public API
/// and internal components.
library;

/// The role of a message in a conversation.
///
/// DartLLM uses a message-based API compatible with the OpenAI
/// chat format. Each message has a role that determines how
/// it is processed by the model.
enum MessageRole {
  /// A system message that establishes the assistant's behavior.
  ///
  /// System messages are processed first and set the context,
  /// personality, and constraints for the assistant. They are
  /// typically not visible to end users.
  ///
  /// Example: "You are a helpful coding assistant."
  system,

  /// A message from the human user.
  ///
  /// User messages contain the input that the model should
  /// respond to. For multimodal models, user messages may
  /// also include images.
  user,

  /// A message from the AI assistant.
  ///
  /// Assistant messages represent the model's responses. When
  /// included in conversation history, they help maintain
  /// context for multi-turn conversations.
  assistant,
}

/// The reason why text generation stopped.
///
/// When the model finishes generating text, it provides a
/// finish reason indicating why generation ended.
enum FinishReason {
  /// Generation stopped because the maximum token limit was reached.
  ///
  /// This indicates that the response was truncated. Consider
  /// increasing maxTokens in GenerationConfig if you need
  /// longer responses.
  length,

  /// Generation stopped because a stop sequence was encountered.
  ///
  /// The model generated one of the configured stop sequences
  /// (or the end-of-sequence token), indicating a natural
  /// completion point.
  stop,

  /// Generation stopped due to an error.
  ///
  /// An error occurred during generation. Check the associated
  /// exception for details about what went wrong.
  error,
}

/// The quantization type for the key-value cache.
///
/// The KV cache stores attention states for previously processed
/// tokens. Lower precision reduces memory usage at the cost of
/// a slight quality decrease.
enum KVCacheType {
  /// 16-bit floating point (half precision).
  ///
  /// Full precision KV cache with no quality loss.
  /// Uses the most memory.
  f16,

  /// 8-bit quantization.
  ///
  /// Reduces KV cache memory by approximately 50% with
  /// minimal quality impact. Recommended for most use cases
  /// where memory is constrained.
  q8_0,

  /// 4-bit quantization.
  ///
  /// Reduces KV cache memory by approximately 75%. May have
  /// a small impact on output quality for some models.
  /// Use when memory is severely constrained.
  q4_0,
}

/// The log level for internal logging.
///
/// Controls the verbosity of DartLLM's internal logging output.
/// Logs are disabled by default and must be enabled via GlobalConfig.
enum LogLevel {
  /// Only log errors that prevent normal operation.
  ///
  /// Use in production to minimize log noise while still
  /// capturing critical issues.
  error,

  /// Log warnings and errors.
  ///
  /// Warnings indicate potential issues that don't prevent
  /// operation but may indicate problems (e.g., GPU fallback).
  warning,

  /// Log informational messages, warnings, and errors.
  ///
  /// Info messages include model loading, configuration details,
  /// and performance metrics.
  info,

  /// Log all messages including debug information.
  ///
  /// Debug logs include detailed internal state, memory usage,
  /// and timing information. Use only during development.
  debug,
}
