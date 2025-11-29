import 'package:dartllm/src/models/chat_completion.dart';
import 'package:dartllm/src/models/chat_message.dart';
import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/usage_stats.dart';
import 'package:test/test.dart';

void main() {
  group('ChatCompletion', () {
    test('stores all completion data', () {
      const message = AssistantMessage('Hello, how can I help you?');
      const usage = UsageStats(promptTokens: 10, completionTokens: 8);
      final completion = ChatCompletion(
        message: message,
        usage: usage,
        finishReason: FinishReason.stop,
        generationTimeMs: 500,
      );

      expect(completion.message, equals(message));
      expect(completion.usage, equals(usage));
      expect(completion.finishReason, equals(FinishReason.stop));
      expect(completion.generationTimeMs, equals(500));
    });

    group('tokensPerSecond', () {
      test('calculates tokens per second correctly', () {
        const message = AssistantMessage('Response');
        const usage = UsageStats(promptTokens: 10, completionTokens: 100);
        final completion = ChatCompletion(
          message: message,
          usage: usage,
          finishReason: FinishReason.stop,
          generationTimeMs: 2000,
        );

        expect(completion.tokensPerSecond, equals(50.0));
      });

      test('returns zero when generation time is zero', () {
        const message = AssistantMessage('Response');
        const usage = UsageStats(promptTokens: 10, completionTokens: 100);
        final completion = ChatCompletion(
          message: message,
          usage: usage,
          finishReason: FinishReason.stop,
          generationTimeMs: 0,
        );

        expect(completion.tokensPerSecond, equals(0.0));
      });
    });

    group('equality', () {
      test('completions with same values are equal', () {
        const message = AssistantMessage('Hello');
        const usage = UsageStats(promptTokens: 10, completionTokens: 5);
        final completion1 = ChatCompletion(
          message: message,
          usage: usage,
          finishReason: FinishReason.stop,
          generationTimeMs: 100,
        );
        final completion2 = ChatCompletion(
          message: message,
          usage: usage,
          finishReason: FinishReason.stop,
          generationTimeMs: 100,
        );

        expect(completion1, equals(completion2));
      });
    });
  });

  group('ChatCompletionChunk', () {
    test('stores chunk data', () {
      const delta = MessageDelta(content: 'Hello');
      const chunk = ChatCompletionChunk(delta: delta);

      expect(chunk.delta, equals(delta));
      expect(chunk.finishReason, isNull);
    });

    test('stores finish reason for final chunk', () {
      const delta = MessageDelta(content: '');
      const chunk = ChatCompletionChunk(
        delta: delta,
        finishReason: FinishReason.stop,
      );

      expect(chunk.finishReason, equals(FinishReason.stop));
    });

    group('isLast', () {
      test('returns false for non-final chunks', () {
        const delta = MessageDelta(content: 'Hello');
        const chunk = ChatCompletionChunk(delta: delta);

        expect(chunk.isLast, isFalse);
      });

      test('returns true for final chunk', () {
        const delta = MessageDelta(content: '');
        const chunk = ChatCompletionChunk(
          delta: delta,
          finishReason: FinishReason.stop,
        );

        expect(chunk.isLast, isTrue);
      });
    });

    group('equality', () {
      test('chunks with same values are equal', () {
        const delta = MessageDelta(content: 'Hello');
        const chunk1 = ChatCompletionChunk(delta: delta);
        const chunk2 = ChatCompletionChunk(delta: delta);

        expect(chunk1, equals(chunk2));
      });
    });
  });

  group('MessageDelta', () {
    test('stores delta content', () {
      const delta = MessageDelta(content: 'Hello world');

      expect(delta.content, equals('Hello world'));
      expect(delta.role, isNull);
    });

    test('stores role when provided', () {
      const delta = MessageDelta(
        content: 'Hello',
        role: MessageRole.assistant,
      );

      expect(delta.content, equals('Hello'));
      expect(delta.role, equals(MessageRole.assistant));
    });

    test('defaults content to empty string', () {
      const delta = MessageDelta();

      expect(delta.content, equals(''));
    });

    group('equality', () {
      test('deltas with same values are equal', () {
        const delta1 = MessageDelta(content: 'Hello');
        const delta2 = MessageDelta(content: 'Hello');

        expect(delta1, equals(delta2));
      });

      test('deltas with different values are not equal', () {
        const delta1 = MessageDelta(content: 'Hello');
        const delta2 = MessageDelta(content: 'World');

        expect(delta1, isNot(equals(delta2)));
      });
    });
  });
}
