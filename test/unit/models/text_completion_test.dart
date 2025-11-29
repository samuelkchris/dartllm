import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/text_completion.dart';
import 'package:dartllm/src/models/usage_stats.dart';
import 'package:test/test.dart';

void main() {
  group('TextCompletion', () {
    test('stores all completion data', () {
      const usage = UsageStats(promptTokens: 5, completionTokens: 20);
      final completion = TextCompletion(
        text: 'there was a magical kingdom',
        usage: usage,
        finishReason: FinishReason.stop,
        generationTimeMs: 400,
      );

      expect(completion.text, equals('there was a magical kingdom'));
      expect(completion.usage, equals(usage));
      expect(completion.finishReason, equals(FinishReason.stop));
      expect(completion.generationTimeMs, equals(400));
    });

    group('tokensPerSecond', () {
      test('calculates tokens per second correctly', () {
        const usage = UsageStats(promptTokens: 5, completionTokens: 50);
        final completion = TextCompletion(
          text: 'Generated text',
          usage: usage,
          finishReason: FinishReason.stop,
          generationTimeMs: 1000,
        );

        expect(completion.tokensPerSecond, equals(50.0));
      });

      test('handles fast generation', () {
        const usage = UsageStats(promptTokens: 5, completionTokens: 200);
        final completion = TextCompletion(
          text: 'Fast generated text',
          usage: usage,
          finishReason: FinishReason.stop,
          generationTimeMs: 500,
        );

        expect(completion.tokensPerSecond, equals(400.0));
      });

      test('returns zero when generation time is zero', () {
        const usage = UsageStats(promptTokens: 5, completionTokens: 100);
        final completion = TextCompletion(
          text: 'Text',
          usage: usage,
          finishReason: FinishReason.stop,
          generationTimeMs: 0,
        );

        expect(completion.tokensPerSecond, equals(0.0));
      });
    });

    group('finish reasons', () {
      test('handles stop finish reason', () {
        const usage = UsageStats(promptTokens: 5, completionTokens: 10);
        final completion = TextCompletion(
          text: 'Complete text.',
          usage: usage,
          finishReason: FinishReason.stop,
          generationTimeMs: 100,
        );

        expect(completion.finishReason, equals(FinishReason.stop));
      });

      test('handles length finish reason', () {
        const usage = UsageStats(promptTokens: 5, completionTokens: 1024);
        final completion = TextCompletion(
          text: 'Truncated text...',
          usage: usage,
          finishReason: FinishReason.length,
          generationTimeMs: 2000,
        );

        expect(completion.finishReason, equals(FinishReason.length));
      });

      test('handles error finish reason', () {
        const usage = UsageStats(promptTokens: 5, completionTokens: 3);
        final completion = TextCompletion(
          text: 'Partial',
          usage: usage,
          finishReason: FinishReason.error,
          generationTimeMs: 50,
        );

        expect(completion.finishReason, equals(FinishReason.error));
      });
    });

    group('equality', () {
      test('completions with same values are equal', () {
        const usage = UsageStats(promptTokens: 5, completionTokens: 10);
        final completion1 = TextCompletion(
          text: 'Hello',
          usage: usage,
          finishReason: FinishReason.stop,
          generationTimeMs: 100,
        );
        final completion2 = TextCompletion(
          text: 'Hello',
          usage: usage,
          finishReason: FinishReason.stop,
          generationTimeMs: 100,
        );

        expect(completion1, equals(completion2));
      });

      test('completions with different text are not equal', () {
        const usage = UsageStats(promptTokens: 5, completionTokens: 10);
        final completion1 = TextCompletion(
          text: 'Hello',
          usage: usage,
          finishReason: FinishReason.stop,
          generationTimeMs: 100,
        );
        final completion2 = TextCompletion(
          text: 'World',
          usage: usage,
          finishReason: FinishReason.stop,
          generationTimeMs: 100,
        );

        expect(completion1, isNot(equals(completion2)));
      });
    });
  });

  group('TextCompletionChunk', () {
    test('stores chunk text', () {
      const chunk = TextCompletionChunk(text: 'Hello');

      expect(chunk.text, equals('Hello'));
      expect(chunk.finishReason, isNull);
    });

    test('stores finish reason for final chunk', () {
      const chunk = TextCompletionChunk(
        text: '',
        finishReason: FinishReason.stop,
      );

      expect(chunk.text, equals(''));
      expect(chunk.finishReason, equals(FinishReason.stop));
    });

    group('isLast', () {
      test('returns false for non-final chunks', () {
        const chunk = TextCompletionChunk(text: 'Hello');

        expect(chunk.isLast, isFalse);
      });

      test('returns true for final chunk with stop reason', () {
        const chunk = TextCompletionChunk(
          text: '',
          finishReason: FinishReason.stop,
        );

        expect(chunk.isLast, isTrue);
      });

      test('returns true for final chunk with length reason', () {
        const chunk = TextCompletionChunk(
          text: '...',
          finishReason: FinishReason.length,
        );

        expect(chunk.isLast, isTrue);
      });

      test('returns true for final chunk with error reason', () {
        const chunk = TextCompletionChunk(
          text: '',
          finishReason: FinishReason.error,
        );

        expect(chunk.isLast, isTrue);
      });
    });

    group('equality', () {
      test('chunks with same values are equal', () {
        const chunk1 = TextCompletionChunk(text: 'Hello');
        const chunk2 = TextCompletionChunk(text: 'Hello');

        expect(chunk1, equals(chunk2));
      });

      test('chunks with different text are not equal', () {
        const chunk1 = TextCompletionChunk(text: 'Hello');
        const chunk2 = TextCompletionChunk(text: 'World');

        expect(chunk1, isNot(equals(chunk2)));
      });

      test('chunks with different finish reasons are not equal', () {
        const chunk1 = TextCompletionChunk(
          text: '',
          finishReason: FinishReason.stop,
        );
        const chunk2 = TextCompletionChunk(
          text: '',
          finishReason: FinishReason.length,
        );

        expect(chunk1, isNot(equals(chunk2)));
      });
    });
  });
}
