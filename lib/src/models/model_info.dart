import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_info.freezed.dart';

/// Metadata about a loaded LLM model.
///
/// Contains information extracted from the GGUF file including
/// the model's architecture, size, and capabilities.
///
/// Access via [LLMModel.modelInfo]:
/// ```dart
/// final model = await DartLLM.loadModel(path: 'model.gguf');
/// print('Loaded ${model.modelInfo.name}');
/// print('Parameters: ${model.modelInfo.parameterCount}');
/// ```
@Freezed(toJson: false, fromJson: false)
sealed class ModelInfo with _$ModelInfo {
  /// Creates model metadata.
  const factory ModelInfo({
    /// The model's name from metadata or filename.
    required String name,

    /// Total number of parameters in the model.
    ///
    /// For example, a 7B model has approximately 7,000,000,000 parameters.
    required int parameterCount,

    /// The model architecture (e.g., "llama", "mistral", "phi").
    required String architecture,

    /// The quantization method used (e.g., "Q4_K_M", "Q5_K_S", "F16").
    required String quantization,

    /// The model's native context size in tokens.
    ///
    /// This is the maximum context the model was trained with.
    /// May be extended using RoPE scaling in ModelConfig.
    required int contextSize,

    /// Size of the model's vocabulary (number of unique tokens).
    required int vocabularySize,

    /// Dimension of token embeddings.
    required int embeddingSize,

    /// Number of layers in the model.
    required int layerCount,

    /// Number of attention heads.
    required int headCount,

    /// Whether this model supports generating embeddings.
    @Default(false) bool supportsEmbedding,

    /// Whether this model supports vision/image inputs.
    @Default(false) bool supportsVision,

    /// File size in bytes.
    required int fileSizeBytes,

    /// The chat template format if detected (e.g., "chatml", "llama2").
    String? chatTemplate,
  }) = _ModelInfo;

  const ModelInfo._();

  /// Human-readable parameter count (e.g., "7B", "13B").
  String get parameterCountFormatted {
    if (parameterCount >= 1e12) {
      return '${(parameterCount / 1e12).toStringAsFixed(1)}T';
    } else if (parameterCount >= 1e9) {
      return '${(parameterCount / 1e9).toStringAsFixed(1)}B';
    } else if (parameterCount >= 1e6) {
      return '${(parameterCount / 1e6).toStringAsFixed(1)}M';
    }
    return parameterCount.toString();
  }

  /// Human-readable file size (e.g., "4.2 GB").
  String get fileSizeFormatted {
    if (fileSizeBytes >= 1e9) {
      return '${(fileSizeBytes / 1e9).toStringAsFixed(1)} GB';
    } else if (fileSizeBytes >= 1e6) {
      return '${(fileSizeBytes / 1e6).toStringAsFixed(1)} MB';
    } else if (fileSizeBytes >= 1e3) {
      return '${(fileSizeBytes / 1e3).toStringAsFixed(1)} KB';
    }
    return '$fileSizeBytes B';
  }
}

/// Information about a model stored in the local cache.
///
/// Returned by [DartLLM.listCachedModels] to enumerate downloaded models.
@Freezed(toJson: false, fromJson: false)
sealed class CachedModelInfo with _$CachedModelInfo {
  /// Creates cached model info.
  const factory CachedModelInfo({
    /// Unique identifier for this cached model.
    ///
    /// Based on the source (HuggingFace repo/file or URL hash).
    required String modelId,

    /// Absolute path to the cached model file.
    required String filePath,

    /// Size of the cached file in bytes.
    required int sizeBytes,

    /// When the model was downloaded.
    required DateTime downloadedAt,

    /// The original download source URL or HuggingFace reference.
    required String sourceUrl,

    /// Model metadata if available, null if not yet loaded.
    ModelInfo? modelInfo,
  }) = _CachedModelInfo;

  const CachedModelInfo._();

  /// Human-readable file size (e.g., "4.2 GB").
  String get sizeFormatted {
    if (sizeBytes >= 1e9) {
      return '${(sizeBytes / 1e9).toStringAsFixed(1)} GB';
    } else if (sizeBytes >= 1e6) {
      return '${(sizeBytes / 1e6).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / 1e3).toStringAsFixed(1)} KB';
  }
}
