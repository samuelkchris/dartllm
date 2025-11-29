import 'dart:async';

import 'package:dartllm/src/api/llm_model.dart';
import 'package:dartllm/src/core/chat_template.dart';
import 'package:dartllm/src/core/inference_context.dart';
import 'package:dartllm/src/core/inference_engine.dart';
import 'package:dartllm/src/core/tokenizer.dart';
import 'package:dartllm/src/models/chat_message.dart';
import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/generation_config.dart';
import 'package:dartllm/src/models/model_info.dart';
import 'package:test/test.dart';

/// Mock tokenizer for testing.
class MockTokenizer implements Tokenizer {
  @override
  int get vocabularySize => 32000;

  @override
  int get bosToken => 1;

  @override
  int get eosToken => 2;

  @override
  Future<List<int>> encode(String text, {bool addSpecialTokens = true}) async {
    // Simple mock: each character becomes a token
    final tokens = text.codeUnits.toList();
    if (addSpecialTokens) {
      return [bosToken, ...tokens, eosToken];
    }
    return tokens;
  }

  @override
  Future<String> decode(List<int> tokens) async {
    // Filter out special tokens and convert back
    final filtered = tokens.where((t) => t != bosToken && t != eosToken);
    return String.fromCharCodes(filtered);
  }

  @override
  Future<int> countTokens(String text) async {
    final tokens = await encode(text);
    return tokens.length;
  }
}

/// Mock inference engine for testing LLMModel.
class MockInferenceEngine implements InferenceEngine {
  final ModelInfo _modelInfo;
  final InferenceContext _context;
  final MockTokenizer _tokenizer;
  ChatTemplate _chatTemplate;
  bool _isDisposed = false;

  MockInferenceEngine()
      : _modelInfo = const ModelInfo(
          name: 'mock-model',
          parameterCount: 7000000000,
          architecture: 'llama',
          quantization: 'Q4_K_M',
          contextSize: 4096,
          vocabularySize: 32000,
          embeddingSize: 4096,
          layerCount: 32,
          headCount: 32,
          fileSizeBytes: 4000000000,
        ),
        _context = InferenceContext(
          modelInfo: const ModelInfo(
            name: 'mock-model',
            parameterCount: 7000000000,
            architecture: 'llama',
            quantization: 'Q4_K_M',
            contextSize: 4096,
            vocabularySize: 32000,
            embeddingSize: 4096,
            layerCount: 32,
            headCount: 32,
            fileSizeBytes: 4000000000,
          ),
          contextSize: 4096,
        ),
        _tokenizer = MockTokenizer(),
        _chatTemplate = ChatMLTemplate();

  @override
  bool get isModelLoaded => !_isDisposed;

  @override
  ModelInfo get modelInfo => _modelInfo;

  @override
  Tokenizer get tokenizer => _tokenizer;

  @override
  ChatTemplate get chatTemplate => _chatTemplate;

  @override
  InferenceContext get context => _context;

  @override
  bool get isDisposed => _isDisposed;

  @override
  Future<ModelInfo> loadModel(String modelPath, {dynamic config}) async {
    return _modelInfo;
  }

  @override
  Future<void> unloadModel() async {
    _isDisposed = true;
  }

  @override
  Future<GenerationResult> generate(
    String prompt, {
    GenerationConfig config = const GenerationConfig(),
  }) async {
    return GenerationResult(
      text: 'Mock response to: $prompt',
      tokens: [1, 2, 3],
      promptTokenCount: prompt.length,
      completionTokenCount: 3,
      finishReason: FinishReason.stop,
      generationTimeMs: 100,
    );
  }

  @override
  Stream<GenerationChunk> generateStream(
    String prompt, {
    GenerationConfig config = const GenerationConfig(),
  }) async* {
    yield const GenerationChunk(text: 'Mock ', token: 1);
    yield const GenerationChunk(text: 'response', token: 2);
    yield const GenerationChunk(
      text: '.',
      token: 3,
      finishReason: FinishReason.stop,
    );
  }

