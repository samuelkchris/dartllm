import 'dart:io';

import 'package:dartllm/src/core/model_downloader.dart';
import 'package:test/test.dart';

void main() {
  group('DownloadProgress', () {
    test('progress returns fraction when totalBytes is known', () {
      const progress = DownloadProgress(
        downloadedBytes: 50,
        totalBytes: 100,
        bytesPerSecond: 10,
      );

      expect(progress.progress, equals(0.5));
    });

    test('progress returns null when totalBytes is unknown', () {
      const progress = DownloadProgress(
        downloadedBytes: 50,
        totalBytes: null,
        bytesPerSecond: 10,
      );

      expect(progress.progress, isNull);
    });

    test('progress returns null when totalBytes is zero', () {
      const progress = DownloadProgress(
        downloadedBytes: 0,
        totalBytes: 0,
        bytesPerSecond: 0,
      );

      expect(progress.progress, isNull);
    });

    test('estimatedSecondsRemaining calculates correctly', () {
      const progress = DownloadProgress(
        downloadedBytes: 50,
        totalBytes: 100,
        bytesPerSecond: 10,
      );

      expect(progress.estimatedSecondsRemaining, equals(5.0));
    });

    test('estimatedSecondsRemaining returns null when totalBytes unknown', () {
      const progress = DownloadProgress(
        downloadedBytes: 50,
        totalBytes: null,
        bytesPerSecond: 10,
      );

      expect(progress.estimatedSecondsRemaining, isNull);
    });

    test('estimatedSecondsRemaining returns null when speed is zero', () {
      const progress = DownloadProgress(
        downloadedBytes: 50,
        totalBytes: 100,
        bytesPerSecond: 0,
      );

      expect(progress.estimatedSecondsRemaining, isNull);
    });

    test('downloadedMB converts bytes to megabytes', () {
      const progress = DownloadProgress(
        downloadedBytes: 10 * 1024 * 1024,
        totalBytes: null,
        bytesPerSecond: 0,
      );

      expect(progress.downloadedMB, equals(10.0));
    });

    test('totalMB returns null when totalBytes is unknown', () {
      const progress = DownloadProgress(
        downloadedBytes: 0,
        totalBytes: null,
        bytesPerSecond: 0,
      );

      expect(progress.totalMB, isNull);
    });

    test('totalMB converts bytes to megabytes when known', () {
      const progress = DownloadProgress(
        downloadedBytes: 0,
        totalBytes: 100 * 1024 * 1024,
        bytesPerSecond: 0,
      );

      expect(progress.totalMB, equals(100.0));
    });
  });

  group('DownloadResult', () {
    test('averageBytesPerSecond calculates correctly', () {
      const result = DownloadResult(
        filePath: '/path/to/file',
        sizeBytes: 1000,
        duration: Duration(seconds: 10),
      );

      expect(result.averageBytesPerSecond, equals(100.0));
    });

    test('averageBytesPerSecond returns 0 for zero duration', () {
      const result = DownloadResult(
        filePath: '/path/to/file',
        sizeBytes: 1000,
        duration: Duration.zero,
      );

      expect(result.averageBytesPerSecond, equals(0.0));
    });
  });

  group('ModelDownloader', () {
    late ModelDownloader downloader;
    late Directory tempDir;

    setUp(() async {
      downloader = ModelDownloader();
      tempDir = await Directory.systemTemp.createTemp('dartllm_download_test_');
    });

    tearDown(() async {
      downloader.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('creates downloader with default timeouts', () {
      expect(downloader, isNotNull);
    });

    test('creates downloader with custom timeouts', () {
      final customDownloader = ModelDownloader(
        connectTimeout: const Duration(seconds: 60),
        idleTimeout: const Duration(seconds: 120),
      );

      expect(customDownloader, isNotNull);
      customDownloader.close();
    });

    test('close can be called multiple times safely', () {
      downloader.close();
      downloader.close();

      expect(true, isTrue);
    });

    group('getContentLength', () {
      test('returns null for invalid URL', () async {
        final length = await downloader.getContentLength('not-a-valid-url');

        expect(length, isNull);
      });

      test('returns null for unreachable host', () async {
        final length = await downloader.getContentLength(
          'https://this-host-does-not-exist-12345.example.com/file',
        );

        expect(length, isNull);
      });
    });
  });
}
