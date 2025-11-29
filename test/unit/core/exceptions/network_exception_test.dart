import 'package:dartllm/src/core/exceptions/dartllm_exception.dart';
import 'package:dartllm/src/core/exceptions/network_exception.dart';
import 'package:test/test.dart';

void main() {
  group('NetworkException', () {
    test('extends DartLLMException', () {
      const exception = NetworkException('test error');
      expect(exception, isA<DartLLMException>());
    });

    test('toString returns formatted message', () {
      const exception = NetworkException('test error');
      expect(exception.toString(), equals('NetworkException: test error'));
    });
  });

  group('DownloadException', () {
    test('extends NetworkException', () {
      final exception = DownloadException('https://example.com/model.gguf');
      expect(exception, isA<NetworkException>());
    });

    test('stores url and download details', () {
      final exception = DownloadException(
        'https://example.com/model.gguf',
        statusCode: 404,
        bytesDownloaded: 1024 * 1024,
        totalBytes: 1024 * 1024 * 100,
      );
      expect(exception.url, equals('https://example.com/model.gguf'));
      expect(exception.statusCode, equals(404));
      expect(exception.bytesDownloaded, equals(1024 * 1024));
      expect(exception.totalBytes, equals(1024 * 1024 * 100));
    });

    test('calculates progress percentage', () {
      final exception = DownloadException(
        'https://example.com/model.gguf',
        bytesDownloaded: 50 * 1024 * 1024,
        totalBytes: 100 * 1024 * 1024,
      );
      expect(exception.progress, equals(0.5));
    });

    test('progress returns null when total is unknown', () {
      final exception = DownloadException(
        'https://example.com/model.gguf',
        bytesDownloaded: 50 * 1024 * 1024,
      );
      expect(exception.progress, isNull);
    });

    test('toString includes URL', () {
      final exception = DownloadException('https://example.com/model.gguf');
      expect(exception.toString(), contains('example.com'));
    });

    test('toString includes HTTP status code', () {
      final exception = DownloadException(
        'https://example.com/model.gguf',
        statusCode: 500,
      );
      expect(exception.toString(), contains('HTTP 500'));
    });

    test('toString includes download progress', () {
      final exception = DownloadException(
        'https://example.com/model.gguf',
        bytesDownloaded: 50 * 1024 * 1024,
        totalBytes: 100 * 1024 * 1024,
      );
      expect(exception.toString(), contains('50.0MB'));
      expect(exception.toString(), contains('100.0MB'));
    });
  });

  group('ConnectionException', () {
    test('extends NetworkException', () {
      const exception = ConnectionException('connection failed');
      expect(exception, isA<NetworkException>());
    });

    test('stores host and timeout details', () {
      const exception = ConnectionException(
        'connection failed',
        host: 'example.com',
        isTimeout: true,
        timeoutDuration: Duration(seconds: 30),
      );
      expect(exception.host, equals('example.com'));
      expect(exception.isTimeout, isTrue);
      expect(exception.timeoutDuration, equals(const Duration(seconds: 30)));
    });

    test('timeout factory creates timeout exception', () {
      final exception = ConnectionException.timeout(
        'example.com',
        duration: const Duration(seconds: 30),
      );
      expect(exception.isTimeout, isTrue);
      expect(exception.host, equals('example.com'));
      expect(exception.message, contains('timed out'));
      expect(exception.message, contains('30s'));
    });

    test('toString includes host', () {
      const exception = ConnectionException(
        'failed',
        host: 'example.com',
      );
      expect(exception.toString(), contains('example.com'));
    });
  });

  group('AuthenticationException', () {
    test('extends NetworkException', () {
      const exception = AuthenticationException('auth failed');
      expect(exception, isA<NetworkException>());
    });

    test('stores service and token status', () {
      const exception = AuthenticationException(
        'auth failed',
        service: 'HuggingFace',
        tokenMissing: true,
      );
      expect(exception.service, equals('HuggingFace'));
      expect(exception.tokenMissing, isTrue);
    });

    test('missingToken factory creates appropriate exception', () {
      final exception = AuthenticationException.missingToken('HuggingFace');
      expect(exception.service, equals('HuggingFace'));
      expect(exception.tokenMissing, isTrue);
      expect(exception.message, contains('no token'));
    });

    test('invalidToken factory creates appropriate exception', () {
      final exception = AuthenticationException.invalidToken('HuggingFace');
      expect(exception.service, equals('HuggingFace'));
      expect(exception.message, contains('invalid or expired'));
    });

    test('toString returns formatted message', () {
      const exception = AuthenticationException('auth failed');
      expect(
        exception.toString(),
        equals('AuthenticationException: auth failed'),
      );
    });
  });
}
