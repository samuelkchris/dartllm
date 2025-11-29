import 'package:logging/logging.dart' as logging;

import 'package:dartllm/src/models/enums.dart';

/// Internal logger for DartLLM diagnostic output.
///
/// This wrapper integrates the standard Dart [logging] package with
/// DartLLM's [LogLevel] enum and [GlobalConfig] settings.
///
/// Usage within DartLLM internals:
/// ```dart
/// final log = DartLLMLogger('dartllm.core.inference');
/// log.debug('Processing prompt with ${tokens} tokens');
/// log.info('Model loaded successfully');
/// log.warning('GPU acceleration unavailable, falling back to CPU');
/// log.error('Failed to allocate context', error, stackTrace);
/// ```
///
/// Library consumers can configure logging output by setting up handlers
/// on the root logger or the 'dartllm' logger hierarchy.
class DartLLMLogger {
  /// The underlying logger instance from the logging package.
  final logging.Logger _logger;

  /// Whether logging is currently enabled globally.
  static bool _enabled = false;

  /// The minimum log level that will be output.
  static LogLevel _minLevel = LogLevel.warning;

  /// Creates a logger with the specified name.
  ///
  /// Logger names should follow a hierarchical pattern:
  /// - `dartllm` - Root logger for the library
  /// - `dartllm.core` - Core inference engine
  /// - `dartllm.platform` - Platform bridge layer
  /// - `dartllm.api` - Public API layer
  DartLLMLogger(String name) : _logger = logging.Logger(name);

  /// Configures global logging settings.
  ///
  /// Called internally when [GlobalConfig] is applied via
  /// [DartLLM.setGlobalConfig].
  static void configure({
    required bool enabled,
    required LogLevel level,
  }) {
    _enabled = enabled;
    _minLevel = level;

    if (enabled) {
      logging.hierarchicalLoggingEnabled = true;
      logging.Logger.root.level = _mapToLoggingLevel(level);
    } else {
      logging.Logger.root.level = logging.Level.OFF;
    }
  }

  /// Maps DartLLM's [LogLevel] to the logging package's [Level].
  static logging.Level _mapToLoggingLevel(LogLevel level) {
    switch (level) {
      case LogLevel.error:
        return logging.Level.SEVERE;
      case LogLevel.warning:
        return logging.Level.WARNING;
      case LogLevel.info:
        return logging.Level.INFO;
      case LogLevel.debug:
        return logging.Level.FINE;
    }
  }

  /// Whether logging is currently enabled.
  static bool get isEnabled => _enabled;

  /// The current minimum log level.
  static LogLevel get minLevel => _minLevel;

  /// Logs a debug message.
  ///
  /// Use for detailed diagnostic information useful during development.
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enabled && _minLevel == LogLevel.debug) {
      _logger.fine(message, error, stackTrace);
    }
  }

  /// Logs an informational message.
  ///
  /// Use for general operational information like model loading,
  /// backend selection, and configuration changes.
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enabled && _minLevel.index >= LogLevel.info.index) {
      _logger.info(message, error, stackTrace);
    }
  }

  /// Logs a warning message.
  ///
  /// Use for potentially problematic situations that don't prevent
  /// operation, such as fallback to CPU or deprecated usage.
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enabled && _minLevel.index >= LogLevel.warning.index) {
      _logger.warning(message, error, stackTrace);
    }
  }

  /// Logs an error message.
  ///
  /// Use for error conditions that may affect functionality.
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.severe(message, error, stackTrace);
    }
  }

  /// Provides access to the underlying logger for advanced use cases.
  ///
  /// Library consumers can use this to attach custom handlers.
  logging.Logger get underlying => _logger;
}

/// Sets up a simple console handler for development.
///
/// This is a convenience function for library consumers who want
/// basic console output without custom configuration.
///
/// ```dart
/// import 'package:dartllm/src/utils/logger.dart';
///
/// void main() {
///   setupConsoleLogging();
///   // Now all DartLLM logs will print to console
/// }
/// ```
void setupConsoleLogging({LogLevel level = LogLevel.info}) {
  logging.hierarchicalLoggingEnabled = true;
  logging.Logger.root.level = DartLLMLogger._mapToLoggingLevel(level);

  logging.Logger.root.onRecord.listen((record) {
    final levelPrefix = _levelPrefix(record.level);
    final time = record.time.toIso8601String().substring(11, 23);
    // ignore: avoid_print
    print('$levelPrefix [$time] ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      // ignore: avoid_print
      print('  Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print('  ${record.stackTrace}');
    }
  });
}

String _levelPrefix(logging.Level level) {
  if (level >= logging.Level.SEVERE) return '[ERROR]';
  if (level >= logging.Level.WARNING) return '[WARN] ';
  if (level >= logging.Level.INFO) return '[INFO] ';
  return '[DEBUG]';
}
