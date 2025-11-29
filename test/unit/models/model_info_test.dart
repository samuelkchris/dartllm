import 'package:dartllm/src/models/model_info.dart';
import 'package:test/test.dart';

void main() {
  group('ModelInfo', () {
    test('stores all model metadata', () {
      const info = ModelInfo(
        name: 'Llama-2-7B',
        parameterCount: 7000000000,
        architecture: 'llama',
        quantization: 'Q4_K_M',
        contextSize: 4096,
        vocabularySize: 32000,
        embeddingSize: 4096,
        layerCount: 32,
        headCount: 32,
        fileSizeBytes: 4200000000,
        supportsEmbedding: true,
        supportsVision: false,
        chatTemplate: 'llama2',
      );

      expect(info.name, equals('Llama-2-7B'));
      expect(info.parameterCount, equals(7000000000));
      expect(info.architecture, equals('llama'));
      expect(info.quantization, equals('Q4_K_M'));
      expect(info.contextSize, equals(4096));
      expect(info.vocabularySize, equals(32000));
      expect(info.embeddingSize, equals(4096));
      expect(info.layerCount, equals(32));
      expect(info.headCount, equals(32));
      expect(info.fileSizeBytes, equals(4200000000));
      expect(info.supportsEmbedding, isTrue);
      expect(info.supportsVision, isFalse);
      expect(info.chatTemplate, equals('llama2'));
    });

    group('parameterCountFormatted', () {
      test('formats billions correctly', () {
        const info = ModelInfo(
          name: 'test',
          parameterCount: 7000000000,
          architecture: 'llama',
          quantization: 'Q4',
          contextSize: 4096,
          vocabularySize: 32000,
          embeddingSize: 4096,
          layerCount: 32,
          headCount: 32,
          fileSizeBytes: 4000000000,
        );

        expect(info.parameterCountFormatted, equals('7.0B'));
      });

      test('formats trillions correctly', () {
        const info = ModelInfo(
          name: 'test',
          parameterCount: 1500000000000,
          architecture: 'llama',
          quantization: 'Q4',
          contextSize: 4096,
          vocabularySize: 32000,
          embeddingSize: 4096,
          layerCount: 32,
          headCount: 32,
          fileSizeBytes: 4000000000,
        );

        expect(info.parameterCountFormatted, equals('1.5T'));
      });

      test('formats millions correctly', () {
        const info = ModelInfo(
          name: 'test',
          parameterCount: 125000000,
          architecture: 'llama',
          quantization: 'Q4',
          contextSize: 4096,
          vocabularySize: 32000,
          embeddingSize: 4096,
          layerCount: 32,
          headCount: 32,
          fileSizeBytes: 4000000000,
        );

        expect(info.parameterCountFormatted, equals('125.0M'));
      });
    });

    group('fileSizeFormatted', () {
      test('formats GB correctly', () {
        const info = ModelInfo(
          name: 'test',
          parameterCount: 7000000000,
          architecture: 'llama',
          quantization: 'Q4',
          contextSize: 4096,
          vocabularySize: 32000,
          embeddingSize: 4096,
          layerCount: 32,
          headCount: 32,
          fileSizeBytes: 4200000000,
        );

        expect(info.fileSizeFormatted, equals('4.2 GB'));
      });

      test('formats MB correctly', () {
        const info = ModelInfo(
          name: 'test',
          parameterCount: 7000000000,
          architecture: 'llama',
          quantization: 'Q4',
          contextSize: 4096,
          vocabularySize: 32000,
          embeddingSize: 4096,
          layerCount: 32,
          headCount: 32,
          fileSizeBytes: 150000000,
        );

        expect(info.fileSizeFormatted, equals('150.0 MB'));
      });
    });

    group('default values', () {
      test('supportsEmbedding defaults to false', () {
        const info = ModelInfo(
          name: 'test',
          parameterCount: 7000000000,
          architecture: 'llama',
          quantization: 'Q4',
          contextSize: 4096,
          vocabularySize: 32000,
          embeddingSize: 4096,
          layerCount: 32,
          headCount: 32,
          fileSizeBytes: 4000000000,
        );

        expect(info.supportsEmbedding, isFalse);
        expect(info.supportsVision, isFalse);
        expect(info.chatTemplate, isNull);
      });
    });
  });

  group('CachedModelInfo', () {
    test('stores cached model metadata', () {
      final downloadedAt = DateTime(2024, 1, 15, 10, 30);
      final info = CachedModelInfo(
        modelId: 'llama-2-7b-chat-q4',
        filePath: '/cache/models/llama-2-7b-chat.Q4_K_M.gguf',
        sizeBytes: 4200000000,
        downloadedAt: downloadedAt,
        sourceUrl: 'https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF',
      );

      expect(info.modelId, equals('llama-2-7b-chat-q4'));
      expect(info.filePath, equals('/cache/models/llama-2-7b-chat.Q4_K_M.gguf'));
      expect(info.sizeBytes, equals(4200000000));
      expect(info.downloadedAt, equals(downloadedAt));
      expect(info.sourceUrl, equals('https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF'));
      expect(info.modelInfo, isNull);
    });

    group('sizeFormatted', () {
      test('formats GB correctly', () {
        final info = CachedModelInfo(
          modelId: 'test',
          filePath: '/test',
          sizeBytes: 4200000000,
          downloadedAt: DateTime.now(),
          sourceUrl: 'https://example.com',
        );

        expect(info.sizeFormatted, equals('4.2 GB'));
      });

      test('formats MB correctly', () {
        final info = CachedModelInfo(
          modelId: 'test',
          filePath: '/test',
          sizeBytes: 150000000,
          downloadedAt: DateTime.now(),
          sourceUrl: 'https://example.com',
        );

        expect(info.sizeFormatted, equals('150.0 MB'));
      });
    });
  });
}
