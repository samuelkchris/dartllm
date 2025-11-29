import 'package:dartllm/src/platform/native_binding.dart';
import 'package:dartllm/src/platform/platform_binding.dart';

/// Creates the native platform binding.
PlatformBinding createPlatformBinding() {
  return NativeBinding();
}

/// Initializes the native platform binding.
Future<bool> initializePlatformBinding(PlatformBinding binding) async {
  if (binding is NativeBinding) {
    return binding.initialize();
  }
  return false;
}
