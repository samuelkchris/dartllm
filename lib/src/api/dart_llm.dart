import 'dart:async';

import 'package:dartllm/src/api/llm_model.dart';
import 'package:dartllm/src/core/huggingface_client.dart';
import 'package:dartllm/src/core/inference_engine.dart';
import 'package:dartllm/src/core/model_cache.dart';
import 'package:dartllm/src/core/model_downloader.dart';
import 'package:dartllm/src/models/global_config.dart';
import 'package:dartllm/src/models/model_config.dart';
import 'package:dartllm/src/models/model_info.dart';
import 'package:dartllm/src/platform/binding_factory.dart';
import 'package:dartllm/src/utils/logger.dart';
import 'package:dartllm/src/utils/path_utils.dart';
import 'package:dartllm/src/utils/platform_utils.dart';

/// Main entry point for the DartLLM package.
///
/// DartLLM provides static methods for:
/// - Loading models from local files
/// - Loading models from HuggingFace
/// - Downloading models from URLs
/// - Managing the model cache
/// - Configuring global settings
///
/// Example usage:
/// ```dart
/// // Load a model
/// final model = await DartLLM.loadModel('path/to/model.gguf');
///
/// // Chat with the model
/// final response = await model.chat([
///   ChatMessage.user('Hello!'),
/// ]);
/// print(response.message.content);
///
/// // Clean up
/// model.dispose();
/// ```
class DartLLM {
  static const String _loggerName = 'dartllm.api';
  static final DartLLMLogger _logger = DartLLMLogger(_loggerName);

  /// Global configuration settings.
  static GlobalConfig _globalConfig = const GlobalConfig();

  /// Model cache instance.
  static ModelCache? _modelCache;

  /// Model downloader instance.
  static ModelDownloader? _modelDownloader;

  /// HuggingFace client instance.
  static HuggingFaceClient? _huggingFaceClient;

  /// Private constructor to prevent instantiation.
  DartLLM._();

  /// Gets the current global configuration.
  static GlobalConfig get globalConfig => _globalConfig;

  /// Gets or creates the model cache.
  static Future<ModelCache> _getCache() async {
    if (_modelCache == null) {
      final cacheDir = _globalConfig.defaultCacheDirectory ??
          PathUtils.defaultModelCacheDir;
      _modelCache = ModelCache(cacheDirectory: cacheDir);
      await _modelCache!.initialize();
    }
    return _modelCache!;
  }

  /// Gets or creates the model downloader.
  static ModelDownloader _getDownloader() {
    _modelDownloader ??= ModelDownloader();
    return _modelDownloader!;
  }

  /// Gets or creates the HuggingFace client.
  static HuggingFaceClient _getHuggingFaceClient() {
    _huggingFaceClient ??= HuggingFaceClient(
      apiToken: _globalConfig.huggingFaceToken,
    );
    return _huggingFaceClient!;
  }

  /// Loads a model from a local file path.
  ///
  /// [path] is the path to the GGUF model file.
  /// [config] specifies model loading options.
  /// [onProgress] callback for loading progress (0.0 to 1.0).
  ///
  /// Returns an [LLMModel] instance ready for inference.
  ///
  /// Throws [ModelNotFoundException] if the file doesn't exist.
  /// Throws [InvalidModelException] if the file isn't a valid GGUF model.
  /// Throws [InsufficientMemoryException] if there isn't enough memory.
  ///
  /// Example:
  /// ```dart
  /// final model = await DartLLM.loadModel(
  ///   '/path/to/model.gguf',
  ///   config: ModelConfig(
  ///     contextSize: 4096,
  ///     gpuLayers: 32,
  ///   ),
  /// );
  /// ```
  static Future<LLMModel> loadModel(
    String path, {
    ModelConfig? config,
    void Function(double progress)? onProgress,
  }) async {
    _logger.info('Loading model from: $path');

    final binding = await BindingFactory.create();
    final engine = InferenceEngine(binding: binding);

    onProgress?.call(0.1);

    final modelInfo = await engine.loadModel(path, config: config);
    _logger.info('Model loaded: ${modelInfo.name}');

    onProgress?.call(1.0);

    return LLMModel.internal(engine);
  }

