import 'dart:io';

import 'package:dartllm/src/utils/platform_utils.dart';

/// Path resolution utilities for model storage and caching.
///
/// Provides platform-specific default paths following OS conventions:
/// - Android: `{app_data}/models/`
/// - iOS: `{app_support}/models/`
/// - macOS: `~/Library/Caches/dartllm/models/`
/// - Windows: `%LOCALAPPDATA%\dartllm\models\`
/// - Linux: `~/.cache/dartllm/models/`
///
/// Note: For Flutter apps, consider using `path_provider` package
/// to get the proper app-specific directories. This utility provides
/// sensible defaults for pure Dart applications.
abstract final class PathUtils {
  /// The library's subdirectory name for cache storage.
  static const String libraryDirName = 'dartllm';

  /// The subdirectory name for model storage.
  static const String modelsDirName = 'models';

  /// Gets the default cache base directory for the current platform.
  ///
  /// Returns the platform-appropriate cache location:
  /// - macOS: `~/Library/Caches/`
  /// - Windows: `%LOCALAPPDATA%\`
  /// - Linux: `~/.cache/`
  ///
  /// Returns null on unsupported platforms (web, mobile without
  /// path_provider integration).
  static String? get defaultCacheBaseDir {
    switch (PlatformUtils.current) {
      case DartLLMPlatform.macos:
        return _macOSCacheDir;
      case DartLLMPlatform.windows:
        return _windowsCacheDir;
      case DartLLMPlatform.linux:
        return _linuxCacheDir;
      case DartLLMPlatform.android:
      case DartLLMPlatform.ios:
        // Mobile platforms require path_provider for proper paths
        // Return null to indicate caller should provide path
        return null;
      case DartLLMPlatform.web:
      case DartLLMPlatform.unknown:
        return null;
    }
  }

  /// Gets the default model cache directory path.
  ///
  /// Returns the full path to the models cache directory:
  /// - macOS: `~/Library/Caches/dartllm/models/`
  /// - Windows: `%LOCALAPPDATA%\dartllm\models\`
  /// - Linux: `~/.cache/dartllm/models/`
  ///
  /// Returns null if no default can be determined (mobile, web).
  static String? get defaultModelCacheDir {
    final baseDir = defaultCacheBaseDir;
    if (baseDir == null) return null;
    return joinPaths([baseDir, libraryDirName, modelsDirName]);
  }

  /// macOS cache directory: ~/Library/Caches/
  static String get _macOSCacheDir {
    final home = Platform.environment['HOME'] ?? '/tmp';
    return '$home/Library/Caches';
  }

  /// Windows cache directory: %LOCALAPPDATA%\
  static String get _windowsCacheDir {
    return Platform.environment['LOCALAPPDATA'] ??
        Platform.environment['APPDATA'] ??
        'C:\\Temp';
  }

  /// Linux cache directory: ~/.cache/
  static String get _linuxCacheDir {
    final xdgCache = Platform.environment['XDG_CACHE_HOME'];
    if (xdgCache != null && xdgCache.isNotEmpty) {
      return xdgCache;
    }
    final home = Platform.environment['HOME'] ?? '/tmp';
    return '$home/.cache';
  }

  /// Joins path segments using the platform-appropriate separator.
  ///
  /// ```dart
  /// PathUtils.joinPaths(['home', 'user', 'models']);
  /// // Unix: "home/user/models"
  /// // Windows: "home\\user\\models"
  /// ```
  static String joinPaths(List<String> segments) {
    final separator = Platform.pathSeparator;
    return segments.where((s) => s.isNotEmpty).join(separator);
  }

  /// Normalizes a path by removing redundant separators.
  ///
  /// ```dart
  /// PathUtils.normalizePath('/home//user///models/');
  /// // Returns: "/home/user/models"
  /// ```
  static String normalizePath(String path) {
    final separator = Platform.pathSeparator;
    final pattern = RegExp('${RegExp.escape(separator)}+');
    var normalized = path.replaceAll(pattern, separator);

    // Remove trailing separator unless it's the root
    if (normalized.length > 1 && normalized.endsWith(separator)) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    return normalized;
  }

