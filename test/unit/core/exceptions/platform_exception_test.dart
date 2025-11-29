import 'package:dartllm/src/core/exceptions/dartllm_exception.dart';
import 'package:dartllm/src/core/exceptions/platform_exception.dart';
import 'package:test/test.dart';

void main() {
  group('LLMPlatformException', () {
    test('extends DartLLMException', () {
      const exception = LLMPlatformException('test error');
      expect(exception, isA<DartLLMException>());
    });

    test('toString returns formatted message', () {
      const exception = LLMPlatformException('test error');
      expect(exception.toString(), equals('LLMPlatformException: test error'));
    });
  });

  group('UnsupportedPlatformException', () {
    test('extends LLMPlatformException', () {
      final exception = UnsupportedPlatformException('Windows RT');
      expect(exception, isA<LLMPlatformException>());
    });

    test('stores platform information', () {
      final exception = UnsupportedPlatformException(
        'Android',
        platformVersion: '5.0',
        minimumVersion: '7.0',
      );
      expect(exception.platform, equals('Android'));
      expect(exception.platformVersion, equals('5.0'));
      expect(exception.minimumVersion, equals('7.0'));
    });

    test('message for unsupported platform', () {
      final exception = UnsupportedPlatformException('Windows RT');
      expect(exception.message, contains('Windows RT'));
      expect(exception.message, contains('not supported'));
    });

    test('message for version mismatch', () {
      final exception = UnsupportedPlatformException(
        'Android',
        platformVersion: '5.0',
        minimumVersion: '7.0',
      );
      expect(exception.message, contains('5.0'));
      expect(exception.message, contains('7.0'));
    });

    test('toString for unsupported platform', () {
      final exception = UnsupportedPlatformException('Windows RT');
      expect(exception.toString(), contains('Windows RT'));
      expect(exception.toString(), contains('not supported'));
    });

    test('toString for version mismatch', () {
      final exception = UnsupportedPlatformException(
        'iOS',
        platformVersion: '12.0',
        minimumVersion: '14.0',
      );
      expect(exception.toString(), contains('12.0'));
      expect(exception.toString(), contains('14.0'));
    });
  });

  group('GpuInitializationException', () {
    test('extends LLMPlatformException', () {
      const exception = GpuInitializationException('GPU init failed');
      expect(exception, isA<LLMPlatformException>());
    });

    test('stores backend and fallback information', () {
      const exception = GpuInitializationException(
        'Metal initialization failed',
        backend: 'Metal',
        willFallbackToCpu: true,
      );
      expect(exception.backend, equals('Metal'));
      expect(exception.willFallbackToCpu, isTrue);
    });

    test('default willFallbackToCpu is true', () {
      const exception = GpuInitializationException('GPU init failed');
      expect(exception.willFallbackToCpu, isTrue);
    });

    test('toString includes backend', () {
      const exception = GpuInitializationException(
        'init failed',
        backend: 'Vulkan',
      );
      expect(exception.toString(), contains('Vulkan'));
    });

    test('toString indicates fallback status', () {
      const exception = GpuInitializationException(
        'init failed',
        willFallbackToCpu: true,
      );
      expect(exception.toString(), contains('falling back to CPU'));
    });

    test('toString when not falling back', () {
      const exception = GpuInitializationException(
        'init failed',
        willFallbackToCpu: false,
      );
      expect(exception.toString(), isNot(contains('falling back')));
    });
  });

  group('PermissionException', () {
    test('extends LLMPlatformException', () {
      final exception = PermissionException('storage');
      expect(exception, isA<LLMPlatformException>());
    });

    test('stores permission type and resource', () {
      final exception = PermissionException(
        'file_read',
        resource: '/data/models/model.gguf',
      );
      expect(exception.permissionType, equals('file_read'));
      expect(exception.resource, equals('/data/models/model.gguf'));
    });

    test('message without resource', () {
      final exception = PermissionException('storage');
      expect(exception.message, contains('storage'));
      expect(exception.message, contains('required'));
    });

    test('message with resource', () {
      final exception = PermissionException(
        'file_read',
        resource: '/path/to/file',
      );
      expect(exception.message, contains('file_read'));
      expect(exception.message, contains('/path/to/file'));
    });

    test('toString includes permission type', () {
      final exception = PermissionException('network');
      expect(exception.toString(), contains('network'));
      expect(exception.toString(), contains('permission required'));
    });

    test('toString includes resource', () {
      final exception = PermissionException(
        'storage',
        resource: '/data/cache',
      );
      expect(exception.toString(), contains('/data/cache'));
    });
  });
}
