import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dartllm/src/core/exceptions/network_exception.dart';
import 'package:dartllm/src/utils/logger.dart';

/// Progress information for a download.
class DownloadProgress {
  /// Bytes downloaded so far.
  final int downloadedBytes;

  /// Total bytes to download, or null if unknown.
  final int? totalBytes;

  /// Download speed in bytes per second.
  final double bytesPerSecond;

  /// Creates download progress info.
  const DownloadProgress({
    required this.downloadedBytes,
    this.totalBytes,
    required this.bytesPerSecond,
  });

  /// Progress as a fraction from 0.0 to 1.0, or null if total is unknown.
  double? get progress {
    if (totalBytes == null || totalBytes == 0) return null;
    return downloadedBytes / totalBytes!;
  }

  /// Estimated time remaining in seconds, or null if unknown.
  double? get estimatedSecondsRemaining {
    if (totalBytes == null || bytesPerSecond == 0) return null;
    final remaining = totalBytes! - downloadedBytes;
    return remaining / bytesPerSecond;
  }

  /// Downloaded megabytes.
  double get downloadedMB => downloadedBytes / (1024 * 1024);

  /// Total megabytes, or null if unknown.
  double? get totalMB => totalBytes != null ? totalBytes! / (1024 * 1024) : null;
}

/// Result of a completed download.
class DownloadResult {
  /// Path to the downloaded file.
  final String filePath;

  /// Size of the file in bytes.
  final int sizeBytes;

  /// Duration of the download.
  final Duration duration;

  /// Creates a download result.
  const DownloadResult({
    required this.filePath,
    required this.sizeBytes,
    required this.duration,
  });

  /// Average download speed in bytes per second.
  double get averageBytesPerSecond {
    if (duration.inMilliseconds == 0) return 0;
    return sizeBytes / (duration.inMilliseconds / 1000);
  }
}

/// Downloads model files from URLs with progress tracking and resume support.
///
/// The ModelDownloader provides:
/// - Progress callbacks during download
/// - Resume capability for interrupted downloads
/// - Checksum validation
/// - Timeout handling
///
/// Example usage:
/// ```dart
/// final downloader = ModelDownloader();
///
/// final result = await downloader.download(
///   'https://example.com/model.gguf',
///   '/path/to/save/model.gguf',
///   onProgress: (progress) {
///     print('${(progress.progress! * 100).toInt()}%');
///   },
/// );
///
/// print('Downloaded ${result.sizeBytes} bytes');
/// ```
class ModelDownloader {
  static const String _loggerName = 'dartllm.core.downloader';
  final DartLLMLogger _logger = DartLLMLogger(_loggerName);

  /// HTTP client for downloads.
  final HttpClient _client;

  /// Connection timeout.
  final Duration _connectTimeout;

  /// Idle timeout (between data chunks).
  final Duration _idleTimeout;

  /// Creates a ModelDownloader.
  ///
  /// [connectTimeout] is the timeout for establishing connections.
  /// [idleTimeout] is the timeout for idle periods during download.
  ModelDownloader({
    Duration connectTimeout = const Duration(seconds: 30),
    Duration idleTimeout = const Duration(seconds: 60),
  })  : _connectTimeout = connectTimeout,
        _idleTimeout = idleTimeout,
        _client = HttpClient() {
    _client.connectionTimeout = _connectTimeout;
    _client.idleTimeout = _idleTimeout;
  }

