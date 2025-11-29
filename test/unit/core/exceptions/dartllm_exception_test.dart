import 'package:dartllm/src/core/exceptions/dartllm_exception.dart';
import 'package:test/test.dart';

void main() {
  group('DartLLMException', () {
    group('constructor', () {
      test('creates exception with message only', () {
        const exception = DartLLMException('test error');

        expect(exception.message, equals('test error'));
        expect(exception.cause, isNull);
      });

      test('creates exception with message and cause', () {
        final cause = Exception('original error');
        final exception = DartLLMException('test error', cause: cause);

        expect(exception.message, equals('test error'));
        expect(exception.cause, equals(cause));
      });
    });

    group('toString', () {
      test('returns formatted message without cause', () {
        const exception = DartLLMException('test error');

        expect(exception.toString(), equals('DartLLMException: test error'));
      });

      test('returns formatted message with cause', () {
        final cause = Exception('original error');
        final exception = DartLLMException('test error', cause: cause);

        expect(
          exception.toString(),
          equals('DartLLMException: test error (caused by: $cause)'),
        );
      });
    });

    group('implements Exception', () {
      test('can be caught as Exception', () {
        expect(
          () => throw const DartLLMException('test'),
          throwsA(isA<Exception>()),
        );
      });

      test('can be caught as DartLLMException', () {
        expect(
          () => throw const DartLLMException('test'),
          throwsA(isA<DartLLMException>()),
        );
      });
    });
  });
}