  /// Loads a model from a HuggingFace repository.
  ///
  /// [repo] is the repository identifier (e.g., 'TheBloke/Llama-2-7B-GGUF').
  /// [filename] is the specific file to download from the repo.
  /// [config] specifies model loading options.
  /// [onDownloadProgress] callback for download progress (0.0 to 1.0).
  /// [onLoadProgress] callback for loading progress (0.0 to 1.0).
  ///
  /// Returns an [LLMModel] instance ready for inference.
  ///
  /// The model will be cached locally after download.
  ///
  /// Example:
  /// ```dart
  /// final model = await DartLLM.loadFromHuggingFace(
  ///   'TheBloke/Llama-2-7B-GGUF',
  ///   filename: 'llama-2-7b.Q4_K_M.gguf',
  ///   onDownloadProgress: (p) => print('Download: ${(p * 100).toInt()}%'),
  /// );
  /// ```
  static Future<LLMModel> loadFromHuggingFace(
    String repo, {
    required String filename,
    ModelConfig? config,
    void Function(double progress)? onDownloadProgress,
    void Function(double progress)? onLoadProgress,
  }) async {
    _logger.info('Loading model from HuggingFace: $repo/$filename');

    final cache = await _getCache();
    final modelId = '$repo/$filename';

    // Check if model is cached
    if (await cache.hasModel(modelId)) {
      final cachedPath = await cache.getModelPath(modelId);
      if (cachedPath != null) {
        _logger.info('Found cached model: $cachedPath');
        onDownloadProgress?.call(1.0);
        return loadModel(
          cachedPath,
          config: config,
          onProgress: onLoadProgress,
        );
      }
    }

    // Get download URL from HuggingFace
    final hfClient = _getHuggingFaceClient();
    final downloadUrl = hfClient.getDownloadUrl(repo, filename);

    _logger.info('Downloading from: $downloadUrl');

    // Download the model
    final downloader = _getDownloader();
    final cacheDir = cache.cacheDirectory;
    final tempPath = '$cacheDir/${PathUtils.getCacheFilename(downloadUrl)}';

    final result = await downloader.download(
      downloadUrl,
      tempPath,
      onProgress: (progress) {
        if (progress.progress != null) {
          onDownloadProgress?.call(progress.progress!);
        }
      },
    );

    _logger.info('Download complete: ${result.sizeBytes} bytes');

    // Add to cache
    final cachedInfo = await cache.addModel(
      modelId,
      result.filePath,
      sourceUrl: downloadUrl,
      move: true,
    );

    // Load the model
    return loadModel(
      cachedInfo.filePath,
      config: config,
      onProgress: onLoadProgress,
    );
  }

  /// Loads a model from a URL.
  ///
  /// [url] is the direct download URL for the GGUF file.
  /// [config] specifies model loading options.
  /// [onDownloadProgress] callback for download progress (0.0 to 1.0).
  /// [onLoadProgress] callback for loading progress (0.0 to 1.0).
  ///
  /// Returns an [LLMModel] instance ready for inference.
  ///
  /// The model will be cached locally after download.
  ///
  /// Example:
  /// ```dart
  /// final model = await DartLLM.loadFromUrl(
  ///   'https://example.com/model.gguf',
  ///   onDownloadProgress: (p) => print('Download: ${(p * 100).toInt()}%'),
  /// );
  /// ```
  static Future<LLMModel> loadFromUrl(
    String url, {
    ModelConfig? config,
    void Function(double progress)? onDownloadProgress,
    void Function(double progress)? onLoadProgress,
  }) async {
    _logger.info('Loading model from URL: $url');

    final cache = await _getCache();
    final modelId = 'url:${PathUtils.getCacheFilename(url)}';

    // Check if model is cached
    if (await cache.hasModel(modelId)) {
      final cachedPath = await cache.getModelPath(modelId);
      if (cachedPath != null) {
        _logger.info('Found cached model: $cachedPath');
        onDownloadProgress?.call(1.0);
        return loadModel(
          cachedPath,
          config: config,
          onProgress: onLoadProgress,
        );
      }
    }

    // Download the model
    final downloader = _getDownloader();
    final cacheDir = cache.cacheDirectory;
    final tempPath = '$cacheDir/${PathUtils.getCacheFilename(url)}';

    final result = await downloader.download(
      url,
      tempPath,
      onProgress: (progress) {
        if (progress.progress != null) {
          onDownloadProgress?.call(progress.progress!);
        }
      },
    );

    _logger.info('Download complete: ${result.sizeBytes} bytes');

    // Add to cache
    final cachedInfo = await cache.addModel(
      modelId,
      result.filePath,
      sourceUrl: url,
      move: true,
    );

    // Load the model
    return loadModel(
      cachedInfo.filePath,
      config: config,
      onProgress: onLoadProgress,
    );
  }

  /// Lists all cached models.
  ///
  /// Returns a list of [CachedModelInfo] for each cached model.
  ///
  /// Example:
  /// ```dart
  /// final cached = await DartLLM.listCachedModels();
  /// for (final model in cached) {
  ///   print('${model.modelId}: ${model.sizeBytes} bytes');
  /// }
  /// ```
  static Future<List<CachedModelInfo>> listCachedModels() async {
    _logger.debug('Listing cached models');

    final cache = await _getCache();
    return cache.listModels();
  }

  /// Clears the model cache.
  ///
  /// [modelId] if specified, only clears that specific model.
  /// If null, clears all cached models.
  ///
  /// Returns the number of bytes freed.
  ///
  /// Example:
  /// ```dart
  /// // Clear specific model
  /// final freed = await DartLLM.clearCache(modelId: 'TheBloke/Llama-2-7B-GGUF/llama-2-7b.Q4_K_M.gguf');
  ///
  /// // Clear all
  /// final totalFreed = await DartLLM.clearCache();
  /// ```
  static Future<int> clearCache({String? modelId}) async {
    _logger.info('Clearing cache${modelId != null ? ' for $modelId' : ''}');

    final cache = await _getCache();

    if (modelId != null) {
      return cache.removeModel(modelId);
    }

    return cache.clear();
  }

