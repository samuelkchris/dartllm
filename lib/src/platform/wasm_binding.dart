import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:dartllm/src/core/exceptions/exceptions.dart';
import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/model_info.dart';
import 'package:dartllm/src/platform/platform_binding.dart';
import 'package:dartllm/src/utils/logger.dart';

/// JavaScript interop bindings for the llama.cpp WASM module.
///
/// These extension types define the interface to the WASM module
/// loaded in the browser.

/// The main DartLLM WASM module interface.
@JS('DartLLMWasm')
extension type DartLLMWasmModule._(JSObject _) implements JSObject {
  /// Initializes the WASM module.
  external JSPromise<JSBoolean> init();

  /// Loads a model from a URL or ArrayBuffer.
  external JSPromise<JSNumber> loadModel(
    JSAny modelData,
    JSNumber contextSize,
    JSNumber gpuLayers,
    JSNumber batchSize,
  );

  /// Unloads a model and frees its resources.
  external JSPromise<JSAny?> unloadModel(JSNumber handle);

  /// Gets model information.
  external JSPromise<ModelInfoJS> getModelInfo(JSNumber handle);

  /// Tokenizes text to token IDs.
  external JSPromise<JSInt32Array> tokenize(
    JSNumber handle,
    JSString text,
    JSBoolean addSpecialTokens,
  );

  /// Detokenizes token IDs to text.
  external JSPromise<JSString> detokenize(JSNumber handle, JSInt32Array tokens);

  /// Generates text from a prompt.
  external JSPromise<GenerateResultJS> generate(
    JSNumber handle,
    JSInt32Array promptTokens,
    GenerateConfigJS config,
  );

  /// Generates embeddings from tokens.
  external JSPromise<JSFloat32Array> embed(
    JSNumber handle,
    JSInt32Array tokens,
    JSBoolean normalize,
  );

  /// Checks if WebGPU is available.
  external JSBoolean hasWebGPU();
}

/// JavaScript representation of model info.
@JS()
@anonymous
extension type ModelInfoJS._(JSObject _) implements JSObject {
  external String get name;

  external int get parameterCount;

  external String get architecture;

  external String get quantization;

  external int get contextSize;

  external int get vocabularySize;

  external int get embeddingSize;

  external int get layerCount;

  external int get headCount;

  external int get fileSizeBytes;

  external bool get supportsEmbedding;

  external bool get supportsVision;

  external String? get chatTemplate;
}

/// JavaScript representation of generation config.
@JS()
@anonymous
extension type GenerateConfigJS._(JSObject _) implements JSObject {
  external factory GenerateConfigJS({
    int maxTokens,
    double temperature,
    double topP,
    int topK,
    double minP,
    double repetitionPenalty,
    double frequencyPenalty,
    double presencePenalty,
    int repeatLastN,
    JSArray<JSNumber>? stopTokens,
    int? seed,
  });
}

/// JavaScript representation of generation result.
@JS()
@anonymous
extension type GenerateResultJS._(JSObject _) implements JSObject {
  external JSInt32Array get tokens;

  external int get finishReason;

  external int get generationTimeMs;
}

/// Accesses the global DartLLMWasm module.
@JS('window.DartLLMWasm')
external DartLLMWasmModule? get _dartLLMWasm;

/// Platform binding implementation using WASM and JavaScript interop.
///
/// This binding communicates with the llama.cpp WASM module running
/// in the browser. It handles type conversion between Dart and JavaScript.
///
/// The WASM module must be loaded before creating this binding:
/// ```html
/// <script src="dartllm_wasm.js"></script>
/// ```
///
/// Performance expectations for web:
/// - Significantly slower than native platforms (2-10 tokens/second)
/// - WebGPU can improve performance when available
/// - Intended for demos and development, not production workloads
class WasmBinding implements PlatformBinding {
  static const String _loggerName = 'dartllm.platform.wasm';

  final DartLLMLogger _logger = DartLLMLogger(_loggerName);

  /// The WASM module instance.
  DartLLMWasmModule? _module;

  /// Whether the binding has been initialized.
  bool _isInitialized = false;

  /// Whether this binding has been disposed.
  bool _isDisposed = false;

