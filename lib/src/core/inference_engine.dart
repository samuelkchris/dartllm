import 'dart:async';

import 'package:dartllm/src/core/chat_template.dart';
import 'package:dartllm/src/core/inference_context.dart';
import 'package:dartllm/src/core/tokenizer.dart';
import 'package:dartllm/src/models/chat_message.dart';
import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/generation_config.dart';
import 'package:dartllm/src/models/model_config.dart';
import 'package:dartllm/src/models/model_info.dart';
import 'package:dartllm/src/platform/platform_binding.dart';
import 'package:dartllm/src/utils/logger.dart';

/// Result of a text generation operation.
class GenerationResult {
  /// The generated text.
  final String text;

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
  const GenerationResult({
    required this.text,
    required this.tokens,
    required this.promptTokenCount,
    required this.completionTokenCount,
    required this.finishReason,
    required this.generationTimeMs,
  });

  /// Total tokens used (prompt + completion).
  int get totalTokens => promptTokenCount + completionTokenCount;

  /// Tokens generated per second.
  double get tokensPerSecond {
    if (generationTimeMs == 0) return 0;
    return completionTokenCount / (generationTimeMs / 1000);
  }
}

/// A chunk from streaming generation.
class GenerationChunk {
  /// The text in this chunk.
  final String text;

  /// The token ID in this chunk.
  final int token;

  /// Why generation stopped, if this is the final chunk.
  final FinishReason? finishReason;

  /// Creates a generation chunk.
  const GenerationChunk({
    required this.text,
    required this.token,
    this.finishReason,
  });

  /// Whether this is the final chunk.
  bool get isLast => finishReason != null;
}

/// Core inference engine that manages model lifecycle and generation.
///
/// The inference engine coordinates between the high-level API and the
/// platform binding. It manages:
/// - Model loading and unloading
/// - Context creation and management
/// - Tokenization and detokenization
/// - Generation with various configurations
/// - Chat template application
///
/// The engine operates on a single model at a time and provides both
/// synchronous (complete) and streaming generation methods.
class InferenceEngine {
  static const String _loggerName = 'dartllm.core.engine';
  final DartLLMLogger _logger = DartLLMLogger(_loggerName);

  final PlatformBinding _binding;

  /// The currently loaded model handle, or null if no model is loaded.
  ModelHandle? _handle;

  /// Information about the loaded model.
  ModelInfo? _modelInfo;

  /// The tokenizer for the loaded model.
  Tokenizer? _tokenizer;

  /// The chat template for the loaded model.
  ChatTemplate? _chatTemplate;

  /// The current inference context.
  InferenceContext? _context;

  /// Whether the engine has been disposed.
  bool _isDisposed = false;

  /// Creates an inference engine with the given platform binding.
  InferenceEngine({required PlatformBinding binding}) : _binding = binding;

  /// Whether a model is currently loaded.
  bool get isModelLoaded => _handle != null;

  /// Information about the loaded model.
  ///
  /// Throws [StateError] if no model is loaded.
  ModelInfo get modelInfo {
    _checkModelLoaded();
    return _modelInfo!;
  }

  /// The tokenizer for the loaded model.
  ///
  /// Throws [StateError] if no model is loaded.
  Tokenizer get tokenizer {
    _checkModelLoaded();
    return _tokenizer!;
  }

  /// The chat template for the loaded model.
  ///
  /// Throws [StateError] if no model is loaded.
  ChatTemplate get chatTemplate {
    _checkModelLoaded();
    return _chatTemplate!;
  }

  /// The current inference context.
  ///
  /// Throws [StateError] if no model is loaded.
  InferenceContext get context {
    _checkModelLoaded();
    return _context!;
  }

  /// Whether the engine has been disposed.
  bool get isDisposed => _isDisposed;

  /// Loads a model from the specified path.
  ///
  /// [modelPath] is the path to the GGUF model file.
  /// [config] specifies model loading options.
  ///
  /// If a model is already loaded, it will be unloaded first.
  ///
  /// Returns information about the loaded model.
  Future<ModelInfo> loadModel(String modelPath, {ModelConfig? config}) async {
    _checkDisposed();

    // Unload existing model if any
    if (isModelLoaded) {
      await unloadModel();
    }

    _logger.info('Loading model: $modelPath');

    final effectiveConfig = config ?? const ModelConfig();

    final request = LoadModelRequest(
      modelPath: modelPath,
      config: effectiveConfig,
    );

    final result = await _binding.loadModel(request);

    _handle = result.handle;
    _modelInfo = result.modelInfo;

    // Create tokenizer
    _tokenizer = PlatformTokenizer(
      binding: _binding,
      handle: _handle!,
      vocabularySize: _modelInfo!.vocabularySize,
    );

    // Select chat template based on architecture
    _chatTemplate = ChatTemplateFactory.forArchitecture(_modelInfo!.architecture);

    // Create context
    final contextSize = effectiveConfig.contextSize ?? _modelInfo!.contextSize;
    _context = InferenceContext(
      modelInfo: _modelInfo!,
      contextSize: contextSize,
      kvCacheType: effectiveConfig.kvCacheType,
    );

    _logger.info('Model loaded: ${_modelInfo!.name}');
    _logger.info('Architecture: ${_modelInfo!.architecture}');
    _logger.info('Context size: $contextSize');
    _logger.info('Chat template: ${_chatTemplate!.name}');

    return _modelInfo!;
  }