  /// Expands a path by replacing ~ with the home directory.
  ///
  /// ```dart
  /// PathUtils.expandPath('~/models');
  /// // Returns: "/home/user/models" (on Linux)
  /// ```
  static String expandPath(String path) {
    if (!path.startsWith('~')) return path;

    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '';

    if (path == '~') return home;
    if (path.startsWith('~/') || path.startsWith('~\\')) {
      return home + path.substring(1);
    }

    return path;
  }

  /// Gets the file extension from a path.
  ///
  /// ```dart
  /// PathUtils.getExtension('/models/llama.gguf'); // 'gguf'
  /// PathUtils.getExtension('/models/readme'); // ''
  /// PathUtils.getExtension('.gitignore'); // 'gitignore'
  /// ```
  static String getExtension(String path) {
    final filename = getFilename(path);
    final lastDot = filename.lastIndexOf('.');

    // No dot found
    if (lastDot < 0) return '';

    // Hidden file without additional extension (e.g., ".gitignore")
    // Return the part after the dot as the extension
    if (lastDot == 0) {
      return filename.length > 1 ? filename.substring(1) : '';
    }

    // Normal file with extension
    return filename.substring(lastDot + 1);
  }

  /// Gets the filename from a path.
  ///
  /// ```dart
  /// PathUtils.getFilename('/models/llama.gguf'); // 'llama.gguf'
  /// ```
  static String getFilename(String path) {
    final lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    if (lastSeparator < 0) return path;
    return path.substring(lastSeparator + 1);
  }

  /// Gets the directory portion of a path.
  ///
  /// ```dart
  /// PathUtils.getDirectory('/models/llama.gguf'); // '/models'
  /// ```
  static String getDirectory(String path) {
    final lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    if (lastSeparator < 0) return '';
    return path.substring(0, lastSeparator);
  }

  /// Checks if a path is absolute.
  ///
  /// ```dart
  /// PathUtils.isAbsolute('/home/user'); // true (Unix)
  /// PathUtils.isAbsolute('C:\\Users'); // true (Windows)
  /// PathUtils.isAbsolute('models/file'); // false
  /// ```
  static bool isAbsolute(String path) {
    if (path.isEmpty) return false;

    // Unix absolute path
    if (path.startsWith('/')) return true;

    // Windows absolute path (e.g., C:\, D:\)
    if (path.length >= 3 &&
        path[1] == ':' &&
        (path[2] == '\\' || path[2] == '/')) {
      return true;
    }

    // UNC path (\\server\share)
    if (path.startsWith('\\\\')) return true;

    return false;
  }

  /// Generates a cache filename from a URL.
  ///
  /// Creates a safe, unique filename based on URL hash.
  ///
  /// ```dart
  /// PathUtils.getCacheFilename(
  ///   'https://huggingface.co/model.gguf',
  /// ); // 'a1b2c3d4e5f6.gguf'
  /// ```
  static String getCacheFilename(String url) {
    final hash = url.hashCode.toUnsigned(32).toRadixString(16).padLeft(8, '0');
    final extension = getExtension(url);
    return extension.isNotEmpty ? '$hash.$extension' : hash;
  }

  /// Validates that a path is safe and doesn't contain dangerous patterns.
  ///
  /// Throws [ArgumentError] if the path is unsafe.
  ///
  /// Checks for:
  /// - Path traversal attempts (..)
  /// - Empty paths
  /// - Null bytes
  static void validatePath(String path) {
    if (path.isEmpty) {
      throw ArgumentError.value(path, 'path', 'Path cannot be empty');
    }

    if (path.contains('\x00')) {
      throw ArgumentError.value(path, 'path', 'Path cannot contain null bytes');
    }

    // Check for path traversal
    final segments = path.split(RegExp(r'[/\\]'));
    for (final segment in segments) {
      if (segment == '..') {
        throw ArgumentError.value(
          path,
          'path',
          'Path traversal detected (..) is not allowed',
        );
      }
    }
  }

  /// Checks if a path is safe without throwing.
  ///
  /// Returns true if the path passes validation.
  static bool isValidPath(String path) {
    try {
      validatePath(path);
      return true;
    } catch (_) {
      return false;
    }
  }
}