  /// Downloads a file from a URL.
  ///
  /// [url] is the URL to download from.
  /// [destinationPath] is where to save the file.
  /// [onProgress] is called with download progress.
  /// [resume] if true, attempts to resume a partial download.
  /// [expectedSize] is the expected file size for validation.
  /// [expectedSha256] is the expected SHA-256 hash for validation.
  ///
  /// Returns a [DownloadResult] on success.
  ///
  /// Throws [DownloadException] if the download fails.
  /// Throws [ConnectionException] if the connection fails.
  Future<DownloadResult> download(
    String url,
    String destinationPath, {
    void Function(DownloadProgress progress)? onProgress,
    bool resume = true,
    int? expectedSize,
    String? expectedSha256,
  }) async {
    _logger.info('Starting download: $url');

    final tempFile = File('$destinationPath.part');
    int startByte = 0;

    // Check for partial download to resume
    if (resume && await tempFile.exists()) {
      final stat = await tempFile.stat();
      startByte = stat.size;
      _logger.info('Resuming download from byte $startByte');
    }

    final stopwatch = Stopwatch()..start();
    int downloadedBytes = startByte;
    int lastProgressBytes = startByte;
    DateTime lastProgressTime = DateTime.now();

    try {
      final uri = Uri.parse(url);
      final request = await _client.getUrl(uri);

      // Add range header for resume
      if (startByte > 0) {
        request.headers.set('Range', 'bytes=$startByte-');
      }

      final response = await request.close();

      // Check response status
      if (response.statusCode != 200 && response.statusCode != 206) {
        throw DownloadException(
          url,
          message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }

      // Get total size
      final contentLength = response.contentLength;
      final totalBytes = contentLength > 0
          ? (response.statusCode == 206 ? startByte + contentLength : contentLength)
          : expectedSize;

      _logger.info('Total size: ${totalBytes != null ? "${totalBytes ~/ (1024 * 1024)} MB" : "unknown"}');

      // Open file for writing
      final sink = tempFile.openWrite(mode: startByte > 0 ? FileMode.append : FileMode.write);

      try {
        await for (final chunk in response) {
          sink.add(chunk);
          downloadedBytes += chunk.length;

          // Calculate progress
          final now = DateTime.now();
          final elapsed = now.difference(lastProgressTime).inMilliseconds;

          if (elapsed >= 100) {
            // Update every 100ms
            final bytesDelta = downloadedBytes - lastProgressBytes;
            final bytesPerSecond = bytesDelta / (elapsed / 1000);

            onProgress?.call(DownloadProgress(
              downloadedBytes: downloadedBytes,
              totalBytes: totalBytes,
              bytesPerSecond: bytesPerSecond,
            ));

            lastProgressBytes = downloadedBytes;
            lastProgressTime = now;
          }
        }

        await sink.flush();
      } finally {
        await sink.close();
      }

      stopwatch.stop();

      // Validate size if expected
      if (expectedSize != null && downloadedBytes != expectedSize) {
        await tempFile.delete();
        throw DownloadException(
          url,
          message: 'Size mismatch: expected $expectedSize, got $downloadedBytes',
          bytesDownloaded: downloadedBytes,
          totalBytes: expectedSize,
        );
      }

      // Validate checksum if provided
      if (expectedSha256 != null) {
        final actualHash = await _computeSha256(tempFile);
        if (actualHash != expectedSha256.toLowerCase()) {
          await tempFile.delete();
          throw DownloadException(
            url,
            message: 'Checksum mismatch: expected $expectedSha256, got $actualHash',
          );
        }
        _logger.info('Checksum verified');
      }

      // Rename temp file to final destination
      await tempFile.rename(destinationPath);

      final result = DownloadResult(
        filePath: destinationPath,
        sizeBytes: downloadedBytes,
        duration: stopwatch.elapsed,
      );

      _logger.info(
        'Download complete: ${result.sizeBytes ~/ (1024 * 1024)} MB in '
        '${result.duration.inSeconds}s '
        '(${(result.averageBytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s)',
      );

      return result;
    } on SocketException catch (e) {
      throw ConnectionException(
        'Connection failed: ${e.message}',
        host: e.address?.host,
        cause: e,
      );
    } on HttpException catch (e) {
      throw DownloadException(
        url,
        message: 'HTTP error: ${e.message}',
        cause: e,
      );
    }
  }

  /// Checks if a URL is reachable and gets the content length.
  ///
  /// Returns the content length in bytes, or null if unknown.
  Future<int?> getContentLength(String url) async {
    try {
      final uri = Uri.parse(url);
      final request = await _client.headUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        return response.contentLength > 0 ? response.contentLength : null;
      }

      return null;
    } catch (e) {
      _logger.warning('Failed to get content length: $url', e);
      return null;
    }
  }

  /// Cancels any ongoing downloads and closes connections.
  void close() {
    _client.close(force: true);
  }

  /// Computes SHA-256 hash of a file.
  Future<String> _computeSha256(File file) async {
    _logger.debug('Computing SHA-256 hash');

    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);

    return digest.toString();
  }
}