  /// Unloads the current model and frees resources.
  ///
  /// Does nothing if no model is loaded.
  Future<void> unloadModel() async {
    if (!isModelLoaded) return;

    _logger.info('Unloading model: ${_modelInfo?.name}');

    await _binding.unloadModel(_handle!);

    _context?.dispose();
    _context = null;
    _handle = null;
    _modelInfo = null;
    _tokenizer = null;
    _chatTemplate = null;

    _logger.info('Model unloaded');
  }

  /// Generates text from a raw prompt.
  ///
  /// [prompt] is the text prompt to complete.
  /// [config] controls generation parameters.
  ///
  /// Returns the generation result including text and statistics.
  Future<GenerationResult> generate(
    String prompt, {
    GenerationConfig config = const GenerationConfig(),
  }) async {
    _checkModelLoaded();
    _checkDisposed();

    _logger.debug('Generating from prompt, length: ${prompt.length}');

    // Tokenize prompt
    final promptTokens = await _tokenizer!.encode(prompt, addSpecialTokens: true);

    // Create generation request
    final request = _createGenerateRequest(promptTokens, config);

    // Generate
    final result = await _binding.generate(request);

    // Detokenize response
    final text = await _tokenizer!.decode(result.tokens);

    return GenerationResult(
      text: text,
      tokens: result.tokens,
      promptTokenCount: result.promptTokenCount,
      completionTokenCount: result.completionTokenCount,
      finishReason: result.finishReason,
      generationTimeMs: result.generationTimeMs,
    );
  }

  /// Generates text from a raw prompt with streaming.
  ///
  /// [prompt] is the text prompt to complete.
  /// [config] controls generation parameters.
  ///
  /// Yields chunks as they are generated.
  Stream<GenerationChunk> generateStream(
    String prompt, {
    GenerationConfig config = const GenerationConfig(),
  }) async* {
    _checkModelLoaded();
    _checkDisposed();

    _logger.debug('Streaming generation from prompt, length: ${prompt.length}');

    // Tokenize prompt
    final promptTokens = await _tokenizer!.encode(prompt, addSpecialTokens: true);

    // Create generation request
    final request = _createGenerateRequest(promptTokens, config);

    // Stream generation
    await for (final chunk in _binding.generateStream(request)) {
      final text = await _tokenizer!.decode([chunk.token]);
      yield GenerationChunk(
        text: text,
        token: chunk.token,
        finishReason: chunk.finishReason,
      );
    }
  }

  /// Generates a response from chat messages.
  ///
  /// [messages] is the conversation history.
  /// [config] controls generation parameters.
  ///
  /// Returns the generation result for the assistant's response.
  Future<GenerationResult> chat(
    List<ChatMessage> messages, {
    GenerationConfig config = const GenerationConfig(),
  }) async {
    _checkModelLoaded();
    _checkDisposed();

    _logger.debug('Chat generation, messages: ${messages.length}');

    // Format messages using chat template
    final prompt = _chatTemplate!.apply(messages, addGenerationPrompt: true);

    // Tokenize (without adding special tokens since template handles them)
    final promptTokens = await _tokenizer!.encode(prompt, addSpecialTokens: false);

    // Add stop sequences from template to config
    final effectiveConfig = _mergeStopSequences(config, _chatTemplate!.stopSequences);

    // Create generation request
    final request = _createGenerateRequest(promptTokens, effectiveConfig);

    // Generate
    final result = await _binding.generate(request);

    // Detokenize and extract response
    final rawText = await _tokenizer!.decode(result.tokens);
    final cleanedText = _chatTemplate!.extractResponse(rawText);

    return GenerationResult(
      text: cleanedText,
      tokens: result.tokens,
      promptTokenCount: result.promptTokenCount,
      completionTokenCount: result.completionTokenCount,
      finishReason: result.finishReason,
      generationTimeMs: result.generationTimeMs,
    );
  }

