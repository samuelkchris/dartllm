import 'dart:io';
import 'package:dartllm/dartllm.dart';

void main() async {
  print('Downloading model from HuggingFace...');

  final model = await DartLLM.loadFromHuggingFace(
    'Qwen/Qwen2.5-0.5B-Instruct-GGUF',
    filename: 'qwen2.5-0.5b-instruct-q4_k_m.gguf',
    config: const ModelConfig(contextSize: 512, gpuLayers: 0),
    onDownloadProgress: (progress) {
      stdout.write('\rDownload: ${(progress * 100).toInt()}%');
    },
  );

  print('\nLoaded: ${model.modelInfo.name}\n');

  final result = await model.chat(
    [const UserMessage('Hello!')],
    config: const GenerationConfig(maxTokens: 50),
  );
  print('Response: ${result.message.content}');

  await model.dispose();
}
