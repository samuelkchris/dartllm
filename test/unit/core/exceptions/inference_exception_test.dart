import 'package:dartllm/src/core/exceptions/dartllm_exception.dart';
import 'package:dartllm/src/core/exceptions/inference_exception.dart';
import 'package:test/test.dart';

void main() {
  group('InferenceException', () {
    test('extends DartLLMException', () {
      const exception = InferenceException('test error');
      expect(exception, isA<DartLLMException>());
    });

    test('toString returns formatted message', () {
      const exception = InferenceException('test error');
      expect(exception.toString(), equals('InferenceException: test error'));
    });
  });

  group('GenerationException', () {
    test('extends InferenceException', () {
      const exception = GenerationException('generation failed');
      expect(exception, isA<InferenceException>());
    });

    test('stores tokens generated count', () {
      const exception = GenerationException(
        'generation failed',
        tokensGenerated: 150,
      );
      expect(exception.tokensGenerated, equals(150));
    });

    test('toString without tokens count', () {
      const exception = GenerationException('generation failed');
      expect(
        exception.toString(),
        equals('GenerationException: generation failed'),
      );
    });

    test('toString with tokens count', () {
      const exception = GenerationException(
        'generation failed',
        tokensGenerated: 150,
      );
      expect(exception.toString(), contains('150 tokens'));
    });

    test('toString includes cause when provided', () {
      final cause = Exception('native error');
      final exception = GenerationException(
        'generation failed',
        cause: cause,
      );
      expect(exception.toString(), contains('caused by'));
    });
  });

  group('TokenizationException', () {
    test('extends InferenceException', () {
      const exception = TokenizationException('tokenization failed');
      expect(exception, isA<InferenceException>());
    });

    test('stores input text and failure position', () {
      const exception = TokenizationException(
        'invalid character',
        inputText: 'hello world',
        failurePosition: 5,
      );
      expect(exception.inputText, equals('hello world'));
      expect(exception.failurePosition, equals(5));
    });

    test('toString without details', () {
      const exception = TokenizationException('tokenization failed');
      expect(
        exception.toString(),
        equals('TokenizationException: tokenization failed'),
      );
    });

    test('toString with position', () {
      const exception = TokenizationException(
        'invalid character',
        failurePosition: 10,
      );
      expect(exception.toString(), contains('position 10'));
    });

    test('toString truncates long input text', () {
      final longText = 'a' * 100;
      final exception = TokenizationException(
        'tokenization failed',
        inputText: longText,
      );
      expect(exception.toString(), contains('...'));
    });

    test('toString does not truncate short input text', () {
      const exception = TokenizationException(
        'tokenization failed',
        inputText: 'short',
      );
      expect(exception.toString(), contains('"short"'));
      expect(exception.toString(), isNot(contains('...')));
    });
  });

  group('SamplingException', () {
    test('extends InferenceException', () {
      const exception = SamplingException('sampling failed');
      expect(exception, isA<InferenceException>());
    });

    test('stores parameter details', () {
      const exception = SamplingException(
        'invalid parameter',
        parameterName: 'temperature',
        parameterValue: -0.5,
      );
      expect(exception.parameterName, equals('temperature'));
      expect(exception.parameterValue, equals(-0.5));
    });

    test('toString without parameter details', () {
      const exception = SamplingException('sampling failed');
      expect(
        exception.toString(),
        equals('SamplingException: sampling failed'),
      );
    });

    test('toString with parameter details', () {
      const exception = SamplingException(
        'invalid parameter',
        parameterName: 'temperature',
        parameterValue: -0.5,
      );
      expect(exception.toString(), contains('temperature=-0.5'));
    });
  });
}