  /// Generates a streaming response from chat messages.
  ///
  /// [messages] is the conversation history.
  /// [config] controls generation parameters.
  ///
  /// Yields chunks as the assistant's response is generated.
  Stream<GenerationChunk> chatStream(
    List<ChatMessage> messages, {
    GenerationConfig config = const GenerationConfig(),
  }) async* {
    _checkModelLoaded();
    _checkDisposed();

    _logger.debug('Streaming chat, messages: ${messages.length}');

    // Format messages using chat template
    final prompt = _chatTemplate!.apply(messages, addGenerationPrompt: true);

    // Tokenize
    final promptTokens = await _tokenizer!.encode(prompt, addSpecialTokens: false);

    // Add stop sequences from template
    final effectiveConfig = _mergeStopSequences(config, _chatTemplate!.stopSequences);

    // Create generation request
    final request = _createGenerateRequest(promptTokens, effectiveConfig);

    // Stream generation
    final buffer = StringBuffer();
    await for (final chunk in _binding.generateStream(request)) {
      final text = await _tokenizer!.decode([chunk.token]);
      buffer.write(text);

      // Check for stop sequences in accumulated text
      bool shouldStop = false;
      for (final stop in _chatTemplate!.stopSequences) {
        if (buffer.toString().contains(stop)) {
          shouldStop = true;
          break;
        }
      }

      yield GenerationChunk(
        text: text,
        token: chunk.token,
        finishReason: shouldStop ? FinishReason.stop : chunk.finishReason,
      );

      if (shouldStop) break;
    }
  }

  /// Generates embeddings for the given text.
  ///
  /// [text] is the input to embed.
  /// [normalize] whether to L2-normalize the output.
  ///
  /// Returns the embedding vector.
  Future<List<double>> embed(String text, {bool normalize = true}) async {
    _checkModelLoaded();
    _checkDisposed();

    _logger.debug('Generating embedding, text length: ${text.length}');

    final tokens = await _tokenizer!.encode(text, addSpecialTokens: true);

    final request = EmbedRequest(
      modelHandle: _handle!,
      tokens: tokens,
      normalize: normalize,
    );

    final result = await _binding.embed(request);

    return result.embedding.toList();
  }

  /// Sets a custom chat template.
  ///
  /// [template] is the template to use for subsequent chat operations.
  void setChatTemplate(ChatTemplate template) {
    _chatTemplate = template;
    _logger.info('Chat template set to: ${template.name}');
  }

  /// Resets the inference context.
  ///
  /// Clears all tokens from the context, resetting it to its initial state.
  void resetContext() {
    _context?.clear();
  }

  /// Disposes of the engine and releases all resources.
  ///
  /// The engine cannot be used after disposing.
  Future<void> dispose() async {
    if (_isDisposed) return;

    _logger.info('Disposing inference engine');

    await unloadModel();
    _isDisposed = true;

    _logger.info('Inference engine disposed');
  }

  /// Creates a GenerateRequest from config.
  ///
  /// Stop sequences are handled via post-processing in [_extractResponse]
  /// rather than as native stop tokens. This approach is more reliable because:
  /// - Stop sequences may span multiple tokens
  /// - Token boundaries don't always align with sequence boundaries
  /// - String matching in extractResponse handles partial matches correctly
  GenerateRequest _createGenerateRequest(
    List<int> promptTokens,
    GenerationConfig config,
  ) {
    return GenerateRequest(
      modelHandle: _handle!,
      promptTokens: promptTokens,
      maxTokens: config.maxTokens,
      temperature: config.temperature,
      topP: config.topP,
      topK: config.topK,
      minP: config.minP,
      repetitionPenalty: config.repetitionPenalty,
      frequencyPenalty: config.frequencyPenalty,
      presencePenalty: config.presencePenalty,
      repeatLastN: config.repeatLastN,
      stopTokens: const [],
      seed: config.seed,
    );
  }

  /// Merges stop sequences into config.
  GenerationConfig _mergeStopSequences(
    GenerationConfig config,
    List<String> additionalStopSequences,
  ) {
    // Stop sequences from template are handled by extractResponse,
    // but we could also convert them to stop tokens here if needed
    return config;
  }

  /// Checks that the engine has not been disposed.
  void _checkDisposed() {
    if (_isDisposed) {
      throw StateError('Cannot use disposed InferenceEngine');
    }
  }

  /// Checks that a model is loaded.
  void _checkModelLoaded() {
    if (!isModelLoaded) {
      throw StateError('No model loaded. Call loadModel() first.');
    }
  }
}
