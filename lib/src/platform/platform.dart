/// Platform abstraction layer for DartLLM.
///
/// This library provides the interface between the Dart API layer
/// and the native inference backend. It handles platform-specific
/// implementation details including FFI, WASM, and isolate management.
///
/// Key components:
/// - [PlatformBinding]: Abstract interface for LLM operations
/// - [BindingFactory]: Creates platform-appropriate bindings
/// - [IsolateManager]: Manages bridge isolate communication
///
/// Platform implementations:
/// - Native platforms use [NativeBinding] with Dart FFI
/// - Web platform uses [WasmBinding] with JS interop
library;

export 'binding_factory.dart';
export 'isolate_manager.dart';
export 'platform_binding.dart';
