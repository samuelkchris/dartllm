import 'dart:io';

import 'package:dartllm/src/models/model_info.dart';
import 'package:dartllm/src/utils/logger.dart';
import 'package:dartllm/src/utils/path_utils.dart';
import 'package:dartllm/src/utils/platform_utils.dart';

/// Manages cached model files on disk.
///
/// The ModelCache provides functionality for:
/// - Listing cached models
/// - Adding models to cache
/// - Removing models from cache
/// - Managing cache directory per platform
///
/// Example usage:
/// ```dart
/// final cache = ModelCache();
/// await cache.initialize();
///
/// // List cached models
/// final models = await cache.listModels();
///
/// // Get cache size
/// final sizeBytes = await cache.totalSize();
///
/// // Clear all cached models
/// await cache.clear();
/// ```
class ModelCache {
  static const String _loggerName = 'dartllm.core.cache';
  final DartLLMLogger _logger = DartLLMLogger(_loggerName);

  /// The base directory for the cache.
  final String? _customCacheDir;

  /// The resolved cache directory.
  Directory? _cacheDir;

  /// Whether the cache has been initialized.
  bool _initialized = false;

  /// Creates a ModelCache with an optional custom cache directory.
  ///
  /// If [cacheDirectory] is null, uses the platform-specific default.
  ModelCache({String? cacheDirectory}) : _customCacheDir = cacheDirectory;

  /// Whether the cache has been initialized.
  bool get isInitialized => _initialized;

  /// The cache directory path.
  ///
  /// Throws [StateError] if not initialized.
  String get cacheDirectory {
    _checkInitialized();
    return _cacheDir!.path;
  }

  /// Initializes the cache, creating the directory if needed.
  ///
  /// This must be called before using other cache methods.
  Future<void> initialize() async {
    if (_initialized) return;

    final dirPath = _customCacheDir ?? await PlatformUtils.defaultCacheDirectory;
    _cacheDir = Directory(dirPath);

    if (!await _cacheDir!.exists()) {
      _logger.info('Creating cache directory: $dirPath');
      await _cacheDir!.create(recursive: true);
    }

    _initialized = true;
    _logger.info('Cache initialized at: $dirPath');
  }

