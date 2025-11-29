import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:dartllm/src/core/exceptions/exceptions.dart';
import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/model_info.dart';
import 'package:dartllm/src/platform/generated_bindings.dart';
import 'package:dartllm/src/platform/library_loader.dart';
import 'package:dartllm/src/platform/platform_binding.dart';
import 'package:dartllm/src/utils/logger.dart';
import 'package:ffi/ffi.dart';

/// Native callback type for streaming token generation.
typedef StreamCallbackNative =
    Int32 Function(
      Int32 token,
      Pointer<Utf8> text,
      Int8 isFinal,
      Int32 finishReason,
      Pointer<Void> userData,
    );

/// Platform binding implementation using Dart FFI.
///
/// This binding communicates with the native llama.cpp library
/// through the C ABI. It uses auto-generated bindings from ffigen
/// and provides a high-level interface implementing [PlatformBinding].
///
/// The native library must be bundled with the application:
/// - Android: `libllamacpp.so` in jniLibs
/// - iOS/macOS: `llamacpp.framework`
/// - Windows: `llamacpp.dll`
/// - Linux: `libllamacpp.so`
class NativeBinding implements PlatformBinding {
  static const String _loggerName = 'dartllm.platform.native';

  final DartLLMLogger _logger = DartLLMLogger(_loggerName);

  /// The loaded dynamic library.
  DynamicLibrary? _library;

  /// The auto-generated bindings wrapper.
  DartLLMBindings? _bindings;

  /// Whether the native library was successfully loaded.
  bool _isInitialized = false;

  /// Whether this binding has been disposed.
  bool _isDisposed = false;

  /// Map of active model handles to their native pointers.
  final Map<ModelHandle, Pointer<Void>> _modelPointers = {};

  /// Counter for generating unique model handles.
  int _nextHandle = 1;

  /// Creates a new native binding.
  ///
  /// Call [initialize] to load the native library before using
  /// other methods.
  NativeBinding();

  /// Initializes the native binding by loading the dynamic library.
  ///
  /// Returns true if the library was loaded successfully.
  /// Returns false if the library is not available on this platform.
  Future<bool> initialize() async {
    if (_isDisposed) {
      throw StateError('NativeBinding has been disposed');
    }

    if (_isInitialized) {
      return true;
    }

    try {
      _library = _loadLibrary();
      _bindings = DartLLMBindings(_library!);

      final initResult = _bindings!.dartllm_init();
      if (initResult != 0) {
        _logger.error('Failed to initialize llama.cpp: error code $initResult');
        return false;
      }

      _isInitialized = true;
      _logger.info('Native binding initialized successfully');
      return true;
    } on ArgumentError catch (error) {
      _logger.warning('Native library not available: $error');
      return false;
    } on Exception catch (error) {
      _logger.error('Failed to initialize native binding', error);
      return false;
    }
  }

  /// Loads the native library using the smart library loader.
  DynamicLibrary _loadLibrary() {
    _logger.debug('Loading native library...');
    try {
      final library = LibraryLoader.load();
      _logger.debug('Native library loaded successfully');
      return library;
    } on LibraryLoadException catch (e) {
      _logger.error('Failed to load native library: ${e.message}');
      _logger.debug('Searched paths: ${LibraryLoader.getSearchedPaths()}');
      rethrow;
    }
  }

  /// Checks that the binding is initialized and not disposed.
  void _checkReady() {
    if (_isDisposed) {
      throw StateError('NativeBinding has been disposed');
    }
    if (!_isInitialized) {
      throw LLMPlatformException(
        'Native binding not initialized. '
        'The native library may not be bundled with the application.',
      );
    }
  }

  /// Whether the native library is available and initialized.
  bool get isAvailable => _isInitialized && !_isDisposed;

  @override
  bool get supportsGpu {
    if (!isAvailable) return false;
    return _bindings!.dartllm_has_gpu_support() != 0;
  }

  @override
  bool get supportsMultiThreading => isAvailable;

