import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dartllm/src/models/enums.dart';

part 'model_config.freezed.dart';

/// Configuration for model loading behavior.
///
/// Controls how models are loaded into memory, including context size,
/// GPU offloading, threading, and caching options.
///
/// ```dart
/// final config = ModelConfig(
///   contextSize: 4096,
///   gpuLayers: -1, // Auto-detect
/// );
/// final model = await DartLLM.loadModel(path: 'model.gguf', config: config);
/// ```
@Freezed(toJson: false, fromJson: false)
sealed class ModelConfig with _$ModelConfig {
  /// Creates a model configuration with the specified parameters.
  const factory ModelConfig({
    /// Maximum context length in tokens.
    ///
    /// Larger values allow longer conversations but require more memory.
    /// If null, uses the model's default context size.
    int? contextSize,

    /// Number of layers to offload to GPU.
    ///
    /// - `-1`: Automatic detection (offload as many as fit in VRAM)
    /// - `0`: CPU only, no GPU acceleration
    /// - `n > 0`: Offload exactly n layers to GPU
    ///
    /// Default: -1 (automatic)
    @Default(-1) int gpuLayers,

    /// Number of CPU threads for inference.
    ///
    /// - `0`: Automatic detection (uses optimal thread count)
    /// - `n > 0`: Use exactly n threads
    ///
    /// More threads can improve performance but may cause contention.
    /// Default: 0 (automatic)
    @Default(0) int threads,

    /// Batch size for prompt processing.
    ///
    /// Larger values process prompts faster but use more memory.
    /// Default: 512
    @Default(512) int batchSize,

    /// RoPE frequency base override.
    ///
    /// Used for context extension techniques. Leave null for model default.
    double? ropeFrequencyBase,

    /// RoPE frequency scale override.
    ///
    /// Used for context extension techniques. Leave null for model default.
    double? ropeFrequencyScale,

    /// Whether to memory-map the model file.
    ///
    /// Memory mapping reduces initial load time and memory usage by
    /// loading model weights on demand. Recommended for most use cases.
    /// Default: true
    @Default(true) bool useMemoryMap,

    /// Whether to lock model memory to prevent swapping.
    ///
    /// Prevents the OS from swapping model memory to disk, ensuring
    /// consistent performance. May require elevated privileges.
    /// Default: false
    @Default(false) bool lockMemory,

    /// Quantization level for the KV cache.
    ///
    /// Lower precision reduces memory usage at the cost of slight
    /// quality decrease. f16 is full precision, q8_0 and q4_0 are
    /// progressively more aggressive quantization.
    /// Default: f16
    @Default(KVCacheType.f16) KVCacheType kvCacheType,

    /// Directory for storing downloaded models.
    ///
    /// If null, uses the platform-specific default cache directory.
    String? cacheDirectory,
  }) = _ModelConfig;

  const ModelConfig._();

  /// Creates a configuration optimized for low memory usage.
  ///
  /// Suitable for mobile devices or systems with limited RAM.
  factory ModelConfig.lowMemory() => const ModelConfig(
        gpuLayers: 0,
        kvCacheType: KVCacheType.q4_0,
        batchSize: 256,
        useMemoryMap: true,
      );

  /// Creates a configuration optimized for maximum performance.
  ///
  /// Uses GPU acceleration and larger batch sizes.
  factory ModelConfig.performance() => const ModelConfig(
        gpuLayers: -1,
        kvCacheType: KVCacheType.f16,
        batchSize: 1024,
        lockMemory: true,
      );
}
