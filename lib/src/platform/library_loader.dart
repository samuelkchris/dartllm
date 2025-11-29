import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Handles loading the native DartLLM library across all platforms.
///
/// This loader searches for the native library in multiple locations:
/// 1. Bundled with the package (for distribution)
/// 2. Next to the executable (for deployed apps)
/// 3. In the build output directory (for development)
/// 4. System library paths
class LibraryLoader {
  static DynamicLibrary? _cachedLibrary;

  /// Loads the native DartLLM library.
  ///
  /// Returns the loaded [DynamicLibrary] or throws an exception if not found.
  static DynamicLibrary load() {
    if (_cachedLibrary != null) {
      return _cachedLibrary!;
    }

    final library = _tryLoadLibrary();
    if (library == null) {
      throw LibraryLoadException(
        'Failed to load DartLLM native library. '
        'Please ensure the native library is built and available. '
        'Run: dart run dartllm:setup',
      );
    }

    _cachedLibrary = library;
    return library;
  }

  /// Attempts to load the library from various locations.
  static DynamicLibrary? _tryLoadLibrary() {
    final searchPaths = _getSearchPaths();

    for (final path in searchPaths) {
      try {
        final library = DynamicLibrary.open(path);
        return library;
      } on ArgumentError {
        // Library not found at this path, try next
        continue;
      }
    }

    // Try loading from system path as last resort
    try {
      return DynamicLibrary.open(_getSystemLibraryName());
    } on ArgumentError {
      return null;
    }
  }

  /// Gets all paths to search for the native library.
  static List<String> _getSearchPaths() {
    final paths = <String>[];
    final libName = _getLibraryFileName();

    // 1. Package's bundled binaries directory
    final packageRoot = _getPackageRoot();
    if (packageRoot != null) {
      final platformDir = _getPlatformDirectoryName();
      paths.add(p.join(packageRoot, 'native', 'build', platformDir, libName));
      paths.add(p.join(packageRoot, 'blobs', platformDir, libName));
    }

    // 2. Next to the executable (deployed apps)
    final execDir = p.dirname(Platform.resolvedExecutable);
    paths.add(p.join(execDir, libName));
    paths.add(p.join(execDir, 'lib', libName));
    paths.add(p.join(execDir, 'blobs', libName));

    // 3. Current working directory and subdirectories
    final cwd = Directory.current.path;
    paths.add(p.join(cwd, libName));
    paths.add(p.join(cwd, 'native', 'build', _getPlatformDirectoryName(), libName));
    paths.add(p.join(cwd, 'blobs', _getPlatformDirectoryName(), libName));

    // 4. Relative to script (for development)
    if (Platform.script.scheme == 'file') {
      final scriptDir = p.dirname(Platform.script.toFilePath());
      paths.add(p.join(scriptDir, libName));
      paths.add(p.join(scriptDir, '..', 'blobs', _getPlatformDirectoryName(), libName));
    }

    // 5. macOS Framework location
    if (Platform.isMacOS) {
      paths.add(p.join(cwd, 'llamacpp.framework', 'llamacpp'));
      paths.add(p.join(execDir, 'llamacpp.framework', 'llamacpp'));
      if (packageRoot != null) {
        paths.add(p.join(packageRoot, 'blobs', 'macos', 'llamacpp.framework', 'llamacpp'));
        paths.add(p.join(packageRoot, 'native', 'build', 'macos', 'llamacpp.framework', 'llamacpp'));
      }
    }

    return paths;
  }

  /// Gets the platform-specific library file name.
  static String _getLibraryFileName() {
    if (Platform.isMacOS) {
      return 'libdartllm.dylib';
    } else if (Platform.isWindows) {
      return 'dartllm.dll';
    } else if (Platform.isLinux || Platform.isAndroid) {
      return 'libdartllm.so';
    } else if (Platform.isIOS) {
      return 'dartllm.framework/dartllm';
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  /// Gets the system library name for DynamicLibrary.open fallback.
  static String _getSystemLibraryName() {
    if (Platform.isMacOS) {
      return 'llamacpp.framework/llamacpp';
    } else if (Platform.isWindows) {
      return 'dartllm.dll';
    } else {
      return 'libdartllm.so';
    }
  }

  /// Gets the platform directory name for build outputs.
  static String _getPlatformDirectoryName() {
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// Attempts to find the package root directory.
  static String? _getPackageRoot() {
    // Try to find the package root by looking for pubspec.yaml
    var dir = Directory.current;
    for (var i = 0; i < 10; i++) {
      final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        final content = pubspec.readAsStringSync();
        if (content.contains('name: dartllm')) {
          return dir.path;
        }
      }
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }

    // Check if running from pub cache
    if (Platform.script.scheme == 'file') {
      final scriptPath = Platform.script.toFilePath();
      if (scriptPath.contains('.pub-cache')) {
        // Find the dartllm package directory
        final match = RegExp(r'dartllm-[\d.]+').firstMatch(scriptPath);
        if (match != null) {
          final idx = scriptPath.indexOf(match.group(0)!);
          return scriptPath.substring(0, idx + match.group(0)!.length);
        }
      }
    }

    return null;
  }

  /// Gets all searched paths for debugging.
  static List<String> getSearchedPaths() {
    return _getSearchPaths();
  }
}

/// Exception thrown when the native library cannot be loaded.
class LibraryLoadException implements Exception {
  /// The error message.
  final String message;

  /// Creates a library load exception.
  LibraryLoadException(this.message);

  @override
  String toString() => 'LibraryLoadException: $message';
}
