import 'dart:io';
import 'package:dartllm/src/models/model_config.dart';
import 'package:dartllm/src/platform/native_binding.dart';
import 'package:dartllm/src/platform/platform_binding.dart';
import 'package:test/test.dart';

void main() {
  group('NativeBinding Integration Tests', () {
    late NativeBinding binding;

    setUp(() {
      binding = NativeBinding();
    });

    tearDown(() {
      binding.dispose();
    });

    test('can initialize native library', () async {
      // Skip if library not available (CI environment)
      final initialized = await binding.initialize();
      if (!initialized) {
        print('Skipping: Native library not available');
        return;
      }

      expect(binding.isAvailable, isTrue);
      print('DartLLM version: ${binding.version}');
      print('llama.cpp version: ${binding.llamaVersion}');
      print('GPU backend: ${binding.gpuBackendName}');
      print('GPU support: ${binding.supportsGpu}');
      print('VRAM size: ${binding.vramSize} bytes');
    });

    test('can load and unload model', () async {
      final initialized = await binding.initialize();
      if (!initialized) {
        print('Skipping: Native library not available');
        return;
      }

      final modelPath = 'test_models/qwen2.5-0.5b-q4_k_m.gguf';
      if (!File(modelPath).existsSync()) {
        print('Skipping: Test model not found at $modelPath');
        return;
      }

      print('Loading model: $modelPath');

      const config = ModelConfig(
        contextSize: 512,
        gpuLayers: 0, // CPU only for testing
        threads: 4,
        batchSize: 512,
        useMemoryMap: true,
      );

      final result = await binding.loadModel(
        LoadModelRequest(modelPath: modelPath, config: config),
      );

      expect(result.handle, greaterThan(0));
      print('Model loaded with handle: ${result.handle}');
      print('Model name: ${result.modelInfo.name}');
      print('Architecture: ${result.modelInfo.architecture}');
      print('Quantization: ${result.modelInfo.quantization}');
      print('Context size: ${result.modelInfo.contextSize}');
      print('Vocabulary size: ${result.modelInfo.vocabularySize}');
      print('Embedding size: ${result.modelInfo.embeddingSize}');
      print('Layer count: ${result.modelInfo.layerCount}');
      print('File size: ${result.modelInfo.fileSizeBytes} bytes');

      await binding.unloadModel(result.handle);
      print('Model unloaded');
    });

    test('can tokenize and detokenize', () async {
      final initialized = await binding.initialize();
      if (!initialized) {
        print('Skipping: Native library not available');
        return;
      }

      final modelPath = 'test_models/qwen2.5-0.5b-q4_k_m.gguf';
      if (!File(modelPath).existsSync()) {
        print('Skipping: Test model not found');
        return;
      }

      const config = ModelConfig(
        contextSize: 512,
        gpuLayers: 0,
        threads: 4,
        batchSize: 512,
        useMemoryMap: true,
      );

      final result = await binding.loadModel(
        LoadModelRequest(modelPath: modelPath, config: config),
      );

      final testText = 'Hello, how are you?';
      print('Tokenizing: "$testText"');

      final tokens = await binding.tokenize(
        TokenizeRequest(
          modelHandle: result.handle,
          text: testText,
          addSpecialTokens: false,
        ),
      );

      print('Tokens: $tokens (${tokens.length} tokens)');
      expect(tokens, isNotEmpty);

      final decoded = await binding.detokenize(
        DetokenizeRequest(modelHandle: result.handle, tokens: tokens),
      );

      print('Decoded: "$decoded"');
      expect(decoded, contains('Hello'));

      await binding.unloadModel(result.handle);
    });

    test('can generate text', () async {
      final initialized = await binding.initialize();
      if (!initialized) {
        print('Skipping: Native library not available');
        return;
      }

      final modelPath = 'test_models/qwen2.5-0.5b-q4_k_m.gguf';
      if (!File(modelPath).existsSync()) {
        print('Skipping: Test model not found');
        return;
      }

      const config = ModelConfig(
        contextSize: 512,
        gpuLayers: 0,
        threads: 4,
        batchSize: 512,
        useMemoryMap: true,
      );

      final loadResult = await binding.loadModel(
        LoadModelRequest(modelPath: modelPath, config: config),
      );

      final prompt = 'The capital of France is';
      print('Prompt: "$prompt"');

      final tokens = await binding.tokenize(
        TokenizeRequest(
          modelHandle: loadResult.handle,
          text: prompt,
          addSpecialTokens: true,
        ),
      );

      print('Prompt tokens: ${tokens.length}');

      final generateResult = await binding.generate(
        GenerateRequest(
          modelHandle: loadResult.handle,
          promptTokens: tokens,
          maxTokens: 20,
          temperature: 0.7,
          topP: 0.9,
          topK: 40,
          minP: 0.0,
          repetitionPenalty: 1.1,
          frequencyPenalty: 0.0,
          presencePenalty: 0.0,
          repeatLastN: 64,
          stopTokens: [],
          seed: 42,
        ),
      );

      print('Generated ${generateResult.completionTokenCount} tokens');
      print('Finish reason: ${generateResult.finishReason}');
      print('Generation time: ${generateResult.generationTimeMs}ms');

      final outputText = await binding.detokenize(
        DetokenizeRequest(
          modelHandle: loadResult.handle,
          tokens: generateResult.tokens,
        ),
      );

      print('Generated text: "$outputText"');
      expect(generateResult.tokens, isNotEmpty);

      await binding.unloadModel(loadResult.handle);
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