  /// Set of active model handles.
  final Set<ModelHandle> _activeHandles = {};

  /// Creates a new WASM binding.
  ///
  /// Call [initialize] to load the WASM module before using
  /// other methods.
  WasmBinding();

  /// Initializes the WASM binding by connecting to the WASM module.
  ///
  /// Returns true if the module was initialized successfully.
  /// Returns false if the module is not available.
  Future<bool> initialize() async {
    if (_isDisposed) {
      throw StateError('WasmBinding has been disposed');
    }

    if (_isInitialized) {
      return true;
    }

    try {
      _module = _dartLLMWasm;

      if (_module == null) {
        _logger.warning(
          'WASM module not found. '
          'Ensure dartllm_wasm.js is loaded before initializing.',
        );
        return false;
      }

      final initResult = await _module!.init().toDart;
      if (!initResult.toDart) {
        _logger.error('WASM module initialization failed');
        return false;
      }

      _isInitialized = true;
      _logger.info('WASM binding initialized successfully');
      return true;
    } on Exception catch (error) {
      _logger.error('Failed to initialize WASM binding', error);
      return false;
    }
  }

  /// Checks that the binding is initialized and not disposed.
  void _checkReady() {
    if (_isDisposed) {
      throw StateError('WasmBinding has been disposed');
    }
    if (!_isInitialized || _module == null) {
      throw LLMPlatformException(
        'WASM binding not initialized. '
        'Ensure the WASM module is loaded and initialize() is called.',
      );
    }
  }

  /// Whether the WASM module is available and initialized.
  bool get isAvailable => _isInitialized && !_isDisposed && _module != null;

  @override
  bool get supportsGpu {
    if (!isAvailable) return false;
    return _module!.hasWebGPU().toDart;
  }

  @override
  bool get supportsMultiThreading => false; // WASM is single-threaded

  @override
  Future<LoadModelResult> loadModel(LoadModelRequest request) async {
    _checkReady();

    _logger.info('Loading model from: ${request.modelPath}');

    try {
      // For web, modelPath is typically a URL to fetch
      final handleJs = await _module!
          .loadModel(
            request.modelPath.toJS,
            (request.config.contextSize ?? 0).toJS,
            request.config.gpuLayers.toJS,
            request.config.batchSize.toJS,
          )
          .toDart;

      final handle = handleJs.toDartInt;

      if (handle <= 0) {
        throw ModelNotFoundException(request.modelPath);
      }

      _activeHandles.add(handle);

      final modelInfo = await getModelInfo(handle);

      _logger.info('Model loaded: ${modelInfo.name} (handle: $handle)');

      return LoadModelResult(handle: handle, modelInfo: modelInfo);
    } on Exception catch (error) {
      _logger.error('Failed to load model', error);
      rethrow;
    }
  }

  @override
  Future<void> unloadModel(ModelHandle handle) async {
    _checkReady();

    if (!_activeHandles.contains(handle)) {
      _logger.warning('Attempted to unload unknown model handle: $handle');
      return;
    }

    await _module!.unloadModel(handle.toJS).toDart;
    _activeHandles.remove(handle);

    _logger.info('Model unloaded: handle $handle');
  }

  @override
  Future<GenerateResult> generate(GenerateRequest request) async {
    _checkReady();

    if (!_activeHandles.contains(request.modelHandle)) {
      throw StateError('Invalid model handle: ${request.modelHandle}');
    }

    final startTime = DateTime.now();

    final promptTokensJs = Int32List.fromList(request.promptTokens).toJS;

    final configJs = GenerateConfigJS(
      maxTokens: request.maxTokens,
      temperature: request.temperature,
      topP: request.topP,
      topK: request.topK,
      minP: request.minP,
      repetitionPenalty: request.repetitionPenalty,
      frequencyPenalty: request.frequencyPenalty,
      presencePenalty: request.presencePenalty,
      repeatLastN: request.repeatLastN,
      stopTokens: request.stopTokens.map((t) => t.toJS).toList().toJS,
      seed: request.seed,
    );

    final resultJs = await _module!
        .generate(request.modelHandle.toJS, promptTokensJs, configJs)
        .toDart;

    final endTime = DateTime.now();
    final generationTimeMs = endTime.difference(startTime).inMilliseconds;

    final tokens = resultJs.tokens.toDart.toList();
    final finishReason = _parseFinishReason(resultJs.finishReason);

    return GenerateResult(
      tokens: tokens,
      promptTokenCount: request.promptTokens.length,
      completionTokenCount: tokens.length,
      finishReason: finishReason,
      generationTimeMs: generationTimeMs,
    );
  }

