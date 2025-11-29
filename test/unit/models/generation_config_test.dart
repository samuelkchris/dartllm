import 'package:dartllm/src/models/generation_config.dart';
import 'package:test/test.dart';

void main() {
  group('GenerationConfig', () {
    group('default values', () {
      test('has sensible defaults', () {
        const config = GenerationConfig();

        expect(config.maxTokens, equals(1024));
        expect(config.temperature, equals(0.7));
        expect(config.topP, equals(0.9));
        expect(config.topK, equals(40));
        expect(config.minP, equals(0.05));
        expect(config.repetitionPenalty, equals(1.1));
        expect(config.frequencyPenalty, equals(0.0));
        expect(config.presencePenalty, equals(0.0));
        expect(config.repeatLastN, equals(64));
        expect(config.stopSequences, isEmpty);
        expect(config.seed, isNull);
        expect(config.grammar, isNull);
        expect(config.jsonSchema, isNull);
      });
    });

    group('custom values', () {
      test('accepts custom parameters', () {
        const config = GenerationConfig(
          maxTokens: 2048,
          temperature: 1.5,
          topP: 0.95,
          topK: 100,
          stopSequences: ['END', 'STOP'],
          seed: 42,
        );

        expect(config.maxTokens, equals(2048));
        expect(config.temperature, equals(1.5));
        expect(config.topP, equals(0.95));
        expect(config.topK, equals(100));
        expect(config.stopSequences, equals(['END', 'STOP']));
        expect(config.seed, equals(42));
      });
    });

    group('copyWith', () {
      test('creates modified copy', () {
        const original = GenerationConfig();
        final modified = original.copyWith(temperature: 1.2, maxTokens: 500);

        expect(modified.temperature, equals(1.2));
        expect(modified.maxTokens, equals(500));
        expect(modified.topP, equals(original.topP));
        expect(modified.topK, equals(original.topK));
      });
    });

    group('factory constructors', () {
      test('creative has higher temperature', () {
        final config = GenerationConfig.creative();

        expect(config.temperature, greaterThan(1.0));
        expect(config.topP, greaterThan(0.9));
      });

      test('precise has lower temperature', () {
        final config = GenerationConfig.precise();

        expect(config.temperature, lessThan(0.5));
        expect(config.topK, lessThan(40));
      });

      test('code has balanced settings', () {
        final config = GenerationConfig.code();

        expect(config.temperature, inInclusiveRange(0.3, 0.5));
        expect(config.stopSequences, isNotEmpty);
      });
    });

    group('equality', () {
      test('configs with same values are equal', () {
        const config1 = GenerationConfig(temperature: 0.8);
        const config2 = GenerationConfig(temperature: 0.8);

        expect(config1, equals(config2));
      });

      test('configs with different values are not equal', () {
        const config1 = GenerationConfig(temperature: 0.8);
        const config2 = GenerationConfig(temperature: 0.9);

        expect(config1, isNot(equals(config2)));
      });
    });
  });
}