  /// Lists all cached models.
  ///
  /// Returns a list of [CachedModelInfo] for each model in the cache.
  Future<List<CachedModelInfo>> listModels() async {
    _checkInitialized();

    final models = <CachedModelInfo>[];
    final metadataDir = Directory('${_cacheDir!.path}/.metadata');

    if (!await metadataDir.exists()) {
      return models;
    }

    await for (final entity in metadataDir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final info = await _readModelMetadata(entity);
          if (info != null) {
            models.add(info);
          }
        } catch (e) {
          _logger.warning('Failed to read metadata: ${entity.path}', e);
        }
      }
    }

    return models;
  }

  /// Gets information about a specific cached model.
  ///
  /// Returns null if the model is not in the cache.
  Future<CachedModelInfo?> getModel(String modelId) async {
    _checkInitialized();

    final metadataFile = _getMetadataFile(modelId);
    if (!await metadataFile.exists()) {
      return null;
    }

    return _readModelMetadata(metadataFile);
  }

  /// Checks if a model is cached.
  Future<bool> hasModel(String modelId) async {
    _checkInitialized();

    final metadataFile = _getMetadataFile(modelId);
    return metadataFile.exists();
  }

  /// Gets the file path for a cached model.
  ///
  /// Returns null if the model is not in the cache.
  Future<String?> getModelPath(String modelId) async {
    final info = await getModel(modelId);
    return info?.filePath;
  }

  /// Adds a model to the cache.
  ///
  /// [modelId] is the unique identifier for the model.
  /// [sourcePath] is the path to the model file to cache.
  /// [sourceUrl] is the optional URL the model was downloaded from.
  /// [move] if true, moves the file instead of copying (default: false).
  ///
  /// Returns the cached model info.
  Future<CachedModelInfo> addModel(
    String modelId,
    String sourcePath, {
    String? sourceUrl,
    bool move = false,
  }) async {
    _checkInitialized();

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw ArgumentError('Source file does not exist: $sourcePath');
    }

    // Validate the path
    PathUtils.validatePath(sourcePath);

    // Create target path
    final sanitizedId = _sanitizeModelId(modelId);
    final targetPath = '${_cacheDir!.path}/$sanitizedId';
    final targetFile = File(targetPath);

    // Copy or move the file
    if (move) {
      _logger.info('Moving model to cache: $modelId');
      await sourceFile.rename(targetPath);
    } else {
      _logger.info('Copying model to cache: $modelId');
      await sourceFile.copy(targetPath);
    }

    // Get file stats
    final stat = await targetFile.stat();

    // Create metadata
    final info = CachedModelInfo(
      modelId: modelId,
      filePath: targetPath,
      sizeBytes: stat.size,
      downloadedAt: DateTime.now(),
      sourceUrl: sourceUrl ?? 'local://$sourcePath',
    );

    // Save metadata
    await _writeModelMetadata(modelId, info);

    _logger.info('Model cached: $modelId (${info.sizeFormatted})');

    return info;
  }

  /// Removes a model from the cache.
  ///
  /// Returns the size in bytes of the removed file, or 0 if not found.
  Future<int> removeModel(String modelId) async {
    _checkInitialized();

    final info = await getModel(modelId);
    if (info == null) {
      return 0;
    }

    final modelFile = File(info.filePath);
    final metadataFile = _getMetadataFile(modelId);

    int freedBytes = 0;

    // Delete model file
    if (await modelFile.exists()) {
      freedBytes = info.sizeBytes;
      await modelFile.delete();
      _logger.info('Deleted model file: ${info.filePath}');
    }

    // Delete metadata
    if (await metadataFile.exists()) {
      await metadataFile.delete();
    }

    _logger.info('Removed model from cache: $modelId');

    return freedBytes;
  }

  /// Clears all models from the cache.
  ///
  /// Returns the total bytes freed.
  Future<int> clear() async {
    _checkInitialized();

    int totalFreed = 0;
    final models = await listModels();

    for (final model in models) {
      totalFreed += await removeModel(model.modelId);
    }

    _logger.info('Cache cleared, freed ${(totalFreed / (1024 * 1024)).toStringAsFixed(1)} MB');

    return totalFreed;
  }

  /// Gets the total size of the cache in bytes.
  Future<int> totalSize() async {
    _checkInitialized();

    int total = 0;
    final models = await listModels();

    for (final model in models) {
      total += model.sizeBytes;
    }

    return total;
  }

  /// Gets the number of models in the cache.
  Future<int> modelCount() async {
    final models = await listModels();
    return models.length;
  }

  /// Verifies a cached model file exists and matches expected size.
  Future<bool> verifyModel(String modelId) async {
    final info = await getModel(modelId);
    if (info == null) {
      return false;
    }

    final file = File(info.filePath);
    if (!await file.exists()) {
      return false;
    }

    final stat = await file.stat();
    return stat.size == info.sizeBytes;
  }

  /// Sanitizes a model ID for use as a filename.
  String _sanitizeModelId(String modelId) {
    return modelId
        .replaceAll('/', '_')
        .replaceAll('\\', '_')
        .replaceAll(':', '_')
        .replaceAll('?', '_')
        .replaceAll('*', '_')
        .replaceAll('"', '_')
        .replaceAll('<', '_')
        .replaceAll('>', '_')
        .replaceAll('|', '_');
  }

  /// Gets the metadata file for a model.
  File _getMetadataFile(String modelId) {
    final sanitizedId = _sanitizeModelId(modelId);
    return File('${_cacheDir!.path}/.metadata/$sanitizedId.json');
  }

  /// Reads model metadata from a file.
  Future<CachedModelInfo?> _readModelMetadata(File file) async {
    try {
      final content = await file.readAsString();
      final lines = content.split('\n');

      String? modelId;
      String? filePath;
      int? sizeBytes;
      DateTime? downloadedAt;
      String? sourceUrl;

      for (final line in lines) {
        final parts = line.split('=');
        if (parts.length != 2) continue;

        final key = parts[0].trim();
        final value = parts[1].trim();

        switch (key) {
          case 'modelId':
            modelId = value;
          case 'filePath':
            filePath = value;
          case 'sizeBytes':
            sizeBytes = int.tryParse(value);
          case 'downloadedAt':
            downloadedAt = DateTime.tryParse(value);
          case 'sourceUrl':
            sourceUrl = value.isEmpty ? null : value;
        }
      }

      if (modelId != null &&
          filePath != null &&
          sizeBytes != null &&
          downloadedAt != null &&
          sourceUrl != null) {
        return CachedModelInfo(
          modelId: modelId,
          filePath: filePath,
          sizeBytes: sizeBytes,
          downloadedAt: downloadedAt,
          sourceUrl: sourceUrl,
        );
      }

      return null;
    } catch (e) {
      _logger.warning('Failed to parse metadata: ${file.path}', e);
      return null;
    }
  }

  /// Writes model metadata to a file.
  Future<void> _writeModelMetadata(String modelId, CachedModelInfo info) async {
    final metadataFile = _getMetadataFile(modelId);
    final metadataDir = metadataFile.parent;

    if (!await metadataDir.exists()) {
      await metadataDir.create(recursive: true);
    }

    final content = '''
modelId=${info.modelId}
filePath=${info.filePath}
sizeBytes=${info.sizeBytes}
downloadedAt=${info.downloadedAt.toIso8601String()}
sourceUrl=${info.sourceUrl}
''';

    await metadataFile.writeAsString(content);
  }

  /// Checks that the cache has been initialized.
  void _checkInitialized() {
    if (!_initialized) {
      throw StateError('ModelCache not initialized. Call initialize() first.');
    }
  }
}
