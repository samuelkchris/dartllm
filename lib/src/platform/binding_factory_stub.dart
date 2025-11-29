import 'package:dartllm/src/platform/platform_binding.dart';

/// Creates the platform-appropriate binding.
///
/// This is a stub that should never be called directly.
/// The actual implementation is provided by conditional imports.
PlatformBinding createPlatformBinding() {
  throw UnsupportedError(
    'Cannot create binding without platform-specific implementation',
  );
}

/// Initializes the platform binding.
///
/// This is a stub that should never be called directly.
Future<bool> initializePlatformBinding(PlatformBinding binding) async {
  throw UnsupportedError(
    'Cannot initialize binding without platform-specific implementation',
  );
}
