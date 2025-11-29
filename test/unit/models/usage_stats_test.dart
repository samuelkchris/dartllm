import 'package:dartllm/src/models/usage_stats.dart';
import 'package:test/test.dart';

void main() {
  group('UsageStats', () {
    test('stores prompt and completion tokens', () {
      const stats = UsageStats(
        promptTokens: 100,
        completionTokens: 50,
      );

      expect(stats.promptTokens, equals(100));
      expect(stats.completionTokens, equals(50));
    });

    test('calculates total tokens', () {
      const stats = UsageStats(
        promptTokens: 100,
        completionTokens: 50,
      );

      expect(stats.totalTokens, equals(150));
    });

    test('handles zero tokens', () {
      const stats = UsageStats(
        promptTokens: 0,
        completionTokens: 0,
      );

      expect(stats.totalTokens, equals(0));
    });

    group('equality', () {
      test('stats with same values are equal', () {
        const stats1 = UsageStats(promptTokens: 100, completionTokens: 50);
        const stats2 = UsageStats(promptTokens: 100, completionTokens: 50);

        expect(stats1, equals(stats2));
      });

      test('stats with different values are not equal', () {
        const stats1 = UsageStats(promptTokens: 100, completionTokens: 50);
        const stats2 = UsageStats(promptTokens: 100, completionTokens: 60);

        expect(stats1, isNot(equals(stats2)));
      });
    });
  });
}