  @override
  Future<GenerationResult> chat(
    List<ChatMessage> messages, {
    GenerationConfig config = const GenerationConfig(),
  }) async {
    return GenerationResult(
      text: 'Mock chat response',
      tokens: [1, 2, 3],
      promptTokenCount: 10,
      completionTokenCount: 3,
      finishReason: FinishReason.stop,
      generationTimeMs: 100,
    );
  }

  @override
  Stream<GenerationChunk> chatStream(
    List<ChatMessage> messages, {
    GenerationConfig config = const GenerationConfig(),
  }) async* {
    yield const GenerationChunk(text: 'Mock ', token: 1);
    yield const GenerationChunk(text: 'chat ', token: 2);
    yield const GenerationChunk(
      text: 'response',
      token: 3,
      finishReason: FinishReason.stop,
    );
  }

  @override
  Future<List<double>> embed(String text, {bool normalize = true}) async {
    return List.filled(4096, 0.1);
  }

  @override
  void setChatTemplate(ChatTemplate template) {
    _chatTemplate = template;
  }

  @override
  void resetContext() {
    _context.clear();
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _context.dispose();
  }
}

void main() {
  group('LLMModel', () {
    late MockInferenceEngine mockEngine;
    late LLMModel model;

    setUp(() {
      mockEngine = MockInferenceEngine();
      model = LLMModel.internal(mockEngine);
    });

    tearDown(() async {
      if (!model.isDisposed) {
        await model.dispose();
      }
    });

    group('properties', () {
      test('modelInfo returns engine model info', () {
        expect(model.modelInfo.name, equals('mock-model'));
        expect(model.modelInfo.architecture, equals('llama'));
      });

      test('contextSize returns context size', () {
        expect(model.contextSize, equals(4096));
      });

      test('tokenCount returns current token count', () {
        expect(model.tokenCount, equals(0));
      });

      test('remainingCapacity returns available tokens', () {
        expect(model.remainingCapacity, equals(4096));
      });

      test('chatTemplate returns current template', () {
        expect(model.chatTemplate, isA<ChatMLTemplate>());
      });

      test('isDisposed initially false', () {
        expect(model.isDisposed, isFalse);
      });
    });

    group('chat', () {
      test('returns ChatCompletion', () async {
        final messages = [
          const ChatMessage.user('Hello'),
        ];

        final result = await model.chat(messages);

        expect(result.message.content, equals('Mock chat response'));
        expect(result.finishReason, equals(FinishReason.stop));
        expect(result.usage.totalTokens, equals(13));
      });

      test('accepts custom config', () async {
        final messages = [const ChatMessage.user('Hello')];
        final config = const GenerationConfig(
          maxTokens: 100,
          temperature: 0.5,
        );

        final result = await model.chat(messages, config: config);

        expect(result.message.content, isNotEmpty);
      });

      test('throws StateError when disposed', () async {
        await model.dispose();

        expect(
          () => model.chat([const ChatMessage.user('Hello')]),
          throwsStateError,
        );
      });
    });

    group('chatStream', () {
      test('yields ChatCompletionChunks', () async {
        final messages = [const ChatMessage.user('Hello')];
        final chunks = <String>[];

        await for (final chunk in model.chatStream(messages)) {
          chunks.add(chunk.delta.content);
        }

        expect(chunks, equals(['Mock ', 'chat ', 'response']));
      });

      test('last chunk has finishReason', () async {
        final messages = [const ChatMessage.user('Hello')];
        FinishReason? lastReason;

        await for (final chunk in model.chatStream(messages)) {
          if (chunk.isLast) {
            lastReason = chunk.finishReason;
          }
        }

        expect(lastReason, equals(FinishReason.stop));
      });

      test('throws StateError when disposed', () async {
        await model.dispose();

        // Stream methods check disposed synchronously
        expect(
          () async {
            await for (final _
                in model.chatStream([const ChatMessage.user('Hello')])) {
              // Should not reach here
            }
          }(),
          throwsStateError,
        );
      });
    });

    group('complete', () {
      test('returns TextCompletion', () async {
        final result = await model.complete('Once upon a time');

        expect(result.text, contains('Mock response'));
        expect(result.finishReason, equals(FinishReason.stop));
      });

      test('throws StateError when disposed', () async {
        await model.dispose();

        expect(
          () => model.complete('Hello'),
          throwsStateError,
        );
      });
    });

    group('completeStream', () {
      test('yields TextCompletionChunks', () async {
        final chunks = <String>[];

        await for (final chunk in model.completeStream('Hello')) {
          chunks.add(chunk.text);
        }

        expect(chunks, equals(['Mock ', 'response', '.']));
      });
    });

    group('embed', () {
      test('returns embedding vector', () async {
        final embedding = await model.embed('Hello world');

        expect(embedding.length, equals(4096));
        expect(embedding.every((v) => v == 0.1), isTrue);
      });

      test('throws StateError when disposed', () async {
        await model.dispose();

        expect(
          () => model.embed('Hello'),
          throwsStateError,
        );
      });
    });

    group('embedBatch', () {
      test('returns multiple embeddings', () async {
        final embeddings = await model.embedBatch(['Hello', 'World']);

        expect(embeddings.length, equals(2));
        expect(embeddings[0].length, equals(4096));
        expect(embeddings[1].length, equals(4096));
      });
    });

    group('countTokens', () {
      test('returns token count', () async {
        final count = await model.countTokens('Hello world');

        // MockTokenizer: each char becomes token + BOS + EOS
        expect(count, equals(13)); // 11 chars + 2 special tokens
      });

      test('throws StateError when disposed', () async {
        await model.dispose();

        expect(
          () => model.countTokens('Hello'),
          throwsStateError,
        );
      });
    });

    group('tokenize', () {
      test('returns token IDs', () async {
        final tokens = await model.tokenize('Hi');

        // MockTokenizer: BOS + 'H' + 'i' + EOS
        expect(tokens.length, equals(4));
        expect(tokens.first, equals(1)); // BOS
        expect(tokens.last, equals(2)); // EOS
      });

      test('can skip special tokens', () async {
        final tokens = await model.tokenize('Hi', addSpecialTokens: false);

        expect(tokens.length, equals(2));
      });
    });

    group('detokenize', () {
      test('converts tokens to text', () async {
        final text = await model.detokenize([72, 105]); // 'Hi' ASCII

        expect(text, equals('Hi'));
      });
    });

    group('setChatTemplate', () {
      test('changes the chat template', () {
        model.setChatTemplate(Llama3InstructTemplate());

        expect(model.chatTemplate, isA<Llama3InstructTemplate>());
      });

      test('throws StateError when disposed', () async {
        await model.dispose();

        expect(
          () => model.setChatTemplate(ChatMLTemplate()),
          throwsStateError,
        );
      });
    });

    group('resetContext', () {
      test('clears context', () {
        model.resetContext();
        expect(model.tokenCount, equals(0));
      });

      test('throws StateError when disposed', () async {
        await model.dispose();

        expect(
          () => model.resetContext(),
          throwsStateError,
        );
      });
    });

    group('dispose', () {
      test('marks model as disposed', () async {
        await model.dispose();

        expect(model.isDisposed, isTrue);
      });

      test('is idempotent', () async {
        await model.dispose();
        await model.dispose();

        expect(model.isDisposed, isTrue);
      });

      test('prevents further operations', () async {
        await model.dispose();

        expect(() => model.modelInfo, throwsStateError);
        expect(() => model.contextSize, throwsStateError);
        expect(() => model.tokenCount, throwsStateError);
        expect(() => model.chatTemplate, throwsStateError);
      });
    });
  });
}
