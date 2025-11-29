import 'dart:async';
import 'dart:typed_data';

import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/model_config.dart';
import 'package:dartllm/src/models/model_info.dart';

/// Handle to a loaded model in native memory.
///
/// This is an opaque identifier used to reference the model
/// across the FFI/WASM boundary. The actual implementation
/// varies by platform.
typedef ModelHandle = int;

/// Request to load a model from a file path.
class LoadModelRequest {
  /// Path to the GGUF model file.
  final String modelPath;

  /// Configuration options for model loading.
  final ModelConfig config;

  /// Creates a model load request.
  const LoadModelRequest({
    required this.modelPath,
    required this.config,
  });
}

/// Result of a successful model load operation.
class LoadModelResult {
  /// Handle to the loaded model.
  final ModelHandle handle;

  /// Information about the loaded model.
  final ModelInfo modelInfo;

  /// Creates a model load result.
  const LoadModelResult({
    required this.handle,
    required this.modelInfo,
  });
}

/// Request to generate text from a prompt.
class GenerateRequest {
  /// Handle to the model to use.
  final ModelHandle modelHandle;

  /// Tokenized prompt as token IDs.
  final List<int> promptTokens;

  /// Maximum number of tokens to generate.
  final int maxTokens;

  /// Sampling temperature.
  final double temperature;

  /// Top-P (nucleus sampling) threshold.
  final double topP;

  /// Top-K sampling limit.
  final int topK;

  /// Minimum probability threshold.
  final double minP;

  /// Penalty for repeated tokens.
  final double repetitionPenalty;

  /// Penalty based on token frequency.
  final double frequencyPenalty;

  /// Penalty for token presence.
  final double presencePenalty;

  /// Number of recent tokens to consider for repetition penalty.
  final int repeatLastN;

  /// Token IDs that trigger generation stop.
  final List<int> stopTokens;

  /// Random seed for reproducibility (null for random).
  final int? seed;

  /// Creates a generation request.
  const GenerateRequest({
    required this.modelHandle,
    required this.promptTokens,
    required this.maxTokens,
    required this.temperature,
    required this.topP,
    required this.topK,
    required this.minP,
    required this.repetitionPenalty,
    required this.frequencyPenalty,
    required this.presencePenalty,
    required this.repeatLastN,
    required this.stopTokens,
    this.seed,
  });
}

/// Result of a text generation operation.
class GenerateResult {
  /// Generated token IDs.
  final List<int> tokens;

  /// Number of tokens in the prompt.
  final int promptTokenCount;

  /// Number of tokens generated.
  final int completionTokenCount;

  /// Why generation stopped.
  final FinishReason finishReason;

  /// Time spent generating in milliseconds.
  final int generationTimeMs;

  /// Creates a generation result.
  const GenerateResult({
    required this.tokens,
    required this.promptTokenCount,
    required this.completionTokenCount,
    required this.finishReason,
    required this.generationTimeMs,
  });
}

/// A single token generated during streaming.
class GenerateStreamChunk {
  /// The generated token ID.
  final int token;

  /// Why generation stopped (null if not finished).
  final FinishReason? finishReason;

  /// Creates a stream chunk.
  const GenerateStreamChunk({
    required this.token,
    this.finishReason,
  });

  /// Whether this is the final chunk.
  bool get isLast => finishReason != null;
}

/// Request to generate embeddings.
class EmbedRequest {
  /// Handle to the model to use.
  final ModelHandle modelHandle;

  /// Tokenized text as token IDs.
  final List<int> tokens;

  /// Whether to L2-normalize the output.
  final bool normalize;

  /// Creates an embedding request.
  const EmbedRequest({
    required this.modelHandle,
    required this.tokens,
    required this.normalize,
  });
}

/// Result of an embedding operation.
class EmbedResult {
  /// The embedding vector.
  final Float32List embedding;

  /// Creates an embedding result.
  const EmbedResult({
    required this.embedding,
  });
}

/// Request to tokenize text.
class TokenizeRequest {
  /// Handle to the model to use.
  final ModelHandle modelHandle;

  /// Text to tokenize.
  final String text;

  /// Whether to add BOS/EOS special tokens.
  final bool addSpecialTokens;

  /// Creates a tokenization request.
  const TokenizeRequest({
    required this.modelHandle,
    required this.text,
    required this.addSpecialTokens,
  });
}

/// Request to detokenize token IDs.
class DetokenizeRequest {
  /// Handle to the model to use.
  final ModelHandle modelHandle;

  /// Token IDs to convert to text.
  final List<int> tokens;

  /// Creates a detokenization request.
  const DetokenizeRequest({
    required this.modelHandle,
    required this.tokens,
  });
}

/// Abstract interface for platform-specific LLM operations.
///
/// This interface defines the contract between the Dart API layer
/// and the native inference backend. Implementations handle the
/// platform-specific details of communicating with llama.cpp.
///
/// Two implementations exist:
/// - [NativeBinding]: Uses Dart FFI for native platforms
/// - [WasmBinding]: Uses JS interop for web platform
abstract interface class PlatformBinding {
  /// Loads a model from the specified path.
  ///
  /// Returns a [LoadModelResult] containing the model handle and metadata.
  ///
  /// Throws:
  /// - [ModelNotFoundException] if the file does not exist
  /// - [InvalidModelException] if the file is not a valid GGUF model
  /// - [InsufficientMemoryException] if there is not enough memory
  Future<LoadModelResult> loadModel(LoadModelRequest request);

  /// Unloads a previously loaded model and frees its resources.
  ///
  /// After calling this method, the model handle becomes invalid.
  Future<void> unloadModel(ModelHandle handle);

  /// Generates a complete response for the given prompt.
  ///
  /// This method blocks until generation is complete or an error occurs.
  Future<GenerateResult> generate(GenerateRequest request);

  /// Generates a streaming response for the given prompt.
  ///
  /// Yields [GenerateStreamChunk] objects as tokens are generated.
  /// The final chunk will have a non-null [finishReason].
  Stream<GenerateStreamChunk> generateStream(GenerateRequest request);

  /// Generates vector embeddings for the given tokens.
  ///
  /// Only works with models that support embedding generation.
  Future<EmbedResult> embed(EmbedRequest request);

  /// Converts text to token IDs using the model's tokenizer.
  Future<List<int>> tokenize(TokenizeRequest request);

  /// Converts token IDs back to text using the model's tokenizer.
  Future<String> detokenize(DetokenizeRequest request);

  /// Gets information about a loaded model.
  Future<ModelInfo> getModelInfo(ModelHandle handle);

  /// Checks if the platform supports GPU acceleration.
  bool get supportsGpu;

  /// Checks if the platform supports multi-threading.
  bool get supportsMultiThreading;

  /// Releases all resources held by this binding.
  ///
  /// After calling dispose, the binding becomes unusable.
  void dispose();
}
