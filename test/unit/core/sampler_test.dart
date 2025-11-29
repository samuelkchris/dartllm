import 'package:dartllm/src/core/sampler.dart';
import 'package:dartllm/src/models/generation_config.dart';
import 'package:test/test.dart';

void main() {
  group('Sampler', () {
    group('greedy sampling (temperature = 0)', () {
      test('always selects highest probability token', () {
        final sampler = Sampler(
          config: const GenerationConfig(temperature: 0.0),
          seed: 42,
        );

        final logits = {
          1: 1.0,
          2: 2.0,
          3: 3.0, // Highest
          4: 0.5,
        };

        // Should always return 3 (highest logit)
        for (var i = 0; i < 10; i++) {
          final token = sampler.sample(Map.from(logits));
          expect(token, equals(3));
        }
      });
    });

    group('temperature', () {
      test('temperature 1.0 preserves distribution', () {
        final sampler = Sampler(
          config: const GenerationConfig(
            temperature: 1.0,
            topK: 0, // Disable top-k
            topP: 1.0, // Disable top-p
            minP: 0.0, // Disable min-p
          ),
          seed: 42,
        );

        final logits = {1: 1.0, 2: 1.0, 3: 1.0};
        final counts = <int, int>{};

        // Sample many times to check distribution
        for (var i = 0; i < 1000; i++) {
          final token = sampler.sample(Map.from(logits));
          counts[token] = (counts[token] ?? 0) + 1;
        }

        // All tokens should be selected roughly equally
        for (final count in counts.values) {
          expect(count, greaterThan(200));
          expect(count, lessThan(500));
        }
      });

      test('low temperature focuses on high probability tokens', () {
        final sampler = Sampler(
          config: const GenerationConfig(
            temperature: 0.1,
            topK: 0,
            topP: 1.0,
            minP: 0.0,
          ),
          seed: 42,
        );

        final logits = {
          1: 0.5,
          2: 1.0,
          3: 2.0, // Should dominate
        };

        final counts = <int, int>{};
        for (var i = 0; i < 100; i++) {
          final token = sampler.sample(Map.from(logits));
          counts[token] = (counts[token] ?? 0) + 1;
        }

        // Token 3 should be selected most often
        expect(counts[3] ?? 0, greaterThan(counts[1] ?? 0));
        expect(counts[3] ?? 0, greaterThan(counts[2] ?? 0));
      });
    });

    group('top-k filtering', () {
      test('limits to k most probable tokens', () {
        final sampler = Sampler(
          config: const GenerationConfig(
            temperature: 1.0,
            topK: 2,
            topP: 1.0,
            minP: 0.0,
          ),
          seed: 42,
        );

        final logits = {
          1: 0.1,
          2: 0.5,
          3: 2.0, // Top 2
          4: 1.5, // Top 2
        };

        final selectedTokens = <int>{};
        for (var i = 0; i < 100; i++) {
          selectedTokens.add(sampler.sample(Map.from(logits)));
        }

        // Should only select tokens 3 and 4 (top-2)
        expect(selectedTokens, containsAll([3, 4]));
        expect(selectedTokens.contains(1), isFalse);
        expect(selectedTokens.contains(2), isFalse);
      });

      test('topK <= 0 disables filtering', () {
        final sampler = Sampler(
          config: const GenerationConfig(
            temperature: 1.0,
            topK: 0,
            topP: 1.0,
            minP: 0.0,
          ),
          seed: 42,
        );

        final logits = {1: 1.0, 2: 1.0, 3: 1.0, 4: 1.0};
        final selectedTokens = <int>{};

        for (var i = 0; i < 100; i++) {
          selectedTokens.add(sampler.sample(Map.from(logits)));
        }

        // All tokens should be selectable
        expect(selectedTokens.length, equals(4));
      });
    });

    group('top-p (nucleus) sampling', () {
      test('limits to tokens within cumulative probability', () {
        final sampler = Sampler(
          config: const GenerationConfig(
            temperature: 1.0,
            topK: 0,
            topP: 0.5, // Only top 50% of probability mass
            minP: 0.0,
          ),
          seed: 42,
        );

        // After softmax, token 4 will have ~73% probability
        final logits = {
          1: 0.0,
          2: 0.5,
          3: 1.0,
          4: 2.0, // Dominant
        };

        final selectedTokens = <int>{};
        for (var i = 0; i < 100; i++) {
          selectedTokens.add(sampler.sample(Map.from(logits)));
        }

        // Token 4 should be selected since it alone exceeds 50%
        expect(selectedTokens, contains(4));
      });

      test('topP >= 1.0 disables filtering', () {
        final sampler = Sampler(
          config: const GenerationConfig(
            temperature: 1.0,
            topK: 0,
            topP: 1.0,
            minP: 0.0,
          ),
          seed: 42,
        );

        final logits = {1: 1.0, 2: 1.0, 3: 1.0};
        final selectedTokens = <int>{};

        for (var i = 0; i < 100; i++) {
          selectedTokens.add(sampler.sample(Map.from(logits)));
        }

        expect(selectedTokens.length, equals(3));
      });
    });

    group('min-p filtering', () {
      test('removes tokens below threshold', () {
        final sampler = Sampler(
          config: const GenerationConfig(
            temperature: 1.0,
            topK: 0,
            topP: 1.0,
            minP: 0.5, // Remove tokens with prob < 50% of max prob
          ),
          seed: 42,
        );

        // Token 4 will have much higher probability than others
        final logits = {
          1: 0.0, // Very low
          2: 3.0, // High
          3: 3.5, // Higher
          4: 4.0, // Highest
        };

        final selectedTokens = <int>{};
        for (var i = 0; i < 100; i++) {
          selectedTokens.add(sampler.sample(Map.from(logits)));
        }

        // Token 1 should be excluded due to min-p
        expect(selectedTokens.contains(1), isFalse);
      });
    });

    group('repetition penalty', () {
      test('reduces probability of repeated tokens', () {
        final sampler = Sampler(
          config: const GenerationConfig(
            temperature: 1.0,
            topK: 0,
            topP: 1.0,
            minP: 0.0,
            repetitionPenalty: 2.0, // Strong penalty
            repeatLastN: 2000, // Large window to keep token 1 in history
          ),
          seed: 42,
        );

        final logits = {1: 2.0, 2: 2.0, 3: 2.0};

        // First, sample token 1 many times to add it to history
        for (var i = 0; i < 100; i++) {
          sampler.sample({1: 10.0, 2: 0.0, 3: 0.0}); // Force token 1
        }

        // Now sample with equal logits - token 1 should be penalized
        final counts = <int, int>{};
        for (var i = 0; i < 300; i++) {
          final token = sampler.sample(Map.from(logits));
          counts[token] = (counts[token] ?? 0) + 1;
        }

        // Token 1 should be selected significantly less often due to penalty
        // With repetition penalty of 2.0, token 1's effective logit is ~1.0
        // while tokens 2 and 3 remain at 2.0 (initially)
        final token1Count = counts[1] ?? 0;
        final token2Count = counts[2] ?? 0;
        final token3Count = counts[3] ?? 0;

        // Token 1 is heavily penalized (100 times in history), should be rare
        // In the first few samples, tokens 2 and 3 should dominate
        expect(token1Count, lessThan(token2Count + token3Count));
      });
    });

    group('reset', () {
      test('clears token history', () {
        final sampler = Sampler(
          config: const GenerationConfig(
            temperature: 1.0,
            repetitionPenalty: 2.0,
          ),
          seed: 42,
        );

        // Build up history
        for (var i = 0; i < 10; i++) {
          sampler.sample({1: 10.0, 2: 0.0, 3: 0.0});
        }

        sampler.reset();

        // After reset, token 1 should not be penalized
        final logits = {1: 2.0, 2: 2.0, 3: 2.0};
        final counts = <int, int>{};

        for (var i = 0; i < 300; i++) {
          final token = sampler.sample(Map.from(logits));
          counts[token] = (counts[token] ?? 0) + 1;
        }

        // All tokens should be roughly equal
        for (final count in counts.values) {
          expect(count, greaterThan(50));
        }
      });
    });

    group('seed reproducibility', () {
      test('same seed produces same sequence', () {
        final config = const GenerationConfig(temperature: 1.0);
        final logits = {1: 1.0, 2: 1.5, 3: 2.0, 4: 1.2};

        final sampler1 = Sampler(config: config, seed: 12345);
        final sampler2 = Sampler(config: config, seed: 12345);

        final sequence1 = <int>[];
        final sequence2 = <int>[];

        for (var i = 0; i < 20; i++) {
          sequence1.add(sampler1.sample(Map.from(logits)));
          sequence2.add(sampler2.sample(Map.from(logits)));
        }

        expect(sequence1, equals(sequence2));
      });

      test('different seeds produce different sequences', () {
        final config = const GenerationConfig(temperature: 1.0);
        final logits = {1: 1.0, 2: 1.5, 3: 2.0, 4: 1.2};

        final sampler1 = Sampler(config: config, seed: 12345);
        final sampler2 = Sampler(config: config, seed: 54321);

        final sequence1 = <int>[];
        final sequence2 = <int>[];

        for (var i = 0; i < 20; i++) {
          sequence1.add(sampler1.sample(Map.from(logits)));
          sequence2.add(sampler2.sample(Map.from(logits)));
        }

        // Very unlikely to be equal
        expect(sequence1, isNot(equals(sequence2)));
      });
    });

    group('edge cases', () {
      test('throws on empty logits', () {
        final sampler = Sampler(
          config: const GenerationConfig(),
          seed: 42,
        );

        expect(() => sampler.sample({}), throwsArgumentError);
      });

      test('handles single token', () {
        final sampler = Sampler(
          config: const GenerationConfig(),
          seed: 42,
        );

        final token = sampler.sample({42: 1.0});
        expect(token, equals(42));
      });

      test('handles negative logits', () {
        final sampler = Sampler(
          config: const GenerationConfig(temperature: 0.0),
          seed: 42,
        );

        final token = sampler.sample({1: -1.0, 2: -0.5, 3: -2.0});
        expect(token, equals(2)); // Highest (least negative)
      });
    });
  });

  group('TokenProbability', () {
    test('stores token probability and logit', () {
      const prob = TokenProbability(
        token: 42,
        probability: 0.25,
        logit: 1.5,
      );

      expect(prob.token, equals(42));
      expect(prob.probability, equals(0.25));
      expect(prob.logit, equals(1.5));
    });

    test('toString returns readable format', () {
      const prob = TokenProbability(
        token: 42,
        probability: 0.25,
        logit: 1.5,
      );

      expect(prob.toString(), contains('42'));
      expect(prob.toString(), contains('0.25'));
    });
  });
}
