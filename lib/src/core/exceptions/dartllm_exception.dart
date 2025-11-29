/// Base exception for all DartLLM errors.
///
/// All exceptions thrown by DartLLM inherit from this class, enabling
/// catch-all handling while still allowing specific exception handling
/// when needed.
///
/// Example:
/// ```dart
/// try {
///   await DartLLM.loadModel(path: '/path/to/model.gguf');
/// } on ModelNotFoundException catch (e) {
///   // Handle missing model specifically
/// } on DartLLMException catch (e) {
///   // Handle any DartLLM error
/// }
/// ```
class DartLLMException implements Exception {
  /// A human-readable description of the error.
  final String message;

  /// The underlying cause of this exception, if any.
  ///
  /// This may be another exception that triggered this error,
  /// useful for debugging and error chain analysis.
  final Object? cause;

  /// Creates a DartLLM exception with the given [message].
  ///
  /// Optionally provide a [cause] to preserve the original error
  /// that led to this exception.
  const DartLLMException(this.message, {this.cause});

  @override
  String toString() {
    if (cause != null) {
      return 'DartLLMException: $message (caused by: $cause)';
    }
    return 'DartLLMException: $message';
  }
}
