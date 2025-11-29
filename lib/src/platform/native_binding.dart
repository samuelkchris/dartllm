import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartllm/src/core/exceptions/exceptions.dart';
import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/model_info.dart';
import 'package:dartllm/src/platform/platform_binding.dart';
import 'package:dartllm/src/utils/logger.dart';
import 'package:dartllm/src/utils/platform_utils.dart';
import 'package:ffi/ffi.dart';

/// FFI function signatures for llama.cpp bindings.
///
/// These typedefs define the C function signatures that will be
/// loaded from the native library.

/// Native function: Initialize the llama.cpp library.
typedef LlamaInitNative = Int32 Function();
typedef LlamaInitDart = int Function();

/// Native function: Load a model from file path.
typedef LlamaLoadModelNative =
    Pointer<Void> Function(
      Pointer<Utf8> path,
      Int32 contextSize,
      Int32 gpuLayers,
      Int32 threads,
      Int32 batchSize,
      Int8 useMemoryMap,
    );
typedef LlamaLoadModelDart =
    Pointer<Void> Function(
      Pointer<Utf8> path,
      int contextSize,
      int gpuLayers,
      int threads,
      int batchSize,
      int useMemoryMap,
    );

/// Native function: Free a loaded model.
typedef LlamaFreeModelNative = Void Function(Pointer<Void> model);
typedef LlamaFreeModelDart = void Function(Pointer<Void> model);

/// Native function: Get model metadata.
typedef LlamaGetModelInfoNative = Pointer<Void> Function(Pointer<Void> model);
typedef LlamaGetModelInfoDart = Pointer<Void> Function(Pointer<Void> model);

/// Native function: Tokenize text.
typedef LlamaTokenizeNative =
    Pointer<Int32> Function(
      Pointer<Void> model,
      Pointer<Utf8> text,
      Int8 addSpecial,
      Pointer<Int32> outLength,
    );
typedef LlamaTokenizeDart =
    Pointer<Int32> Function(
      Pointer<Void> model,
      Pointer<Utf8> text,
      int addSpecial,
      Pointer<Int32> outLength,
    );

/// Native function: Detokenize tokens to text.
typedef LlamaDetokenizeNative =
    Pointer<Utf8> Function(
      Pointer<Void> model,
      Pointer<Int32> tokens,
      Int32 tokenCount,
    );
typedef LlamaDetokenizeDart =
    Pointer<Utf8> Function(
      Pointer<Void> model,
      Pointer<Int32> tokens,
      int tokenCount,
    );

/// Native function: Generate tokens.
typedef LlamaGenerateNative =
    Pointer<Void> Function(
      Pointer<Void> model,
      Pointer<Int32> promptTokens,
      Int32 promptLength,
      Int32 maxTokens,
      Float temperature,
      Float topP,
      Int32 topK,
      Float minP,
      Float repetitionPenalty,
      Int32 seed,
    );
typedef LlamaGenerateDart =
    Pointer<Void> Function(
      Pointer<Void> model,
      Pointer<Int32> promptTokens,
      int promptLength,
      int maxTokens,
      double temperature,
      double topP,
      int topK,
      double minP,
      double repetitionPenalty,
      int seed,
    );

/// Native function: Generate embeddings.
typedef LlamaEmbedNative =
    Pointer<Float> Function(
      Pointer<Void> model,
      Pointer<Int32> tokens,
      Int32 tokenCount,
      Int8 normalize,
      Pointer<Int32> outDimension,
    );
typedef LlamaEmbedDart =
    Pointer<Float> Function(
      Pointer<Void> model,
      Pointer<Int32> tokens,
      int tokenCount,
      int normalize,
      Pointer<Int32> outDimension,
    );

/// Native function: Free allocated memory.
typedef LlamaFreeNative = Void Function(Pointer<Void> ptr);
typedef LlamaFreeDart = void Function(Pointer<Void> ptr);

/// Native function: Check GPU support.
typedef LlamaHasGpuSupportNative = Int8 Function();
typedef LlamaHasGpuSupportDart = int Function();

/// Native struct for model information.
///
/// This struct matches the layout of DartLLMModelInfo in dartllm.h.
/// Fixed-size char arrays are used for strings to ensure ABI compatibility.
final class DartLLMModelInfoStruct extends Struct {
  /// Model name (null-terminated, max 256 chars).
  @Array(256)
  external Array<Uint8> name;

