import 'package:dartllm/src/utils/memory_utils.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryUtils', () {
    group('formatBytes', () {
      test('formats bytes correctly', () {
        expect(MemoryUtils.formatBytes(0), equals('0 B'));
        expect(MemoryUtils.formatBytes(500), equals('500 B'));
        expect(MemoryUtils.formatBytes(1023), equals('1023 B'));
      });

      test('formats kilobytes correctly', () {
        expect(MemoryUtils.formatBytes(1024), equals('1.0 KB'));
        expect(MemoryUtils.formatBytes(1536), equals('1.5 KB'));
        expect(MemoryUtils.formatBytes(10240), equals('10.0 KB'));
      });

      test('formats megabytes correctly', () {
        expect(MemoryUtils.formatBytes(1024 * 1024), equals('1.0 MB'));
        expect(MemoryUtils.formatBytes(150 * 1024 * 1024), equals('150.0 MB'));
        expect(MemoryUtils.formatBytes(512 * 1024 * 1024), equals('512.0 MB'));
      });

      test('formats gigabytes correctly', () {
        expect(MemoryUtils.formatBytes(1024 * 1024 * 1024), equals('1.0 GB'));
        expect(MemoryUtils.formatBytes(4200000000), equals('3.9 GB'));
        expect(
            MemoryUtils.formatBytes(8 * 1024 * 1024 * 1024), equals('8.0 GB'));
      });

      test('respects decimal places parameter', () {
        expect(MemoryUtils.formatBytes(1536, decimals: 0), equals('2 KB'));
        expect(MemoryUtils.formatBytes(1536, decimals: 2), equals('1.50 KB'));
        expect(MemoryUtils.formatBytes(1536, decimals: 3), equals('1.500 KB'));
      });

      test('throws for negative bytes', () {
        expect(
          () => MemoryUtils.formatBytes(-1),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('unit conversions', () {
      test('mbToBytes converts correctly', () {
        expect(MemoryUtils.mbToBytes(1), equals(1024 * 1024));
        expect(MemoryUtils.mbToBytes(512), equals(512 * 1024 * 1024));
      });

      test('gbToBytes converts correctly', () {
        expect(MemoryUtils.gbToBytes(1), equals(1024 * 1024 * 1024));
        expect(MemoryUtils.gbToBytes(4), equals(4 * 1024 * 1024 * 1024));
      });

      test('bytesToMB converts correctly', () {
        expect(MemoryUtils.bytesToMB(1024 * 1024), equals(1));
        expect(MemoryUtils.bytesToMB(512 * 1024 * 1024), equals(512));
        expect(
            MemoryUtils.bytesToMB(1024 * 1024 + 500), equals(1)); // Truncated
      });

      test('bytesToGB converts correctly', () {
        expect(MemoryUtils.bytesToGB(1024 * 1024 * 1024), equals(1));
        expect(MemoryUtils.bytesToGB(4 * 1024 * 1024 * 1024), equals(4));
      });
    });

    group('estimateModelWeightsBytes', () {
      test('calculates weight memory for 7B Q4 model', () {
        final bytes = MemoryUtils.estimateModelWeightsBytes(
          parameterCount: 7000000000,
          bitsPerWeight: 4.0,
        );

        // 7B * 4 bits / 8 = 3.5 GB
        expect(bytes, equals(3500000000));
      });

      test('calculates weight memory for 7B Q4_K_M model', () {
        final bytes = MemoryUtils.estimateModelWeightsBytes(
          parameterCount: 7000000000,
          bitsPerWeight: 4.5,
        );

        // 7B * 4.5 bits / 8 = ~3.9 GB
        expect(bytes, equals(3937500000));
      });

      test('throws for negative parameter count', () {
        expect(
          () => MemoryUtils.estimateModelWeightsBytes(
            parameterCount: -1,
            bitsPerWeight: 4.0,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws for non-positive bits per weight', () {
        expect(
          () => MemoryUtils.estimateModelWeightsBytes(
            parameterCount: 7000000000,
            bitsPerWeight: 0,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('estimateKVCacheBytes', () {
      test('calculates KV cache for typical 7B model', () {
        final bytes = MemoryUtils.estimateKVCacheBytes(
          contextSize: 4096,
          layerCount: 32,
          headDimension: 128,
          headCount: 32,
          bytesPerElement: 2,
        );

        // 2 * 32 * 4096 * 32 * 128 * 2 = 2,147,483,648 bytes (~2GB)
        expect(bytes, equals(2147483648));
      });

      test('scales with context size', () {
        final bytes2k = MemoryUtils.estimateKVCacheBytes(
          contextSize: 2048,
          layerCount: 32,
          headDimension: 128,
          headCount: 32,
        );
        final bytes4k = MemoryUtils.estimateKVCacheBytes(
          contextSize: 4096,
          layerCount: 32,
          headDimension: 128,
          headCount: 32,
        );

        expect(bytes4k, equals(bytes2k * 2));
      });

      test('throws for non-positive context size', () {
        expect(
          () => MemoryUtils.estimateKVCacheBytes(
            contextSize: 0,
            layerCount: 32,
            headDimension: 128,
            headCount: 32,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('estimateTotalMemory', () {
      test('combines weights, KV cache, and scratch buffer', () {
        final estimate = MemoryUtils.estimateTotalMemory(
          parameterCount: 7000000000,
          bitsPerWeight: 4.0,
          contextSize: 4096,
          layerCount: 32,
          headDimension: 128,
          headCount: 32,
        );

        expect(estimate.modelWeights, greaterThan(0));
        expect(estimate.kvCache, greaterThan(0));
        expect(estimate.scratchBuffer, greaterThan(0));
        expect(
          estimate.total,
          equals(
            estimate.modelWeights + estimate.kvCache + estimate.scratchBuffer,
          ),
        );
      });

      test('uses custom scratch buffer size', () {
        final estimate = MemoryUtils.estimateTotalMemory(
          parameterCount: 7000000000,
          bitsPerWeight: 4.0,
          contextSize: 4096,
          layerCount: 32,
          headDimension: 128,
          headCount: 32,
          scratchBufferBytes: 256 * 1024 * 1024,
        );

        expect(estimate.scratchBuffer, equals(256 * 1024 * 1024));
      });
    });

    group('quantizationBits', () {
      test('contains common quantization formats', () {
        expect(MemoryUtils.quantizationBits, containsPair('Q4_K_M', 4.5));
        expect(MemoryUtils.quantizationBits, containsPair('Q8_0', 8.0));
        expect(MemoryUtils.quantizationBits, containsPair('F16', 16.0));
      });
    });

    group('getBitsPerWeight', () {
      test('returns bits for known quantization', () {
        expect(MemoryUtils.getBitsPerWeight('Q4_K_M'), equals(4.5));
        expect(MemoryUtils.getBitsPerWeight('q4_k_m'),
            equals(4.5)); // Case insensitive
      });

      test('returns null for unknown quantization', () {
        expect(MemoryUtils.getBitsPerWeight('UNKNOWN'), isNull);
      });
    });
  });

  group('MemoryEstimate', () {
    test('calculates total correctly', () {
      const estimate = MemoryEstimate(
        modelWeights: 4000000000,
        kvCache: 1000000000,
        scratchBuffer: 500000000,
      );

      expect(estimate.total, equals(5500000000));
    });

    test('formats sizes correctly', () {
      const estimate = MemoryEstimate(
        modelWeights: 4 * 1024 * 1024 * 1024, // 4 GB
        kvCache: 1024 * 1024 * 1024, // 1 GB
        scratchBuffer: 512 * 1024 * 1024, // 512 MB
      );

      expect(estimate.modelWeightsFormatted, equals('4.0 GB'));
      expect(estimate.kvCacheFormatted, equals('1.0 GB'));
      expect(estimate.scratchBufferFormatted, equals('512.0 MB'));
    });

    test('toString returns readable format', () {
      const estimate = MemoryEstimate(
        modelWeights: 4000000000,
        kvCache: 1000000000,
        scratchBuffer: 500000000,
      );

      final str = estimate.toString();
      expect(str, contains('weights:'));
      expect(str, contains('kvCache:'));
      expect(str, contains('scratch:'));
      expect(str, contains('total:'));
    });
  });
}