  /// Gets the total size of the model cache in bytes.
  ///
  /// Example:
  /// ```dart
  /// final sizeBytes = await DartLLM.getCacheSize();
  /// print('Cache size: ${sizeBytes / (1024 * 1024)} MB');
  /// ```
  static Future<int> getCacheSize() async {
    _logger.debug('Getting cache size');

    final cache = await _getCache();
    return cache.totalSize();
  }

  /// Gets the number of cached models.
  ///
  /// Example:
  /// ```dart
  /// final count = await DartLLM.getCachedModelCount();
  /// print('Cached models: $count');
  /// ```
  static Future<int> getCachedModelCount() async {
    final cache = await _getCache();
    return cache.modelCount();
  }

  /// Gets information about a model file without loading it.
  ///
  /// [path] is the path to the GGUF model file.
  ///
  /// Returns [ModelInfo] with metadata about the model.
  ///
  /// This is useful for inspecting models before loading them.
  ///
  /// Example:
  /// ```dart
  /// final info = await DartLLM.getModelInfo('/path/to/model.gguf');
  /// print('Model: ${info.name}');
  /// print('Size: ${info.parameterCount} parameters');
  /// print('Context: ${info.contextSize} tokens');
  /// ```
  static Future<ModelInfo> getModelInfo(String path) async {
    _logger.debug('Getting model info for: $path');

    final binding = await BindingFactory.create();
    final engine = InferenceEngine(binding: binding);

    try {
      final info = await engine.loadModel(path);
      return info;
    } finally {
      await engine.dispose();
    }
  }

  /// Searches HuggingFace for models matching a query.
  ///
  /// [query] is the search term.
  /// [filter] can be 'gguf' to filter GGUF models.
  /// [limit] is the maximum results to return (default: 10).
  ///
  /// Returns a list of repository IDs.
  ///
  /// Example:
  /// ```dart
  /// final repos = await DartLLM.searchHuggingFace('llama 7b gguf');
  /// for (final repo in repos) {
  ///   print(repo);
  /// }
  /// ```
  static Future<List<String>> searchHuggingFace(
    String query, {
    String? filter,
    int limit = 10,
  }) async {
    _logger.debug('Searching HuggingFace: $query');

    final client = _getHuggingFaceClient();
    return client.searchRepos(query, filter: filter, limit: limit);
  }

  /// Gets information about a HuggingFace repository.
  ///
  /// [repo] is the repository identifier (e.g., 'TheBloke/Llama-2-7B-GGUF').
  ///
  /// Returns [HuggingFaceRepo] with repository info and file list.
  ///
  /// Example:
  /// ```dart
  /// final repo = await DartLLM.getHuggingFaceRepoInfo('TheBloke/Llama-2-7B-GGUF');
  /// for (final file in repo.ggufFiles) {
  ///   print('${file.filename}: ${file.sizeMB.toStringAsFixed(1)} MB');
  /// }
  /// ```
  static Future<HuggingFaceRepo> getHuggingFaceRepoInfo(String repo) async {
    _logger.debug('Getting HuggingFace repo info: $repo');

    final client = _getHuggingFaceClient();
    return client.getRepoInfo(repo);
  }

  /// Sets the global configuration.
  ///
  /// [config] is the new global configuration to use.
  ///
  /// Global config affects:
  /// - Default cache directory
  /// - Default GPU layers
  /// - Default thread count
  /// - Logging settings
  /// - HuggingFace API token
  ///
  /// Example:
  /// ```dart
  /// DartLLM.setGlobalConfig(GlobalConfig(
  ///   defaultGpuLayers: 32,
  ///   enableLogging: true,
  ///   logLevel: LogLevel.debug,
  /// ));
  /// ```
  static void setGlobalConfig(GlobalConfig config) {
    _globalConfig = config;
    DartLLMLogger.configure(
      enabled: config.enableLogging,
      level: config.logLevel,
    );

    // Reset cached instances if config changed
    if (_modelCache != null && config.defaultCacheDirectory != null) {
      _modelCache = null;
    }
    if (_huggingFaceClient != null) {
      _huggingFaceClient!.close();
      _huggingFaceClient = null;
    }

    _logger.debug('Global config updated');
  }

  /// Disposes of all cached resources.
  ///
  /// Call this when the application is shutting down to release resources.
  static void dispose() {
    _modelDownloader?.close();
    _modelDownloader = null;

    _huggingFaceClient?.close();
    _huggingFaceClient = null;

    _modelCache = null;

    _logger.debug('DartLLM resources disposed');
  }

  /// Gets the version of the DartLLM package.
  ///
  /// Returns the semantic version string.
  static String get version => '0.0.1';

  /// Gets the version of the underlying llama.cpp library.
  ///
  /// Returns null if the native library is not available.
  static String? get llamaCppVersion {
    return null;
  }

  /// Checks if the current platform is supported.
  ///
  /// Returns true if DartLLM can run on this platform.
  static bool get isPlatformSupported {
    return PlatformUtils.isSupported;
  }
}
