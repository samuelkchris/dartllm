/// Exception types for DartLLM error handling.
///
/// This library exports all exception classes used by DartLLM.
/// The exception hierarchy allows for both specific and general
/// error handling:
///
/// ```dart
/// try {
///   await DartLLM.loadModel(path: '/path/to/model.gguf');
/// } on ModelNotFoundException catch (e) {
///   // Handle missing model specifically
/// } on ModelException catch (e) {
///   // Handle any model-related error
/// } on DartLLMException catch (e) {
///   // Handle any DartLLM error
/// }
/// ```
library;

export 'dartllm_exception.dart';
export 'inference_exception.dart';
export 'memory_exception.dart';
export 'model_exception.dart';
export 'network_exception.dart';
export 'platform_exception.dart';
