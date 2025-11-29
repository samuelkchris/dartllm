import 'package:dartllm/src/core/exceptions/platform_exception.dart';
import 'package:dartllm/src/platform/platform_binding.dart';
import 'package:dartllm/src/utils/logger.dart';
import 'package:dartllm/src/utils/platform_utils.dart';

import 'package:dartllm/src/platform/binding_factory_stub.dart'
    if (dart.library.io) 'package:dartllm/src/platform/binding_factory_native.dart'
    if (dart.library.js_interop) 'package:dartllm/src/platform/binding_factory_web.dart'
    as platform_impl;

/// Factory for creating platform-appropriate bindings.
///
/// This factory automatically selects the correct binding implementation
/// based on the current runtime platform:
/// - Native platforms (Android, iOS, macOS, Windows, Linux): [NativeBinding]
/// - Web platform: [WasmBinding]
///
/// Usage:
/// ```dart
/// final binding = await BindingFactory.create();
/// final result = await binding.loadModel(request);
/// ```
abstract final class BindingFactory {
  static const String _loggerName = 'dartllm.platform.factory';
  static final DartLLMLogger _logger = DartLLMLogger(_loggerName);

  /// The singleton binding instance.
  static PlatformBinding? _instance;

  /// Whether initialization is in progress.
  static bool _initializing = false;

  /// Creates and initializes a platform-appropriate binding.
  ///
  /// This method returns a singleton instance. Multiple calls return
  /// the same binding.
  ///
  /// Throws [UnsupportedPlatformException] if the platform is not supported.
  /// Throws [LLMPlatformException] if the native library fails to load.
  static Future<PlatformBinding> create() async {
    if (_instance != null) {
      return _instance!;
    }

    if (_initializing) {
      while (_initializing) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      if (_instance != null) {
        return _instance!;
      }
    }

    _initializing = true;

    try {
      final platform = PlatformUtils.current;
      _logger.info('Creating binding for platform: ${PlatformUtils.platformName}');

      if (!PlatformUtils.isSupported) {
        throw UnsupportedPlatformException(PlatformUtils.platformName);
      }

      if (platform == DartLLMPlatform.unknown) {
        throw UnsupportedPlatformException(PlatformUtils.platformName);
      }

      final binding = platform_impl.createPlatformBinding();
      final initialized = await platform_impl.initializePlatformBinding(binding);

      if (!initialized) {
        throw LLMPlatformException(
          'Failed to initialize platform binding. '
          'The native library may not be bundled with the application.',
        );
      }

      _instance = binding;
      _logger.info('Platform binding created successfully');
      return binding;
    } finally {
      _initializing = false;
    }
  }

  /// Returns the current binding instance, or null if not created.
  static PlatformBinding? get instance => _instance;

  /// Disposes the current binding and clears the singleton.
  ///
  /// After calling this, [create] will create a new binding.
  static void dispose() {
    _instance?.dispose();
    _instance = null;
    _logger.info('Binding factory disposed');
  }

  /// Resets the factory state for testing purposes.
  ///
  /// This is intended only for use in tests.
  static void resetForTesting() {
    _instance?.dispose();
    _instance = null;
    _initializing = false;
  }
}
