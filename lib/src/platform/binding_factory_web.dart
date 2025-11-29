import 'package:dartllm/src/platform/platform_binding.dart';
import 'package:dartllm/src/platform/wasm_binding.dart';

/// Creates the web platform binding.
PlatformBinding createPlatformBinding() {
  return WasmBinding();
}

/// Initializes the web platform binding.
Future<bool> initializePlatformBinding(PlatformBinding binding) async {
  if (binding is WasmBinding) {
    return binding.initialize();
  }
  return false;
}
