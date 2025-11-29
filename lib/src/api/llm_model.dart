import 'dart:async';

import 'package:dartllm/src/core/chat_template.dart';
import 'package:dartllm/src/core/inference_engine.dart';
import 'package:dartllm/src/models/chat_completion.dart';
import 'package:dartllm/src/models/chat_message.dart';
import 'package:dartllm/src/models/generation_config.dart';
import 'package:dartllm/src/models/model_info.dart';
import 'package:dartllm/src/models/text_completion.dart';
import 'package:dartllm/src/models/usage_stats.dart';

/// A loaded LLM model that can perform inference.
///
/// LLMModel provides the main interface for interacting with a loaded model.
/// It supports:
/// - Chat completion with conversation history
/// - Text completion from prompts
/// - Text embedding generation
/// - Token counting and manipulation
///
/// Models must be disposed when no longer needed to free resources.
///
/// Example usage:
/// ```dart
/// final model = await DartLLM.loadModel('path/to/model.gguf');
///
/// // Chat completion
/// final response = await model.chat([
///   ChatMessage.system('You are a helpful assistant.'),
///   ChatMessage.user('Hello!'),
/// ]);
/// print(response.message.content);
///
/// // Streaming
/// await for (final chunk in model.chatStream([
///   ChatMessage.user('Tell me a story'),
/// ])) {
///   stdout.write(chunk.delta.content);
/// }
///
/// // Clean up
/// model.dispose();
/// ```
class LLMModel {
  final InferenceEngine _engine;
  bool _isDisposed = false;

  /// Creates an LLMModel wrapping the given inference engine.
  ///
  /// This constructor is internal. Use [DartLLM.loadModel] to load models.
  LLMModel.internal(this._engine);

  /// Information about the loaded model.
  ///
  /// Throws [StateError] if the model has been disposed.
  ModelInfo get modelInfo {
    _checkDisposed();
    return _engine.modelInfo;
  }

  /// Whether this model has been disposed.
  bool get isDisposed => _isDisposed;

  /// The context size available for this model.
  ///
  /// This is the maximum number of tokens that can fit in the context window.
  /// Throws [StateError] if the model has been disposed.
  int get contextSize {
    _checkDisposed();
    return _engine.context.contextSize;
  }

  /// The current number of tokens in the context.
  ///
  /// Throws [StateError] if the model has been disposed.
  int get tokenCount {
    _checkDisposed();
    return _engine.context.tokenCount;
  }

  /// The remaining capacity in tokens.
  ///
  /// Throws [StateError] if the model has been disposed.
  int get remainingCapacity {
    _checkDisposed();
    return _engine.context.remainingCapacity;
  }

  /// The chat template being used for this model.
  ///
  /// Throws [StateError] if the model has been disposed.
  ChatTemplate get chatTemplate {
    _checkDisposed();
    return _engine.chatTemplate;
  }

  /// Generates a chat completion from the given messages.
  ///
  /// [messages] is the conversation history.
  /// [config] controls generation parameters.
  ///
  /// Returns a [ChatCompletion] containing the assistant's response.
  ///
  /// Throws [StateError] if the model has been disposed.
  Future<ChatCompletion> chat(
    List<ChatMessage> messages, {
    GenerationConfig? config,
  }) async {
    _checkDisposed();

    final effectiveConfig = config ?? const GenerationConfig();
    final result = await _engine.chat(messages, config: effectiveConfig);

    return ChatCompletion(
      message: AssistantMessage(result.text),
      usage: UsageStats(
        promptTokens: result.promptTokenCount,
        completionTokens: result.completionTokenCount,
      ),
      finishReason: result.finishReason,
      generationTimeMs: result.generationTimeMs,
    );
  }

  /// Generates a streaming chat completion from the given messages.
  ///
  /// [messages] is the conversation history.
  /// [config] controls generation parameters.
  ///
  /// Yields [ChatCompletionChunk] instances as the response is generated.
  ///
  /// Throws [StateError] if the model has been disposed.
  Stream<ChatCompletionChunk> chatStream(
    List<ChatMessage> messages, {
    GenerationConfig? config,
  }) async* {
    _checkDisposed();

    final effectiveConfig = config ?? const GenerationConfig();

    await for (final chunk in _engine.chatStream(
      messages,
      config: effectiveConfig,
    )) {
      yield ChatCompletionChunk(
        delta: MessageDelta(content: chunk.text),
        finishReason: chunk.finishReason,
      );
    }
  }

