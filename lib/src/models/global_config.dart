import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dartllm/src/models/enums.dart';

part 'global_config.freezed.dart';

/// Global configuration affecting all DartLLM operations.
///
/// Apply global settings using [DartLLM.setGlobalConfig]:
///
/// ```dart
/// DartLLM.setGlobalConfig(GlobalConfig(
///   enableLogging: true,
///   logLevel: LogLevel.info,
/// ));
/// ```
///
/// Global settings apply to all subsequently loaded models.
@Freezed(toJson: false, fromJson: false)
sealed class GlobalConfig with _$GlobalConfig {
  /// Creates a global configuration with the specified parameters.
  const factory GlobalConfig({
    /// Base directory for the model cache.
    ///
    /// Downloaded models are stored here. If null, uses the
    /// platform-specific default:
    /// - Android: app's external cache directory
    /// - iOS/macOS: app's caches directory
    /// - Windows/Linux: user's cache directory
    String? defaultCacheDirectory,

    /// Default GPU layer count for new models.
    ///
    /// Applied when loading models without explicit gpuLayers config.
    /// - `-1`: Automatic detection
    /// - `0`: CPU only
    /// - `n > 0`: Offload n layers
    ///
    /// Default: -1 (automatic)
    @Default(-1) int defaultGpuLayers,

    /// Default CPU thread count for new models.
    ///
    /// Applied when loading models without explicit thread config.
    /// - `0`: Automatic detection
    /// - `n > 0`: Use n threads
    ///
    /// Default: 0 (automatic)
    @Default(0) int defaultThreadCount,

    /// Whether to enable internal debug logging.
    ///
    /// When enabled, DartLLM outputs diagnostic information through
    /// the logging system. Useful for debugging but may impact performance.
    /// Default: false
    @Default(false) bool enableLogging,

    /// Minimum log level to output.
    ///
    /// Only messages at this level or higher are logged.
    /// Default: LogLevel.warning
    @Default(LogLevel.warning) LogLevel logLevel,

    /// HuggingFace API token for accessing private repositories.
    ///
    /// Required when downloading models from private HuggingFace repos.
    /// Keep this value secure and never log it.
    String? huggingFaceToken,
  }) = _GlobalConfig;

  const GlobalConfig._();

  /// Creates a configuration with verbose logging enabled.
  ///
  /// Useful during development and debugging.
  factory GlobalConfig.debug() => const GlobalConfig(
        enableLogging: true,
        logLevel: LogLevel.debug,
      );

  /// Creates a production configuration with minimal logging.
  factory GlobalConfig.production() => const GlobalConfig(
        enableLogging: true,
        logLevel: LogLevel.error,
      );
}
