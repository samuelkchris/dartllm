import 'dart:typed_data';

import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/model_config.dart';
import 'package:dartllm/src/models/model_info.dart';
import 'package:dartllm/src/platform/platform_binding.dart';
import 'package:test/test.dart';

void main() {
  group('LoadModelRequest', () {
    test('stores model path and config', () {
      const config = ModelConfig(contextSize: 4096, gpuLayers: 32);
      const request = LoadModelRequest(
        modelPath: '/path/to/model.gguf',
        config: config,
      );

      expect(request.modelPath, equals('/path/to/model.gguf'));
      expect(request.config.contextSize, equals(4096));
      expect(request.config.gpuLayers, equals(32));
    });
  });

  group('LoadModelResult', () {
    test('stores handle and model info', () {
      const result = LoadModelResult(
        handle: 42,
        modelInfo: _testModelInfo,
      );

      expect(result.handle, equals(42));
      expect(result.modelInfo.name, equals('test-model'));
    });
  });

  group('GenerateRequest', () {
    test('stores all generation parameters', () {
      const request = GenerateRequest(
        modelHandle: 1,
        promptTokens: [1, 2, 3, 4],
        maxTokens: 100,
        temperature: 0.7,
        topP: 0.9,
        topK: 40,
        minP: 0.05,
        repetitionPenalty: 1.1,
        frequencyPenalty: 0.0,
        presencePenalty: 0.0,
        repeatLastN: 64,
        stopTokens: [0],
        seed: 42,
      );

      expect(request.modelHandle, equals(1));
      expect(request.promptTokens, equals([1, 2, 3, 4]));
      expect(request.maxTokens, equals(100));
      expect(request.temperature, equals(0.7));
      expect(request.topP, equals(0.9));
      expect(request.topK, equals(40));
      expect(request.minP, equals(0.05));
      expect(request.repetitionPenalty, equals(1.1));
      expect(request.frequencyPenalty, equals(0.0));
      expect(request.presencePenalty, equals(0.0));
      expect(request.repeatLastN, equals(64));
      expect(request.stopTokens, equals([0]));
      expect(request.seed, equals(42));
    });

    test('seed is optional', () {
      const request = GenerateRequest(
        modelHandle: 1,
        promptTokens: [1, 2, 3],
        maxTokens: 50,
        temperature: 0.7,
        topP: 0.9,
        topK: 40,
        minP: 0.05,
        repetitionPenalty: 1.1,
        frequencyPenalty: 0.0,
        presencePenalty: 0.0,
        repeatLastN: 64,
        stopTokens: [],
      );

      expect(request.seed, isNull);
    });
  });

  group('GenerateResult', () {
    test('stores generation output', () {
      const result = GenerateResult(
        tokens: [5, 6, 7, 8, 9],
        promptTokenCount: 4,
        completionTokenCount: 5,
        finishReason: FinishReason.stop,
        generationTimeMs: 500,
      );

      expect(result.tokens, equals([5, 6, 7, 8, 9]));
      expect(result.promptTokenCount, equals(4));
      expect(result.completionTokenCount, equals(5));
      expect(result.finishReason, equals(FinishReason.stop));
      expect(result.generationTimeMs, equals(500));
    });

    test('handles different finish reasons', () {
      const lengthResult = GenerateResult(
        tokens: [1, 2, 3],
        promptTokenCount: 1,
        completionTokenCount: 3,
        finishReason: FinishReason.length,
        generationTimeMs: 100,
      );

      const errorResult = GenerateResult(
        tokens: [1],
        promptTokenCount: 1,
        completionTokenCount: 1,
        finishReason: FinishReason.error,
        generationTimeMs: 50,
      );

      expect(lengthResult.finishReason, equals(FinishReason.length));
      expect(errorResult.finishReason, equals(FinishReason.error));
    });
  });

  group('GenerateStreamChunk', () {
    test('stores token and optional finish reason', () {
      const chunk = GenerateStreamChunk(
        token: 123,
        finishReason: null,
      );

      expect(chunk.token, equals(123));
      expect(chunk.finishReason, isNull);
      expect(chunk.isLast, isFalse);
    });

    test('isLast returns true when finishReason is set', () {
      const chunk = GenerateStreamChunk(
        token: 0,
        finishReason: FinishReason.stop,
      );

      expect(chunk.isLast, isTrue);
    });
  });

  group('EmbedRequest', () {
    test('stores embedding parameters', () {
      const request = EmbedRequest(
        modelHandle: 1,
        tokens: [1, 2, 3, 4, 5],
        normalize: true,
      );

      expect(request.modelHandle, equals(1));
      expect(request.tokens, equals([1, 2, 3, 4, 5]));
      expect(request.normalize, isTrue);
    });
  });

  group('EmbedResult', () {
    test('stores embedding vector', () {
      final embedding = Float32List.fromList([0.1, 0.2, 0.3, 0.4]);
      final result = EmbedResult(embedding: embedding);

      expect(result.embedding.length, equals(4));
      expect(result.embedding[0], closeTo(0.1, 0.0001));
      expect(result.embedding[1], closeTo(0.2, 0.0001));
      expect(result.embedding[2], closeTo(0.3, 0.0001));
      expect(result.embedding[3], closeTo(0.4, 0.0001));
    });
  });

  group('TokenizeRequest', () {
    test('stores tokenization parameters', () {
      const request = TokenizeRequest(
        modelHandle: 1,
        text: 'Hello, world!',
        addSpecialTokens: true,
      );

      expect(request.modelHandle, equals(1));
      expect(request.text, equals('Hello, world!'));
      expect(request.addSpecialTokens, isTrue);
    });
  });

  group('DetokenizeRequest', () {
    test('stores detokenization parameters', () {
      const request = DetokenizeRequest(
        modelHandle: 1,
        tokens: [1, 2, 3, 4, 5],
      );

      expect(request.modelHandle, equals(1));
      expect(request.tokens, equals([1, 2, 3, 4, 5]));
    });
  });
}

/// Test model info constant.
const _testModelInfo = ModelInfo(
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