  /// Number of parameters in the model.
  @Int64()
  external int parameterCount;

  /// Model architecture name (null-terminated, max 64 chars).
  @Array(64)
  external Array<Uint8> architecture;

  /// Quantization format (null-terminated, max 32 chars).
  @Array(32)
  external Array<Uint8> quantization;

  /// Maximum context size in tokens.
  @Int32()
  external int contextSize;

  /// Vocabulary size.
  @Int32()
  external int vocabularySize;

  /// Embedding dimension.
  @Int32()
  external int embeddingSize;

  /// Number of transformer layers.
  @Int32()
  external int layerCount;

  /// Number of attention heads.
  @Int32()
  external int headCount;

  /// File size in bytes.
  @Int64()
  external int fileSizeBytes;

  /// Whether model supports embeddings (0 or 1).
  @Int8()
  external int supportsEmbedding;

  /// Whether model supports vision (0 or 1).
  @Int8()
  external int supportsVision;

  /// Chat template string (null-terminated, max 4096 chars).
  @Array(4096)
  external Array<Uint8> chatTemplate;
}

/// Platform binding implementation using Dart FFI.
///
/// This binding communicates with the native llama.cpp library
/// through the C ABI. It handles memory management, type conversion,
/// and error propagation across the FFI boundary.
///
/// The native library must be bundled with the application:
/// - Android: `libllamacpp.so` in jniLibs
/// - iOS/macOS: `llamacpp.framework`
/// - Windows: `llamacpp.dll`
/// - Linux: `libllamacpp.so`
class NativeBinding implements PlatformBinding {
  static const String _loggerName = 'dartllm.platform.native';

  final DartLLMLogger _logger = DartLLMLogger(_loggerName);

  /// The loaded dynamic library, or null if not available.
  DynamicLibrary? _library;

  /// Whether the native library was successfully loaded.
  bool _isInitialized = false;

  /// Whether this binding has been disposed.
  bool _isDisposed = false;

  /// Cached FFI function pointers.
  LlamaInitDart? _llamaInit;
  LlamaLoadModelDart? _llamaLoadModel;
  LlamaFreeModelDart? _llamaFreeModel;
  LlamaGetModelInfoDart? _llamaGetModelInfo;
  LlamaTokenizeDart? _llamaTokenize;
  LlamaDetokenizeDart? _llamaDetokenize;
  LlamaGenerateDart? _llamaGenerate;
  LlamaEmbedDart? _llamaEmbed;
  LlamaFreeDart? _llamaFree;
  LlamaHasGpuSupportDart? _llamaHasGpuSupport;

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
      _bindFunctions();

      final initResult = _llamaInit!();
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

  /// Loads the platform-appropriate dynamic library.
  DynamicLibrary _loadLibrary() {
    final libraryName = _getLibraryName();
    _logger.debug('Loading native library: $libraryName');
    return DynamicLibrary.open(libraryName);
  }

  /// Gets the library filename for the current platform.
  String _getLibraryName() {
    switch (PlatformUtils.current) {
      case DartLLMPlatform.android:
        return 'libllamacpp.so';
      case DartLLMPlatform.ios:
      case DartLLMPlatform.macos:
        return 'llamacpp.framework/llamacpp';
      case DartLLMPlatform.windows:
        return 'llamacpp.dll';
      case DartLLMPlatform.linux:
        return 'libllamacpp.so';
      case DartLLMPlatform.web:
        throw UnsupportedPlatformException('Web');
      case DartLLMPlatform.unknown:
        throw UnsupportedPlatformException(Platform.operatingSystem);
    }
  }

