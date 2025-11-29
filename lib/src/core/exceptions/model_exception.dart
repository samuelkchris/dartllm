import 'package:dartllm/src/core/exceptions/dartllm_exception.dart';

/// Base exception for model-related errors.
///
/// Thrown when operations involving model files fail, such as
/// loading, parsing, or validating GGUF model files.
class ModelException extends DartLLMException {
  /// Creates a model exception with the given [message].
  ///
  /// Optionally provide a [cause] to preserve the original error.
  const ModelException(super.message, {super.cause});

  @override
  String toString() {
    if (cause != null) {
      return 'ModelException: $message (caused by: $cause)';
    }
    return 'ModelException: $message';
  }
}

/// Thrown when a model file cannot be found at the specified location.
///
/// This exception indicates that the file path, URL, or HuggingFace
/// repository reference does not point to an existing model file.
///
/// Common causes:
/// - Incorrect file path
/// - File was moved or deleted
/// - Network resource is unavailable
/// - HuggingFace repository or file does not exist
class ModelNotFoundException extends ModelException {
  /// The path or URL that was not found.
  final String path;

  /// Creates an exception indicating the model at [path] was not found.
  ///
  /// Optionally provide a [cause] for the underlying error.
  const ModelNotFoundException(this.path, {Object? cause})
      : super('Model not found: $path', cause: cause);

  @override
  String toString() {
    if (cause != null) {
      return 'ModelNotFoundException: Model not found at "$path" (caused by: $cause)';
    }
    return 'ModelNotFoundException: Model not found at "$path"';
  }
}

/// Thrown when a file is not a valid GGUF model.
///
/// This exception indicates that while the file exists, it cannot
/// be parsed as a valid GGUF model file. This may occur if:
/// - The file is corrupted
/// - The file is not a GGUF file
/// - The file uses an unsupported format
class InvalidModelException extends ModelException {
  /// The path to the invalid model file.
  final String path;

  /// Additional details about why the model is invalid.
  final String? details;

  /// Creates an exception indicating the model at [path] is invalid.
  ///
  /// Optionally provide [details] explaining why the model is invalid
  /// and a [cause] for the underlying error.
  const InvalidModelException(this.path, {this.details, Object? cause})
      : super(
          details != null
              ? 'Invalid model at $path: $details'
              : 'Invalid model at $path',
          cause: cause,
        );

  @override
  String toString() {
    final buffer = StringBuffer('InvalidModelException: Invalid model at "$path"');
    if (details != null) {
      buffer.write(': $details');
    }
    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }
    return buffer.toString();
  }
}

/// Thrown when a model file version is not supported.
///
/// GGUF files have version numbers that indicate their format.
/// This exception is thrown when the model uses a version that
/// is newer than what DartLLM supports, or is too old.
class ModelVersionException extends ModelException {
  /// The version found in the model file.
  final int foundVersion;

  /// The minimum supported version.
  final int minVersion;

  /// The maximum supported version.
  final int maxVersion;

  /// Creates an exception indicating a version mismatch.
  ///
  /// The [foundVersion] is the version in the model file.
  /// [minVersion] and [maxVersion] define the supported range.
  const ModelVersionException({
    required this.foundVersion,
    required this.minVersion,
    required this.maxVersion,
  }) : super(
          'Model version $foundVersion is not supported. '
          'Supported versions: $minVersion to $maxVersion',
        );

  @override
  String toString() {
    return 'ModelVersionException: Model version $foundVersion is not supported. '
        'Supported versions: $minVersion to $maxVersion';
  }
}

/// Thrown when a model file is corrupted or incomplete.
///
/// This exception indicates that the model file exists and appears
/// to be a GGUF file, but its contents are corrupted. This may
/// occur due to:
/// - Incomplete download
/// - Disk errors
/// - File modification
/// - Checksum mismatch
class ModelCorruptedException extends ModelException {
  /// The path to the corrupted model file.
  final String path;

  /// The expected checksum, if available.
  final String? expectedChecksum;

  /// The actual checksum computed from the file, if available.
  final String? actualChecksum;

  /// Creates an exception indicating the model at [path] is corrupted.
  ///
  /// Optionally provide [expectedChecksum] and [actualChecksum] if
  /// the corruption was detected via checksum validation.
  const ModelCorruptedException(
    this.path, {
    this.expectedChecksum,
    this.actualChecksum,
    Object? cause,
  }) : super('Model file is corrupted: $path', cause: cause);

  @override
  String toString() {
    final buffer = StringBuffer('ModelCorruptedException: Model file is corrupted at "$path"');
    if (expectedChecksum != null && actualChecksum != null) {
      buffer.write(' (expected checksum: $expectedChecksum, actual: $actualChecksum)');
    }
    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }
    return buffer.toString();
  }
}