  /// Gets the DartLLM library version.
  String get version {
    if (!isAvailable) return 'unknown';
    final ptr = _bindings!.dartllm_version();
    if (ptr == nullptr) return 'unknown';
    return ptr.cast<Utf8>().toDartString();
  }

  /// Gets the llama.cpp backend version.
  String get llamaVersion {
    if (!isAvailable) return 'unknown';
    final ptr = _bindings!.dartllm_llama_version();
    if (ptr == nullptr) return 'unknown';
    return ptr.cast<Utf8>().toDartString();
  }

  /// Gets the active GPU backend name.
  String get gpuBackendName {
    if (!isAvailable) return 'cpu';
    final ptr = _bindings!.dartllm_gpu_backend_name();
    if (ptr == nullptr) return 'cpu';
    return ptr.cast<Utf8>().toDartString();
  }

  /// Gets the available VRAM in bytes.
  int get vramSize {
    if (!isAvailable) return 0;
    return _bindings!.dartllm_get_vram_size();
  }

  /// Gets the last error message from native code, or null if no error.
  String? get lastError {
    if (!isAvailable) return null;
    final ptr = _bindings!.dartllm_get_last_error();
    if (ptr == nullptr) return null;
    return ptr.cast<Utf8>().toDartString();
  }

  /// Clears the last error in native code.
  void clearError() {
    if (isAvailable) {
      _bindings!.dartllm_clear_error();
    }
  }

  @override
  Future<LoadModelResult> loadModel(LoadModelRequest request) async {
    _checkReady();

    final pathPointer = request.modelPath.toNativeUtf8();

    try {
      final modelPointer = _bindings!.dartllm_load_model(
        pathPointer.cast(),
        request.config.contextSize ?? 0,
        request.config.gpuLayers,
        request.config.threads,
        request.config.batchSize,
        request.config.useMemoryMap ? 1 : 0,
      );

      if (modelPointer == nullptr) {
        throw ModelNotFoundException(request.modelPath);
      }

      final handle = _nextHandle++;
      _modelPointers[handle] = modelPointer;

      final modelInfo = await getModelInfo(handle);

      _logger.info('Model loaded: ${modelInfo.name} (handle: $handle)');

      return LoadModelResult(handle: handle, modelInfo: modelInfo);
    } finally {
      calloc.free(pathPointer);
    }
  }

  @override
  Future<void> unloadModel(ModelHandle handle) async {
    _checkReady();

    final pointer = _modelPointers.remove(handle);
    if (pointer == null) {
      _logger.warning('Attempted to unload unknown model handle: $handle');
      return;
    }

    _bindings!.dartllm_free_model(pointer);
    _logger.info('Model unloaded: handle $handle');
  }

  @override
  Future<GenerateResult> generate(GenerateRequest request) async {
    _checkReady();

    final pointer = _modelPointers[request.modelHandle];
    if (pointer == null) {
      throw StateError('Invalid model handle: ${request.modelHandle}');
    }

    final startTime = DateTime.now();

    final promptPointer = calloc<Int32>(request.promptTokens.length);
    try {
      for (var i = 0; i < request.promptTokens.length; i++) {
        promptPointer[i] = request.promptTokens[i];
      }

      final resultPointer = _bindings!.dartllm_generate(
        pointer,
        promptPointer,
        request.promptTokens.length,
        request.maxTokens,
        request.temperature,
        request.topP,
        request.topK,
        request.minP,
        request.repetitionPenalty,
        request.seed ?? -1,
      );

      if (resultPointer == nullptr) {
        throw GenerationException('Generation failed in native code');
      }

      try {
        final result = _parseGenerateResult(resultPointer.cast());
        final endTime = DateTime.now();
        final generationTimeMs = endTime.difference(startTime).inMilliseconds;

        return GenerateResult(
          tokens: result.tokens,
          promptTokenCount: request.promptTokens.length,
          completionTokenCount: result.tokens.length,
          finishReason: result.finishReason,
          generationTimeMs: generationTimeMs,
        );
      } finally {
        _bindings!.dartllm_free(resultPointer.cast());
      }
    } finally {
      calloc.free(promptPointer);
    }
  }

