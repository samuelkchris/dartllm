import 'package:dartllm/src/core/exceptions/dartllm_exception.dart';

/// Base exception for memory-related errors.
///
/// Thrown when operations fail due to memory constraints, including
/// model loading, inference, and buffer allocation.
class MemoryException extends DartLLMException {
  /// Creates a memory exception with the given [message].
  ///
  /// Optionally provide a [cause] to preserve the original error.
  const MemoryException(super.message, {super.cause});

  @override
  String toString() {
    if (cause != null) {
      return 'MemoryException: $message (caused by: $cause)';
    }
    return 'MemoryException: $message';
  }
}

/// Thrown when there is not enough memory to complete an operation.
///
/// This exception indicates that the device lacks sufficient RAM
/// to load a model or perform inference. Common scenarios:
/// - Model is too large for available memory
/// - Context size requires more memory than available
/// - Multiple models are loaded simultaneously
///
/// Solutions:
/// - Use a smaller model or more aggressive quantization
/// - Reduce context size in ModelConfig
/// - Close other applications to free memory
/// - Unload unused models
class InsufficientMemoryException extends MemoryException {
  /// The amount of memory required in bytes.
  final int? requiredBytes;

  /// The amount of memory available in bytes.
  final int? availableBytes;

  /// Creates an exception indicating insufficient memory.
  ///
  /// Optionally provide [requiredBytes] and [availableBytes] to
  /// give users specific information about the memory shortfall.
  InsufficientMemoryException({
    this.requiredBytes,
    this.availableBytes,
    Object? cause,
  }) : super(
          _formatMessage(requiredBytes, availableBytes),
          cause: cause,
        );

  static String _formatMessage(int? required, int? available) {
    if (required != null && available != null) {
      final requiredMb = (required / (1024 * 1024)).toStringAsFixed(1);
      final availableMb = (available / (1024 * 1024)).toStringAsFixed(1);
      return 'Insufficient memory: requires ${requiredMb}MB but only ${availableMb}MB available';
    }
    return 'Insufficient memory to complete the operation';
  }

  @override
  String toString() {
    final buffer = StringBuffer('InsufficientMemoryException: ');
    if (requiredBytes != null && availableBytes != null) {
      final requiredMb = (requiredBytes! / (1024 * 1024)).toStringAsFixed(1);
      final availableMb = (availableBytes! / (1024 * 1024)).toStringAsFixed(1);
      buffer.write('Requires ${requiredMb}MB but only ${availableMb}MB available');
    } else {
      buffer.write('Insufficient memory to complete the operation');
    }
    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }
    return buffer.toString();
  }
}

/// Thrown when a memory allocation fails.
///
/// This exception indicates that a specific memory allocation
/// request could not be fulfilled. Unlike InsufficientMemoryException,
/// this typically indicates a failure in the native memory allocator
/// rather than a general lack of available memory.
class MemoryAllocationException extends MemoryException {
  /// The size of the failed allocation in bytes.
  final int? allocationSize;

  /// A description of what was being allocated.
  final String? allocationPurpose;

  /// Creates an exception indicating a memory allocation failure.
  ///
  /// Optionally provide [allocationSize] and [allocationPurpose]
  /// for more detailed error information.
  MemoryAllocationException({
    this.allocationSize,
    this.allocationPurpose,
    Object? cause,
  }) : super(
          _formatMessage(allocationSize, allocationPurpose),
          cause: cause,
        );

  static String _formatMessage(int? size, String? purpose) {
    final parts = <String>['Failed to allocate memory'];
    if (purpose != null) {
      parts.add('for $purpose');
    }
    if (size != null) {
      final sizeMb = (size / (1024 * 1024)).toStringAsFixed(1);
      parts.add('(${sizeMb}MB requested)');
    }
    return parts.join(' ');
  }

  @override
  String toString() {
    final buffer = StringBuffer('MemoryAllocationException: Failed to allocate memory');
    if (allocationPurpose != null) {
      buffer.write(' for $allocationPurpose');
    }
    if (allocationSize != null) {
      final sizeMb = (allocationSize! / (1024 * 1024)).toStringAsFixed(1);
      buffer.write(' (${sizeMb}MB requested)');
    }
    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }
    return buffer.toString();
  }
}

/// Thrown when the context size limit is exceeded.
///
/// This exception indicates that the combined length of the prompt
/// and generated tokens exceeds the model's configured context size.
/// The context size determines how many tokens the model can process
/// in a single session.
///
/// Solutions:
/// - Reduce the prompt length
/// - Increase contextSize in ModelConfig (requires more memory)
/// - Summarize or truncate conversation history
class ContextOverflowException extends MemoryException {
  /// The maximum context size in tokens.
  final int contextSize;

  /// The number of tokens that were attempted.
  final int attemptedTokens;

  /// Creates an exception indicating a context overflow.
  ///
  /// The [contextSize] is the maximum allowed tokens, and
  /// [attemptedTokens] is how many were actually needed.
  const ContextOverflowException({
    required this.contextSize,
    required this.attemptedTokens,
  }) : super(
          'Context overflow: attempted $attemptedTokens tokens '
          'but context size is limited to $contextSize',
        );

  /// The number of tokens that exceeded the limit.
  int get overflowAmount => attemptedTokens - contextSize;

  @override
  String toString() {
    return 'ContextOverflowException: Attempted $attemptedTokens tokens '
        'but context size is limited to $contextSize '
        '(overflow by $overflowAmount tokens)';
  }
}
