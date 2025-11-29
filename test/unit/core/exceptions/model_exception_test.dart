import 'package:dartllm/src/core/exceptions/dartllm_exception.dart';
import 'package:dartllm/src/core/exceptions/model_exception.dart';
import 'package:test/test.dart';

void main() {
  group('ModelException', () {
    test('extends DartLLMException', () {
      const exception = ModelException('test error');
      expect(exception, isA<DartLLMException>());
    });

    test('toString returns formatted message', () {
      const exception = ModelException('test error');
      expect(exception.toString(), equals('ModelException: test error'));
    });

    test('toString includes cause when provided', () {
      final cause = Exception('cause');
      final exception = ModelException('test error', cause: cause);
      expect(
        exception.toString(),
        equals('ModelException: test error (caused by: $cause)'),
      );
    });
  });

  group('ModelNotFoundException', () {
    test('extends ModelException', () {
      const exception = ModelNotFoundException('/path/to/model.gguf');
      expect(exception, isA<ModelException>());
    });

    test('stores the path', () {
      const exception = ModelNotFoundException('/path/to/model.gguf');
      expect(exception.path, equals('/path/to/model.gguf'));
    });

    test('message includes path', () {
      const exception = ModelNotFoundException('/path/to/model.gguf');
      expect(exception.message, contains('/path/to/model.gguf'));
    });

    test('toString returns formatted message', () {
      const exception = ModelNotFoundException('/path/to/model.gguf');
      expect(
        exception.toString(),
        equals(
            'ModelNotFoundException: Model not found at "/path/to/model.gguf"'),
      );
    });

    test('toString includes cause when provided', () {
      final cause = Exception('file not found');
      const path = '/path/to/model.gguf';
      final exception = ModelNotFoundException(path, cause: cause);
      expect(
        exception.toString(),
        contains('caused by:'),
      );
    });
  });

  group('InvalidModelException', () {
    test('extends ModelException', () {
      const exception = InvalidModelException('/path/to/model.gguf');
      expect(exception, isA<ModelException>());
    });

    test('stores path and details', () {
      const exception = InvalidModelException(
        '/path/to/model.gguf',
        details: 'not a GGUF file',
      );
      expect(exception.path, equals('/path/to/model.gguf'));
      expect(exception.details, equals('not a GGUF file'));
    });

    test('toString without details', () {
      const exception = InvalidModelException('/path/to/model.gguf');
      expect(
        exception.toString(),
        equals('InvalidModelException: Invalid model at "/path/to/model.gguf"'),
      );
    });

    test('toString with details', () {
      const exception = InvalidModelException(
        '/path/to/model.gguf',
        details: 'not a GGUF file',
      );
      expect(
        exception.toString(),
        contains('not a GGUF file'),
      );
    });
  });

  group('ModelVersionException', () {
    test('extends ModelException', () {
      const exception = ModelVersionException(
        foundVersion: 4,
        minVersion: 1,
        maxVersion: 3,
      );
      expect(exception, isA<ModelException>());
    });

    test('stores version information', () {
      const exception = ModelVersionException(
        foundVersion: 4,
        minVersion: 1,
        maxVersion: 3,
      );
      expect(exception.foundVersion, equals(4));
      expect(exception.minVersion, equals(1));
      expect(exception.maxVersion, equals(3));
    });

    test('message includes version details', () {
      const exception = ModelVersionException(
        foundVersion: 4,
        minVersion: 1,
        maxVersion: 3,
      );
      expect(exception.message, contains('4'));
      expect(exception.message, contains('1'));
      expect(exception.message, contains('3'));
    });

    test('toString returns formatted message', () {
      const exception = ModelVersionException(
        foundVersion: 4,
        minVersion: 1,
        maxVersion: 3,
      );
      expect(
        exception.toString(),
        contains('version 4 is not supported'),
      );
    });
  });

  group('ModelCorruptedException', () {
    test('extends ModelException', () {
      const exception = ModelCorruptedException('/path/to/model.gguf');
      expect(exception, isA<ModelException>());
    });

    test('stores path and checksum information', () {
      const exception = ModelCorruptedException(
        '/path/to/model.gguf',
        expectedChecksum: 'abc123',
        actualChecksum: 'def456',
      );
      expect(exception.path, equals('/path/to/model.gguf'));
      expect(exception.expectedChecksum, equals('abc123'));
      expect(exception.actualChecksum, equals('def456'));
    });

    test('toString without checksum', () {
      const exception = ModelCorruptedException('/path/to/model.gguf');
      expect(
        exception.toString(),
        contains('corrupted'),
      );
    });

    test('toString with checksum mismatch', () {
      const exception = ModelCorruptedException(
        '/path/to/model.gguf',
        expectedChecksum: 'abc123',
        actualChecksum: 'def456',
      );
      expect(exception.toString(), contains('abc123'));
      expect(exception.toString(), contains('def456'));
    });
  });
}