  /// Parses the native generation result structure.
  ({List<int> tokens, FinishReason finishReason}) _parseGenerateResult(
    Pointer<Void> resultPointer,
  ) {
    // The native result structure layout:
    // - int32_t token_count
    // - int32_t finish_reason (0=stop, 1=length, 2=error)
    // - int32_t tokens[token_count]
    final intPtr = resultPointer.cast<Int32>();
    final tokenCount = intPtr[0];
    final finishReasonCode = intPtr[1];

    final tokens = <int>[];
    for (var i = 0; i < tokenCount; i++) {
      tokens.add(intPtr[2 + i]);
    }

    final finishReason = switch (finishReasonCode) {
      0 => FinishReason.stop,
      1 => FinishReason.length,
      _ => FinishReason.error,
    };

    return (tokens: tokens, finishReason: finishReason);
  }

  @override
  Stream<GenerateStreamChunk> generateStream(GenerateRequest request) {
    _checkReady();

    final pointer = _modelPointers[request.modelHandle];
    if (pointer == null) {
      throw StateError('Invalid model handle: ${request.modelHandle}');
    }

    final controller = StreamController<GenerateStreamChunk>();
    final tokensPointer = calloc<Int32>(request.promptTokens.length);

    for (var i = 0; i < request.promptTokens.length; i++) {
      tokensPointer[i] = request.promptTokens[i];
    }

    var shouldContinue = true;

    int streamCallback(
      int token,
      Pointer<Utf8> textPtr,
      int isFinal,
      int finishReason,
      Pointer<Void> userData,
    ) {
      if (!shouldContinue) {
        return 0;
      }

      final chunk = GenerateStreamChunk(
        token: token,
        text: textPtr != nullptr ? textPtr.toDartString() : null,
        finishReason: isFinal != 0 ? FinishReason.values[finishReason] : null,
      );
      controller.add(chunk);

      if (isFinal != 0) {
        controller.close();
        shouldContinue = false;
      }
      return shouldContinue ? 1 : 0;
    }

    final nativeCallback = NativeCallable<StreamCallbackNative>.isolateLocal(
      streamCallback,
      exceptionalReturn: 0,
    );

    Future<void>.microtask(() async {
      try {
        final result = _bindings!.dartllm_generate_stream(
          pointer,
          tokensPointer,
          request.promptTokens.length,
          request.maxTokens,
          request.temperature,
          request.topP,
          request.topK,
          request.minP,
          request.repetitionPenalty,
          request.seed ?? -1,
          nativeCallback.nativeFunction.cast(),
          nullptr,
        );

        if (result < 0 && !controller.isClosed) {
          controller.addError(
            GenerationException('Streaming generation failed: code $result'),
          );
          controller.close();
        }
      } finally {
        calloc.free(tokensPointer);
        nativeCallback.close();
      }
    });

    return controller.stream;
  }

  @override
  Future<EmbedResult> embed(EmbedRequest request) async {
    _checkReady();

    final pointer = _modelPointers[request.modelHandle];
    if (pointer == null) {
      throw StateError('Invalid model handle: ${request.modelHandle}');
    }

    final tokensPointer = calloc<Int32>(request.tokens.length);
    final dimensionPointer = calloc<Int32>(1);

    try {
      for (var i = 0; i < request.tokens.length; i++) {
        tokensPointer[i] = request.tokens[i];
      }

      final embeddingPointer = _bindings!.dartllm_embed(
        pointer,
        tokensPointer,
        request.tokens.length,
        request.normalize ? 1 : 0,
        dimensionPointer,
      );

      if (embeddingPointer == nullptr) {
        throw GenerationException('Embedding generation failed in native code');
      }

      try {
        final dimension = dimensionPointer[0];
        final embedding = Float32List(dimension);

        for (var i = 0; i < dimension; i++) {
          embedding[i] = embeddingPointer[i];
        }

        return EmbedResult(embedding: embedding);
      } finally {
        _bindings!.dartllm_free(embeddingPointer.cast());
      }
    } finally {
      calloc.free(tokensPointer);
      calloc.free(dimensionPointer);
    }
  }

