import 'package:dartllm/dartllm.dart';

/// Example demonstrating DartLLM usage for local LLM inference.
///
/// This example shows how to:
/// - Load a GGUF model
/// - Generate text completions
/// - Use chat conversations
Future<void> main() async {
  // Load a model from local path
  final model = await DartLLM.loadModel('/path/to/model.gguf');

  // Generate a simple text completion
  final completion = await model.complete(
    'Write a haiku about Dart programming:',
    config: const GenerationConfig(maxTokens: 100),
  );
  print('Completion: ${completion.text}');

  // Use chat API for conversations
  final chatResult = await model.chat([
    const UserMessage('What is Dart?'),
  ]);
  print('Response: ${chatResult.message.content}');

  // Clean up
  await model.dispose();
}
