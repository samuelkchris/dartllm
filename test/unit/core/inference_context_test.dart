import 'package:dartllm/src/core/inference_context.dart';
import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/model_info.dart';
import 'package:test/test.dart';

void main() {
  group('InferenceContext', () {
    late InferenceContext context;

    final testModelInfo = const ModelInfo(
      name: 'test-model',
      parameterCount: 7000000000,
      architecture: 'llama',
      quantization: 'Q4_K_M',
      contextSize: 4096,
      vocabularySize: 32000,
      embeddingSize: 4096,
      layerCount: 32,
      headCount: 32,
      fileSizeBytes: 4000000000,
    );

    setUp(() {
      context = InferenceContext(
        modelInfo: testModelInfo,
        contextSize: 2048,
      );
    });

    tearDown(() {
      if (!context.isDisposed) {
        context.dispose();
      }
    });

    test('initializes with correct values', () {
      expect(context.contextSize, equals(2048));
      expect(context.tokenCount, equals(0));
      expect(context.remainingCapacity, equals(2048));
      expect(context.isFull, isFalse);
      expect(context.isDisposed, isFalse);
      expect(context.kvCacheType, equals(KVCacheType.f16));
    });

    test('stores model info', () {
      expect(context.modelInfo.name, equals('test-model'));
      expect(context.modelInfo.architecture, equals('llama'));
    });

    test('allows custom KV cache type', () {
      final q8Context = InferenceContext(
        modelInfo: testModelInfo,
        contextSize: 2048,
        kvCacheType: KVCacheType.q8_0,
      );

      expect(q8Context.kvCacheType, equals(KVCacheType.q8_0));
      q8Context.dispose();
    });

    group('addTokens', () {
      test('adds tokens to context', () {
        context.addTokens([1, 2, 3, 4, 5]);

        expect(context.tokenCount, equals(5));
        expect(context.tokens, equals([1, 2, 3, 4, 5]));
        expect(context.remainingCapacity, equals(2043));
      });

      test('adds multiple batches of tokens', () {
        context.addTokens([1, 2, 3]);
        context.addTokens([4, 5, 6]);

        expect(context.tokenCount, equals(6));
        expect(context.tokens, equals([1, 2, 3, 4, 5, 6]));
      });

      test('throws when exceeding capacity', () {
        context.addTokens(List.filled(2000, 1));

        expect(
          () => context.addTokens(List.filled(100, 1)),
          throwsArgumentError,
        );
      });

      test('throws when disposed', () {
        context.dispose();

        expect(
          () => context.addTokens([1, 2, 3]),
          throwsStateError,
        );
      });
    });

    group('clear', () {
      test('removes all tokens', () {
        context.addTokens([1, 2, 3, 4, 5]);
        context.clear();

        expect(context.tokenCount, equals(0));
        expect(context.tokens, isEmpty);
        expect(context.remainingCapacity, equals(2048));
      });

      test('throws when disposed', () {
        context.dispose();

        expect(() => context.clear(), throwsStateError);
      });
    });

    group('truncate', () {
      test('keeps specified number of tokens', () {
        context.addTokens([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
        context.truncate(5);

        expect(context.tokenCount, equals(5));
        expect(context.tokens, equals([6, 7, 8, 9, 10]));
      });

      test('does nothing when keepCount >= tokenCount', () {
        context.addTokens([1, 2, 3]);
        context.truncate(5);

        expect(context.tokenCount, equals(3));
        expect(context.tokens, equals([1, 2, 3]));
      });

      test('throws for negative keepCount', () {
        context.addTokens([1, 2, 3]);

        expect(() => context.truncate(-1), throwsArgumentError);
      });

      test('throws when disposed', () {
        context.dispose();

        expect(() => context.truncate(5), throwsStateError);
      });
    });

    group('isFull', () {
      test('returns false when not full', () {
        context.addTokens([1, 2, 3]);
        expect(context.isFull, isFalse);
      });

      test('returns true when full', () {
        context.addTokens(List.filled(2048, 1));
        expect(context.isFull, isTrue);
      });
    });

    group('tokens', () {
      test('returns unmodifiable list', () {
        context.addTokens([1, 2, 3]);
        final tokens = context.tokens;

        expect(() => (tokens as List).add(4), throwsUnsupportedError);
      });
    });

    group('estimateMemoryUsage', () {
      test('returns 0 for empty context', () {
        expect(context.estimateMemoryUsage(), equals(0));
      });

      test('estimates memory based on tokens and cache type', () {
        context.addTokens(List.filled(100, 1));

        // With f16: 2 * 32 * 4096 * 100 * 2 = 52,428,800
        final memoryF16 = context.estimateMemoryUsage();
        expect(memoryF16, greaterThan(0));
      });

      test('q8 cache uses less memory than f16', () {
        final contextF16 = InferenceContext(
          modelInfo: testModelInfo,
          contextSize: 2048,
          kvCacheType: KVCacheType.f16,
        );
        final contextQ8 = InferenceContext(
          modelInfo: testModelInfo,
          contextSize: 2048,
          kvCacheType: KVCacheType.q8_0,
        );

        contextF16.addTokens(List.filled(100, 1));
        contextQ8.addTokens(List.filled(100, 1));

        expect(contextQ8.estimateMemoryUsage(), lessThan(contextF16.estimateMemoryUsage()));

        contextF16.dispose();
        contextQ8.dispose();
      });
    });

    group('dispose', () {
      test('marks context as disposed', () {
        context.dispose();
        expect(context.isDisposed, isTrue);
      });

      test('clears tokens on dispose', () {
        context.addTokens([1, 2, 3]);
        context.dispose();

        // Can't check tokens after dispose, but we verify it doesn't throw
        expect(context.isDisposed, isTrue);
      });

      test('is idempotent', () {
        context.dispose();
        context.dispose();

        expect(context.isDisposed, isTrue);
      });
    });
  });
}
