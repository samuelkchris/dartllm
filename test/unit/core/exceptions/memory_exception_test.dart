import 'package:dartllm/src/core/exceptions/dartllm_exception.dart';
import 'package:dartllm/src/core/exceptions/memory_exception.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryException', () {
    test('extends DartLLMException', () {
      const exception = MemoryException('test error');
      expect(exception, isA<DartLLMException>());
    });

    test('toString returns formatted message', () {
      const exception = MemoryException('test error');
      expect(exception.toString(), equals('MemoryException: test error'));
    });
  });

  group('InsufficientMemoryException', () {
    test('extends MemoryException', () {
      final exception = InsufficientMemoryException();
      expect(exception, isA<MemoryException>());
    });

    test('creates generic message when no details provided', () {
      final exception = InsufficientMemoryException();
      expect(exception.message, contains('Insufficient memory'));
    });

    test('stores required and available bytes', () {
      final exception = InsufficientMemoryException(
        requiredBytes: 1024 * 1024 * 1024, // 1GB
        availableBytes: 512 * 1024 * 1024, // 512MB
      );
      expect(exception.requiredBytes, equals(1024 * 1024 * 1024));
      expect(exception.availableBytes, equals(512 * 1024 * 1024));
    });

    test('message includes MB values when bytes provided', () {
      final exception = InsufficientMemoryException(
        requiredBytes: 1024 * 1024 * 1024, // 1GB
        availableBytes: 512 * 1024 * 1024, // 512MB
      );
      expect(exception.message, contains('1024.0MB'));
      expect(exception.message, contains('512.0MB'));
    });

    test('toString formats memory values', () {
      final exception = InsufficientMemoryException(
        requiredBytes: 2048 * 1024 * 1024,
        availableBytes: 1024 * 1024 * 1024,
      );
      expect(exception.toString(), contains('2048.0MB'));
      expect(exception.toString(), contains('1024.0MB'));
    });
  });

  group('MemoryAllocationException', () {
    test('extends MemoryException', () {
      final exception = MemoryAllocationException();
      expect(exception, isA<MemoryException>());
    });

    test('stores allocation details', () {
      final exception = MemoryAllocationException(
        allocationSize: 100 * 1024 * 1024,
        allocationPurpose: 'KV cache',
      );
      expect(exception.allocationSize, equals(100 * 1024 * 1024));
      expect(exception.allocationPurpose, equals('KV cache'));
    });

    test('message includes purpose and size', () {
      final exception = MemoryAllocationException(
        allocationSize: 100 * 1024 * 1024,
        allocationPurpose: 'KV cache',
      );
      expect(exception.message, contains('KV cache'));
      expect(exception.message, contains('100.0MB'));
    });

    test('toString includes all details', () {
      final exception = MemoryAllocationException(
        allocationSize: 256 * 1024 * 1024,
        allocationPurpose: 'model weights',
      );
      expect(exception.toString(), contains('model weights'));
      expect(exception.toString(), contains('256.0MB'));
    });
  });

  group('ContextOverflowException', () {
    test('extends MemoryException', () {
      const exception = ContextOverflowException(
        contextSize: 4096,
        attemptedTokens: 5000,
      );
      expect(exception, isA<MemoryException>());
    });

    test('stores context size and attempted tokens', () {
      const exception = ContextOverflowException(
        contextSize: 4096,
        attemptedTokens: 5000,
      );
      expect(exception.contextSize, equals(4096));
      expect(exception.attemptedTokens, equals(5000));
    });

    test('calculates overflow amount', () {
      const exception = ContextOverflowException(
        contextSize: 4096,
        attemptedTokens: 5000,
      );
      expect(exception.overflowAmount, equals(904));
    });

    test('message includes token counts', () {
      const exception = ContextOverflowException(
        contextSize: 4096,
        attemptedTokens: 5000,
      );
      expect(exception.message, contains('5000'));
      expect(exception.message, contains('4096'));
    });

    test('toString includes overflow amount', () {
      const exception = ContextOverflowException(
        contextSize: 4096,
        attemptedTokens: 5000,
      );
      expect(exception.toString(), contains('904'));
    });
  });
}
