import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/model_config.dart';
import 'package:test/test.dart';

void main() {
  group('ModelConfig', () {
    group('default values', () {
      test('has sensible defaults', () {
        const config = ModelConfig();

        expect(config.contextSize, isNull);
        expect(config.gpuLayers, equals(-1));
        expect(config.threads, equals(0));
        expect(config.batchSize, equals(512));
        expect(config.ropeFrequencyBase, isNull);
        expect(config.ropeFrequencyScale, isNull);
        expect(config.useMemoryMap, isTrue);
        expect(config.lockMemory, isFalse);
        expect(config.kvCacheType, equals(KVCacheType.f16));
        expect(config.cacheDirectory, isNull);
      });
    });

    group('custom values', () {
      test('accepts custom parameters', () {
        const config = ModelConfig(
          contextSize: 4096,
          gpuLayers: 32,
          threads: 8,
          batchSize: 1024,
          useMemoryMap: false,
          kvCacheType: KVCacheType.q8_0,
        );

        expect(config.contextSize, equals(4096));
        expect(config.gpuLayers, equals(32));
        expect(config.threads, equals(8));
        expect(config.batchSize, equals(1024));
        expect(config.useMemoryMap, isFalse);
        expect(config.kvCacheType, equals(KVCacheType.q8_0));
      });
    });

    group('copyWith', () {
      test('creates modified copy', () {
        const original = ModelConfig();
        final modified = original.copyWith(
          contextSize: 8192,
          gpuLayers: 0,
        );

        expect(modified.contextSize, equals(8192));
        expect(modified.gpuLayers, equals(0));
        expect(modified.useMemoryMap, equals(original.useMemoryMap));
      });
    });

    group('factory constructors', () {
      test('lowMemory optimizes for memory usage', () {
        final config = ModelConfig.lowMemory();

        expect(config.gpuLayers, equals(0));
        expect(config.kvCacheType, equals(KVCacheType.q4_0));
        expect(config.useMemoryMap, isTrue);
      });

      test('performance optimizes for speed', () {
        final config = ModelConfig.performance();

        expect(config.gpuLayers, equals(-1));
        expect(config.kvCacheType, equals(KVCacheType.f16));
        expect(config.lockMemory, isTrue);
      });
    });

    group('equality', () {
      test('configs with same values are equal', () {
        const config1 = ModelConfig(contextSize: 4096);
        const config2 = ModelConfig(contextSize: 4096);

        expect(config1, equals(config2));
      });
    });
  });
}
