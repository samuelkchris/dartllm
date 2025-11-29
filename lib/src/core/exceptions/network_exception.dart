import 'package:dartllm/src/core/exceptions/dartllm_exception.dart';

/// Base exception for network-related errors.
///
/// Thrown when operations involving network communication fail,
/// such as downloading models from remote sources.
class NetworkException extends DartLLMException {
  /// Creates a network exception with the given [message].
  ///
  /// Optionally provide a [cause] to preserve the original error.
  const NetworkException(super.message, {super.cause});

  @override
  String toString() {
    if (cause != null) {
      return 'NetworkException: $message (caused by: $cause)';
    }
    return 'NetworkException: $message';
  }
}

/// Thrown when a model download fails.
///
/// This exception indicates that a model could not be downloaded
/// from a remote source. Possible causes include:
/// - Network connectivity issues
/// - Server errors (5xx responses)
/// - File not found on server (404)
/// - Download interrupted
/// - Disk space exhausted during download
class DownloadException extends NetworkException {
  /// The URL that was being downloaded.
  final String url;

  /// The HTTP status code, if available.
  final int? statusCode;

  /// The number of bytes downloaded before failure.
  final int? bytesDownloaded;

  /// The total expected size in bytes, if known.
  final int? totalBytes;

  /// Creates an exception indicating download failure.
  ///
  /// The [url] is the resource that failed to download. Optionally
  /// provide [statusCode], [bytesDownloaded], and [totalBytes] for
  /// more detailed error information.
  DownloadException(
    this.url, {
    String? message,
    this.statusCode,
    this.bytesDownloaded,
    this.totalBytes,
    Object? cause,
  }) : super(message ?? 'Failed to download from $url', cause: cause);

  /// The download progress as a percentage (0.0 to 1.0).
  ///
  /// Returns null if total size is unknown.
  double? get progress {
    if (bytesDownloaded != null && totalBytes != null && totalBytes! > 0) {
      return bytesDownloaded! / totalBytes!;
    }
    return null;
  }

  @override
  String toString() {
    final buffer = StringBuffer('DownloadException: Failed to download from "$url"');
    if (statusCode != null) {
      buffer.write(' (HTTP $statusCode)');
    }
    if (bytesDownloaded != null) {
      final downloadedMb = (bytesDownloaded! / (1024 * 1024)).toStringAsFixed(1);
      if (totalBytes != null) {
        final totalMb = (totalBytes! / (1024 * 1024)).toStringAsFixed(1);
        buffer.write(' [${downloadedMb}MB of ${totalMb}MB downloaded]');
      } else {
        buffer.write(' [${downloadedMb}MB downloaded]');
      }
    }
    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }
    return buffer.toString();
  }
}

/// Thrown when a network connection cannot be established.
///
/// This exception indicates that the device could not connect
/// to the remote server. Possible causes include:
/// - No internet connectivity
/// - DNS resolution failure
/// - Server unreachable
/// - Connection timeout
/// - Firewall blocking the connection
class ConnectionException extends NetworkException {
  /// The host that could not be reached.
  final String? host;

  /// Whether this was a timeout.
  final bool isTimeout;

  /// The timeout duration if this was a timeout.
  final Duration? timeoutDuration;

  /// Creates an exception indicating connection failure.
  ///
  /// Optionally provide [host] for the unreachable server, and
  /// [isTimeout] with [timeoutDuration] if the connection timed out.
  const ConnectionException(
    super.message, {
    this.host,
    this.isTimeout = false,
    this.timeoutDuration,
    super.cause,
  });

  /// Creates a timeout exception for the given [host].
  factory ConnectionException.timeout(
    String host, {
    Duration? duration,
    Object? cause,
  }) {
    final durationStr = duration != null ? ' after ${duration.inSeconds}s' : '';
    return ConnectionException(
      'Connection to $host timed out$durationStr',
      host: host,
      isTimeout: true,
      timeoutDuration: duration,
      cause: cause,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('ConnectionException: $message');
    if (host != null && !message.contains(host!)) {
      buffer.write(' [host: $host]');
    }
    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }
    return buffer.toString();
  }
}

/// Thrown when authentication to a remote service fails.
///
/// This exception indicates that the provided credentials were
/// rejected by the remote service. This may occur when:
/// - Accessing private HuggingFace repositories without a valid token
/// - Token has expired
/// - Token lacks required permissions
/// - Invalid API key format
class AuthenticationException extends NetworkException {
  /// The service that rejected authentication.
  final String? service;

  /// Whether the token was missing entirely.
  final bool tokenMissing;

  /// Creates an exception indicating authentication failure.
  ///
  /// Optionally provide [service] to identify which service
  /// rejected the authentication. Set [tokenMissing] to true
  /// if the failure was due to no token being provided.
  const AuthenticationException(
    super.message, {
    this.service,
    this.tokenMissing = false,
    super.cause,
  });

  /// Creates an exception for a missing authentication token.
  factory AuthenticationException.missingToken(String service) {
    return AuthenticationException(
      'Authentication required for $service but no token was provided',
      service: service,
      tokenMissing: true,
    );
  }

  /// Creates an exception for an invalid or expired token.
  factory AuthenticationException.invalidToken(String service, {Object? cause}) {
    return AuthenticationException(
      'Authentication token for $service is invalid or expired',
      service: service,
      cause: cause,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('AuthenticationException: $message');
    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }
    return buffer.toString();
  }
}
