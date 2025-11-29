import 'dart:io';
import 'package:dartllm/dartllm.dart';

void main() async {
  final model = await DartLLM.loadModel(
    'test_models/qwen2.5-0.5b-q4_k_m.gguf',
    config: const ModelConfig(contextSize: 512, gpuLayers: 0),
  );
  print('Loaded: ${model.modelInfo.name}\n');

  await completionExample(model);
  await chatExample(model);
  await streamExample(model);

  await model.dispose();
}

Future<void> completionExample(LLMModel model) async {
  final result = await model.complete(
    'The capital of France is',
    config: const GenerationConfig(maxTokens: 20),
  );
  print('Completion: ${result.text}\n');
}

Future<void> chatExample(LLMModel model) async {
  final result = await model.chat(
    [const UserMessage('What is 2+2?')],
    config: const GenerationConfig(maxTokens: 20),
  );
  print('Chat: ${result.message.content}\n');
}

Future<void> streamExample(LLMModel model) async {
  stdout.write('Stream: ');
  await for (final chunk in model.completeStream(
    '1, 2, 3,',
    config: const GenerationConfig(maxTokens: 20),
  )) {
    stdout.write(chunk.text);
  }
  print('\n');
}
