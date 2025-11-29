import 'package:dartllm/src/core/exceptions/dartllm_exception.dart';

/// Base exception for platform-related errors.
///
/// Thrown when operations fail due to platform-specific issues,
/// such as unsupported platforms, GPU initialization failures,
/// or permission problems.
///
/// Note: This is distinct from Flutter's PlatformException. In
/// Flutter applications, use import aliases if needed to distinguish
/// between them.
class LLMPlatformException extends DartLLMException {
  /// Creates a platform exception with the given [message].
  ///
  /// Optionally provide a [cause] to preserve the original error.
  const LLMPlatformException(super.message, {super.cause});

  @override
  String toString() {
    if (cause != null) {
      return 'LLMPlatformException: $message (caused by: $cause)';
    }
    return 'LLMPlatformException: $message';
  }
}

/// Thrown when the current platform is not supported.
///
/// DartLLM supports specific platforms with minimum version
/// requirements. This exception is thrown when:
/// - Running on an unsupported operating system
/// - Platform version is below the minimum requirement
/// - Required platform features are unavailable
class UnsupportedPlatformException extends LLMPlatformException {
  /// The name of the current platform.
  final String platform;

  /// The current platform version, if known.
  final String? platformVersion;

  /// The minimum required version, if applicable.
  final String? minimumVersion;

  /// Creates an exception indicating an unsupported platform.
  ///
  /// The [platform] identifies the current platform. Optionally
  /// provide [platformVersion] and [minimumVersion] for version
  /// mismatch errors.
  UnsupportedPlatformException(
    this.platform, {
    this.platformVersion,
    this.minimumVersion,
    Object? cause,
  }) : super(
          _formatMessage(platform, platformVersion, minimumVersion),
          cause: cause,
        );

  static String _formatMessage(
    String platform,
    String? version,
    String? minimum,
  ) {
    if (version != null && minimum != null) {
      return 'Platform $platform version $version is not supported. '
          'Minimum required version: $minimum';
    }
    return 'Platform $platform is not supported by DartLLM';
  }

  @override
  String toString() {
    final buffer = StringBuffer('UnsupportedPlatformException: ');
    if (platformVersion != null && minimumVersion != null) {
      buffer.write('$platform version $platformVersion is not supported. ');
      buffer.write('Minimum required: $minimumVersion');
    } else {
      buffer.write('$platform is not supported by DartLLM');
    }
    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }
    return buffer.toString();
  }
}

/// Thrown when GPU initialization fails.
///
/// This exception indicates that GPU acceleration could not be
/// enabled. DartLLM will automatically fall back to CPU inference
/// when this occurs. Possible causes include:
/// - GPU driver not installed or outdated
/// - Insufficient GPU memory
/// - GPU compute features not supported
/// - Metal, Vulkan, or CUDA initialization failure
class GpuInitializationException extends LLMPlatformException {
  /// The GPU backend that failed to initialize.
  ///
  /// Examples: "Metal", "Vulkan", "CUDA", "OpenCL", "WebGPU"
  final String? backend;

  /// Whether the system will fall back to CPU inference.
  final bool willFallbackToCpu;

  /// Creates an exception indicating GPU initialization failure.
  ///
  /// Optionally specify the [backend] that failed and whether
  /// the system [willFallbackToCpu].
  const GpuInitializationException(
    super.message, {
    this.backend,
    this.willFallbackToCpu = true,
    super.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('GpuInitializationException: $message');
    if (backend != null) {
      buffer.write(' [backend: $backend]');
    }
    if (willFallbackToCpu) {
      buffer.write(' (falling back to CPU)');
    }
    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }
    return buffer.toString();
  }
}

/// Thrown when required permissions are not granted.
///
/// This exception indicates that the operation requires permissions
/// that have not been granted by the user or system. Common scenarios:
/// - File system access denied
/// - Network access not permitted (sandboxed apps)
/// - Storage permission not granted on mobile
class PermissionException extends LLMPlatformException {
  /// The type of permission that is missing.
  ///
  /// Examples: "storage", "network", "file_read", "file_write"
  final String permissionType;

  /// The resource that could not be accessed due to missing permission.
  final String? resource;

  /// Creates an exception indicating missing permissions.
  ///
  /// The [permissionType] identifies what permission is needed.
  /// Optionally provide [resource] to identify what could not be accessed.
  PermissionException(this.permissionType, {this.resource, Object? cause})
      : super(_formatMessage(permissionType, resource), cause: cause);

  static String _formatMessage(String permission, String? resource) {
    if (resource != null) {
      return 'Permission denied: $permission access required for $resource';
    }
    return 'Permission denied: $permission access required';
  }

  @override
  String toString() {
    final buffer = StringBuffer('PermissionException: ');
    buffer.write('$permissionType permission required');
    if (resource != null) {
      buffer.write(' for "$resource"');
    }
    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }
    return buffer.toString();
  }
}
