/// DartLLM - Run local LLMs on-device in Dart/Flutter.
///
/// DartLLM provides a simple, high-performance interface for running
/// GGUF-format language models locally on mobile, desktop, and web platforms.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:dartllm/dartllm.dart';
///
/// // Load a model
/// final model = await DartLLM.loadModel('path/to/model.gguf');
///
/// // Chat completion
/// final response = await model.chat([
///   ChatMessage.system('You are a helpful assistant.'),
///   ChatMessage.user('What is the capital of France?'),
/// ]);
/// print(response.message.content);
///
/// // Streaming
/// await for (final chunk in model.chatStream([
///   ChatMessage.user('Tell me a story'),
/// ])) {
///   stdout.write(chunk.delta.content);
/// }
///
/// // Clean up
/// model.dispose();
/// ```
///
/// ## Features
///
/// - **Multi-platform**: iOS, Android, macOS, Windows, Linux, Web
/// - **Hardware acceleration**: Metal, CUDA, Vulkan, WebGPU
/// - **Streaming**: Real-time token-by-token generation
/// - **Chat templates**: Built-in support for ChatML, Llama, Mistral, etc.
/// - **Embeddings**: Generate text embeddings for similarity search
///
/// ## Model Loading
///
/// Models can be loaded from:
/// - Local GGUF files: `DartLLM.loadModel(path)`
/// - HuggingFace repos: `DartLLM.loadFromHuggingFace(repo, filename:)`
/// - Direct URLs: `DartLLM.loadFromUrl(url)`
///
/// ## Configuration
///
/// Configure model behavior with [ModelConfig]:
///
/// ```dart
/// final model = await DartLLM.loadModel(
///   'model.gguf',
///   config: ModelConfig(
///     contextSize: 4096,
///     gpuLayers: 32,
///     threads: 4,
///   ),
/// );
/// ```
///
/// Configure generation with [GenerationConfig]:
///
/// ```dart
/// final response = await model.chat(
///   messages,
///   config: GenerationConfig(
///     maxTokens: 500,
///     temperature: 0.7,
///     topP: 0.9,
///   ),
/// );
/// ```
library;

export 'src/api/api.dart';
export 'src/models/chat_completion.dart';
export 'src/models/chat_message.dart';
export 'src/models/enums.dart';
export 'src/models/generation_config.dart';
export 'src/models/global_config.dart';
export 'src/models/model_config.dart';
export 'src/models/model_info.dart';
export 'src/models/text_completion.dart';
export 'src/models/usage_stats.dart';
export 'src/core/chat_template.dart';
export 'src/core/exceptions/exceptions.dart';