  /// Binds all FFI function pointers from the loaded library.
  void _bindFunctions() {
    final library = _library!;

    _llamaInit = library
        .lookup<NativeFunction<LlamaInitNative>>('dartllm_init')
        .asFunction<LlamaInitDart>();

    _llamaLoadModel = library
        .lookup<NativeFunction<LlamaLoadModelNative>>('dartllm_load_model')
        .asFunction<LlamaLoadModelDart>();

    _llamaFreeModel = library
        .lookup<NativeFunction<LlamaFreeModelNative>>('dartllm_free_model')
        .asFunction<LlamaFreeModelDart>();

    _llamaGetModelInfo = library
        .lookup<NativeFunction<LlamaGetModelInfoNative>>(
          'dartllm_get_model_info',
        )
        .asFunction<LlamaGetModelInfoDart>();

    _llamaTokenize = library
        .lookup<NativeFunction<LlamaTokenizeNative>>('dartllm_tokenize')
        .asFunction<LlamaTokenizeDart>();

    _llamaDetokenize = library
        .lookup<NativeFunction<LlamaDetokenizeNative>>('dartllm_detokenize')
        .asFunction<LlamaDetokenizeDart>();

    _llamaGenerate = library
        .lookup<NativeFunction<LlamaGenerateNative>>('dartllm_generate')
        .asFunction<LlamaGenerateDart>();

    _llamaEmbed = library
        .lookup<NativeFunction<LlamaEmbedNative>>('dartllm_embed')
        .asFunction<LlamaEmbedDart>();

    _llamaFree = library
        .lookup<NativeFunction<LlamaFreeNative>>('dartllm_free')
        .asFunction<LlamaFreeDart>();

    _llamaHasGpuSupport = library
        .lookup<NativeFunction<LlamaHasGpuSupportNative>>(
          'dartllm_has_gpu_support',
        )
        .asFunction<LlamaHasGpuSupportDart>();
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
    return _llamaHasGpuSupport!() != 0;
  }

  @override
  bool get supportsMultiThreading => isAvailable;

  @override
  Future<LoadModelResult> loadModel(LoadModelRequest request) async {
    _checkReady();

    final pathPointer = request.modelPath.toNativeUtf8();

    try {
      final modelPointer = _llamaLoadModel!(
        pathPointer,
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

    _llamaFreeModel!(pointer);
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

      final resultPointer = _llamaGenerate!(
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
        final result = _parseGenerateResult(resultPointer);
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
        _llamaFree!(resultPointer);
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
  Stream<GenerateStreamChunk> generateStream(GenerateRequest request) async* {
    _checkReady();

    // For streaming, we generate in chunks by repeatedly calling generate
    // with increasing max tokens. This is a simplified implementation;
    // a proper implementation would use a native streaming API.
    final result = await generate(request);

    for (var i = 0; i < result.tokens.length; i++) {
      final isLast = i == result.tokens.length - 1;
      yield GenerateStreamChunk(
        token: result.tokens[i],
        finishReason: isLast ? result.finishReason : null,
      );
    }
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

      final embeddingPointer = _llamaEmbed!(
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
        _llamaFree!(embeddingPointer.cast<Void>());
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
      final tokensPointer = _llamaTokenize!(
        pointer,
        textPointer,
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
        _llamaFree!(tokensPointer.cast<Void>());
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

      final textPointer = _llamaDetokenize!(
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
        return textPointer.toDartString();
      } finally {
        _llamaFree!(textPointer.cast<Void>());
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

    final infoPointer = _llamaGetModelInfo!(pointer);
    if (infoPointer == nullptr) {
      throw InvalidModelException(
        'handle:$handle',
        details: 'Failed to retrieve model information',
      );
    }

    try {
      return _parseModelInfo(infoPointer);
    } finally {
      _llamaFree!(infoPointer);
    }
  }

  /// Parses the native model info structure.
  ModelInfo _parseModelInfo(Pointer<Void> infoPointer) {
    final info = infoPointer.cast<DartLLMModelInfoStruct>().ref;

    return ModelInfo(
      name: _arrayToString(info.name, 256),
      parameterCount: info.parameterCount,
      architecture: _arrayToString(info.architecture, 64),
      quantization: _arrayToString(info.quantization, 32),
      contextSize: info.contextSize,
      vocabularySize: info.vocabularySize,
      embeddingSize: info.embeddingSize,
      layerCount: info.layerCount,
      headCount: info.headCount,
      fileSizeBytes: info.fileSizeBytes,
      supportsEmbedding: info.supportsEmbedding != 0,
      supportsVision: info.supportsVision != 0,
      chatTemplate: _arrayToString(info.chatTemplate, 4096),
    );
  }

  /// Converts a fixed-size char array to a Dart string.
  String _arrayToString(Array<Uint8> array, int maxLength) {
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
      _llamaFreeModel?.call(pointer);
    }
    _modelPointers.clear();

    _library = null;
    _isInitialized = false;

    _logger.info('Native binding disposed');
  }
}