  /// Converts a JavaScript finish reason code to a Dart enum.
  FinishReason _parseFinishReason(int code) {
    return switch (code) {
      0 => FinishReason.stop,
      1 => FinishReason.length,
      _ => FinishReason.error,
    };
  }

  @override
  Stream<GenerateStreamChunk> generateStream(GenerateRequest request) async* {
    _checkReady();

    final result = await generate(request);

    for (var i = 0; i < result.tokens.length; i++) {
      final isLast = i == result.tokens.length - 1;
      final tokenText = await detokenize(
        DetokenizeRequest(
          modelHandle: request.modelHandle,
          tokens: [result.tokens[i]],
        ),
      );
      yield GenerateStreamChunk(
        token: result.tokens[i],
        text: tokenText,
        finishReason: isLast ? result.finishReason : null,
      );
    }
  }

  @override
  Future<EmbedResult> embed(EmbedRequest request) async {
    _checkReady();

    if (!_activeHandles.contains(request.modelHandle)) {
      throw StateError('Invalid model handle: ${request.modelHandle}');
    }

    final tokensJs = Int32List.fromList(request.tokens).toJS;

    final embeddingJs = await _module!
        .embed(request.modelHandle.toJS, tokensJs, request.normalize.toJS)
        .toDart;

    return EmbedResult(embedding: embeddingJs.toDart);
  }

  @override
  Future<List<int>> tokenize(TokenizeRequest request) async {
    _checkReady();

    if (!_activeHandles.contains(request.modelHandle)) {
      throw StateError('Invalid model handle: ${request.modelHandle}');
    }

    final tokensJs = await _module!
        .tokenize(
          request.modelHandle.toJS,
          request.text.toJS,
          request.addSpecialTokens.toJS,
        )
        .toDart;

    return tokensJs.toDart.toList();
  }

  @override
  Future<String> detokenize(DetokenizeRequest request) async {
    _checkReady();

    if (!_activeHandles.contains(request.modelHandle)) {
      throw StateError('Invalid model handle: ${request.modelHandle}');
    }

    final tokensJs = Int32List.fromList(request.tokens).toJS;

    final textJs =
        await _module!.detokenize(request.modelHandle.toJS, tokensJs).toDart;

    return textJs.toDart;
  }

  @override
  Future<ModelInfo> getModelInfo(ModelHandle handle) async {
    _checkReady();

    if (!_activeHandles.contains(handle)) {
      throw StateError('Invalid model handle: $handle');
    }

    final infoJs = await _module!.getModelInfo(handle.toJS).toDart;

    return ModelInfo(
      name: infoJs.name,
      parameterCount: infoJs.parameterCount,
      architecture: infoJs.architecture,
      quantization: infoJs.quantization,
      contextSize: infoJs.contextSize,
      vocabularySize: infoJs.vocabularySize,
      embeddingSize: infoJs.embeddingSize,
      layerCount: infoJs.layerCount,
      headCount: infoJs.headCount,
      fileSizeBytes: infoJs.fileSizeBytes,
      supportsEmbedding: infoJs.supportsEmbedding,
      supportsVision: infoJs.supportsVision,
      chatTemplate: infoJs.chatTemplate,
    );
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    // Unload all models
    for (final handle in _activeHandles.toList()) {
      _module?.unloadModel(handle.toJS);
    }
    _activeHandles.clear();

    _module = null;
    _isInitialized = false;

    _logger.info('WASM binding disposed');
  }
}

/// Extension to convert `JSInt32Array` to Dart `List<int>`.
extension JSInt32ArrayToList on JSInt32Array {
  /// Converts to Dart list.
  List<int> asList() {
    return toDart.toList();
  }
}