  /// Generates a text completion from the given prompt.
  ///
  /// [prompt] is the text to complete.
  /// [config] controls generation parameters.
  ///
  /// Returns a [TextCompletion] containing the generated text.
  ///
  /// Throws [StateError] if the model has been disposed.
  Future<TextCompletion> complete(
    String prompt, {
    GenerationConfig? config,
  }) async {
    _checkDisposed();

    final effectiveConfig = config ?? const GenerationConfig();
    final result = await _engine.generate(prompt, config: effectiveConfig);

    return TextCompletion(
      text: result.text,
      usage: UsageStats(
        promptTokens: result.promptTokenCount,
        completionTokens: result.completionTokenCount,
      ),
      finishReason: result.finishReason,
      generationTimeMs: result.generationTimeMs,
    );
  }

  /// Generates a streaming text completion from the given prompt.
  ///
  /// [prompt] is the text to complete.
  /// [config] controls generation parameters.
  ///
  /// Yields [TextCompletionChunk] instances as the text is generated.
  ///
  /// Throws [StateError] if the model has been disposed.
  Stream<TextCompletionChunk> completeStream(
    String prompt, {
    GenerationConfig? config,
  }) async* {
    _checkDisposed();

    final effectiveConfig = config ?? const GenerationConfig();

    await for (final chunk in _engine.generateStream(
      prompt,
      config: effectiveConfig,
    )) {
      yield TextCompletionChunk(
        text: chunk.text,
        finishReason: chunk.finishReason,
      );
    }
  }

  /// Generates an embedding vector for the given text.
  ///
  /// [text] is the input to embed.
  /// [normalize] whether to L2-normalize the output (default: true).
  ///
  /// Returns the embedding as a list of doubles.
  ///
  /// Throws [StateError] if the model has been disposed.
  Future<List<double>> embed(String text, {bool normalize = true}) async {
    _checkDisposed();
    return _engine.embed(text, normalize: normalize);
  }

  /// Generates embeddings for multiple texts in batch.
  ///
  /// [texts] is the list of inputs to embed.
  /// [normalize] whether to L2-normalize the outputs (default: true).
  ///
  /// Returns a list of embedding vectors.
  ///
  /// Throws [StateError] if the model has been disposed.
  Future<List<List<double>>> embedBatch(
    List<String> texts, {
    bool normalize = true,
  }) async {
    _checkDisposed();

    final embeddings = <List<double>>[];
    for (final text in texts) {
      embeddings.add(await _engine.embed(text, normalize: normalize));
    }
    return embeddings;
  }

  /// Counts the number of tokens in the given text.
  ///
  /// [text] is the input to tokenize and count.
  ///
  /// Returns the token count.
  ///
  /// Throws [StateError] if the model has been disposed.
  Future<int> countTokens(String text) async {
    _checkDisposed();
    final tokens = await _engine.tokenizer.encode(text);
    return tokens.length;
  }

  /// Tokenizes the given text into token IDs.
  ///
  /// [text] is the input to tokenize.
  /// [addSpecialTokens] whether to add BOS/EOS tokens (default: true).
  ///
  /// Returns the list of token IDs.
  ///
  /// Throws [StateError] if the model has been disposed.
  Future<List<int>> tokenize(
    String text, {
    bool addSpecialTokens = true,
  }) async {
    _checkDisposed();
    return _engine.tokenizer.encode(text, addSpecialTokens: addSpecialTokens);
  }

  /// Converts token IDs back to text.
  ///
  /// [tokens] is the list of token IDs to decode.
  ///
  /// Returns the decoded text.
  ///
  /// Throws [StateError] if the model has been disposed.
  Future<String> detokenize(List<int> tokens) async {
    _checkDisposed();
    return _engine.tokenizer.decode(tokens);
  }

  /// Sets a custom chat template for this model.
  ///
  /// [template] is the template to use for chat formatting.
  ///
  /// Throws [StateError] if the model has been disposed.
  void setChatTemplate(ChatTemplate template) {
    _checkDisposed();
    _engine.setChatTemplate(template);
  }

  /// Resets the context, clearing all token history.
  ///
  /// This is useful for starting a fresh conversation.
  ///
  /// Throws [StateError] if the model has been disposed.
  void resetContext() {
    _checkDisposed();
    _engine.resetContext();
  }

  /// Disposes of this model and releases all resources.
  ///
  /// The model cannot be used after disposing. Calling dispose multiple
  /// times is safe and has no effect after the first call.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _engine.dispose();
  }

  /// Checks that the model has not been disposed.
  void _checkDisposed() {
    if (_isDisposed) {
      throw StateError('Cannot use disposed LLMModel');
    }
  }
}