  @override
  Future<List<int>> tokenize(TokenizeRequest request) async {
    _checkReady();

    final pointer = _modelPointers[request.modelHandle];
    if (pointer == null) {
      throw StateError('Invalid model handle: ${request.modelHandle}');
    }

    final textPointer = request.text.toNativeUtf8();
    final lengthPointer = calloc<Int32>(1);

    try {
      final tokensPointer = _bindings!.dartllm_tokenize(
        pointer,
        textPointer.cast(),
        request.addSpecialTokens ? 1 : 0,
        lengthPointer,
      );

      if (tokensPointer == nullptr) {
        throw TokenizationException(
          'Tokenization failed',
          inputText: request.text,
        );
      }

      try {
        final length = lengthPointer[0];
        final tokens = <int>[];

        for (var i = 0; i < length; i++) {
          tokens.add(tokensPointer[i]);
        }

        return tokens;
      } finally {
        _bindings!.dartllm_free(tokensPointer.cast());
      }
    } finally {
      calloc.free(textPointer);
      calloc.free(lengthPointer);
    }
  }

  @override
  Future<String> detokenize(DetokenizeRequest request) async {
    _checkReady();

    final pointer = _modelPointers[request.modelHandle];
    if (pointer == null) {
      throw StateError('Invalid model handle: ${request.modelHandle}');
    }

    final tokensPointer = calloc<Int32>(request.tokens.length);

    try {
      for (var i = 0; i < request.tokens.length; i++) {
        tokensPointer[i] = request.tokens[i];
      }

      final textPointer = _bindings!.dartllm_detokenize(
        pointer,
        tokensPointer,
        request.tokens.length,
      );

      if (textPointer == nullptr) {
        throw TokenizationException(
          'Detokenization failed',
          inputText: request.tokens.toString(),
        );
      }

      try {
        return textPointer.cast<Utf8>().toDartString();
      } finally {
        _bindings!.dartllm_free(textPointer.cast());
      }
    } finally {
      calloc.free(tokensPointer);
    }
  }

  @override
  Future<ModelInfo> getModelInfo(ModelHandle handle) async {
    _checkReady();

    final pointer = _modelPointers[handle];
    if (pointer == null) {
      throw StateError('Invalid model handle: $handle');
    }

    final infoPointer = _bindings!.dartllm_get_model_info(pointer);
    if (infoPointer == nullptr) {
      throw InvalidModelException(
        'handle:$handle',
        details: 'Failed to retrieve model information',
      );
    }

    try {
      return _parseModelInfo(infoPointer);
    } finally {
      _bindings!.dartllm_free(infoPointer.cast());
    }
  }

  /// Parses the native model info structure using generated bindings.
  ModelInfo _parseModelInfo(Pointer<DartLLMModelInfo> infoPointer) {
    final info = infoPointer.ref;

    return ModelInfo(
      name: _charArrayToString(info.name, 256),
      parameterCount: info.parameter_count,
      architecture: _charArrayToString(info.architecture, 64),
      quantization: _charArrayToString(info.quantization, 32),
      contextSize: info.context_size,
      vocabularySize: info.vocabulary_size,
      embeddingSize: info.embedding_size,
      layerCount: info.layer_count,
      headCount: info.head_count,
      fileSizeBytes: info.file_size_bytes,
      supportsEmbedding: info.supports_embedding != 0,
      supportsVision: info.supports_vision != 0,
      chatTemplate: _charArrayToString(info.chat_template, 4096),
    );
  }

  /// Converts a fixed-size char array to a Dart string.
  String _charArrayToString(Array<Char> array, int maxLength) {
    final bytes = <int>[];
    for (var i = 0; i < maxLength; i++) {
      final byte = array[i];
      if (byte == 0) break;
      bytes.add(byte);
    }
    return String.fromCharCodes(bytes);
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    // Unload all models
    for (final pointer in _modelPointers.values) {
      _bindings?.dartllm_free_model(pointer);
    }
    _modelPointers.clear();

    _bindings = null;
    _library = null;
    _isInitialized = false;

    _logger.info('Native binding disposed');
  }
}
