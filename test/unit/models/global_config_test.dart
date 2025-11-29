import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/global_config.dart';
import 'package:test/test.dart';

void main() {
  group('GlobalConfig', () {
    group('default values', () {
      test('has sensible defaults', () {
        const config = GlobalConfig();

        expect(config.defaultCacheDirectory, isNull);
        expect(config.defaultGpuLayers, equals(-1));
        expect(config.defaultThreadCount, equals(0));
        expect(config.enableLogging, isFalse);
        expect(config.logLevel, equals(LogLevel.warning));
        expect(config.huggingFaceToken, isNull);
      });
    });

    group('custom values', () {
      test('accepts custom parameters', () {
        const config = GlobalConfig(
          defaultCacheDirectory: '/custom/cache',
          defaultGpuLayers: 32,
          defaultThreadCount: 8,
          enableLogging: true,
          logLevel: LogLevel.debug,
          huggingFaceToken: 'hf_token_123',
        );

        expect(config.defaultCacheDirectory, equals('/custom/cache'));
        expect(config.defaultGpuLayers, equals(32));
        expect(config.defaultThreadCount, equals(8));
        expect(config.enableLogging, isTrue);
        expect(config.logLevel, equals(LogLevel.debug));
        expect(config.huggingFaceToken, equals('hf_token_123'));
      });
    });

    group('copyWith', () {
      test('creates modified copy', () {
        const original = GlobalConfig();
        final modified = original.copyWith(
          enableLogging: true,
          logLevel: LogLevel.info,
        );

        expect(modified.enableLogging, isTrue);
        expect(modified.logLevel, equals(LogLevel.info));
        expect(modified.defaultGpuLayers, equals(original.defaultGpuLayers));
        expect(
            modified.defaultThreadCount, equals(original.defaultThreadCount));
      });
    });

    group('factory constructors', () {
      test('debug enables verbose logging', () {
        final config = GlobalConfig.debug();

        expect(config.enableLogging, isTrue);
        expect(config.logLevel, equals(LogLevel.debug));
      });

      test('production has minimal logging', () {
        final config = GlobalConfig.production();

        expect(config.enableLogging, isTrue);
        expect(config.logLevel, equals(LogLevel.error));
      });
    });

    group('equality', () {
      test('configs with same values are equal', () {
        const config1 = GlobalConfig(enableLogging: true);
        const config2 = GlobalConfig(enableLogging: true);

        expect(config1, equals(config2));
      });

      test('configs with different values are not equal', () {
        const config1 = GlobalConfig(enableLogging: true);
        const config2 = GlobalConfig(enableLogging: false);

        expect(config1, isNot(equals(config2)));
      });
    });
  });
}
