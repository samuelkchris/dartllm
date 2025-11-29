# DartLLM

**Run LLMs locally in Dart & Flutter apps - no cloud, no API keys, full privacy.**

[![Pub Version](https://img.shields.io/pub/v/dartllm)](https://pub.dev/packages/dartllm)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

DartLLM brings the power of large language models directly to your Dart and Flutter applications. Built on [llama.cpp](https://github.com/ggerganov/llama.cpp), it supports 80+ model architectures with GPU acceleration across all major platforms.

---

## Features

- **100% Local** - Models run on-device. Your data never leaves the device.
- **Cross-Platform** - Android, iOS, macOS, Windows, Linux, Web
- **GPU Accelerated** - Metal (Apple), CUDA (NVIDIA), Vulkan
- **Simple API** - Load a model, chat or complete, done.
- **Streaming** - Real-time token generation for responsive UIs
- **HuggingFace** - Download models directly from HuggingFace Hub
- **Non-blocking** - Isolate-based inference keeps your UI smooth

---

## Quick Start

### 1. Install

```bash
dart pub add dartllm
```

### 2. Use

```dart
import 'package:dartllm/dartllm.dart';

void main() async {
  final model = await DartLLM.loadModel('path/to/model.gguf');

  final result = await model.chat([
    const UserMessage('Hello!'),
  ]);

  print(result.message.content);
  await model.dispose();
}
```

---

## Examples

### Text Completion

```dart
final result = await model.complete(
  'The capital of France is',
  config: const GenerationConfig(maxTokens: 50),
);
print(result.text);
```

### Chat

```dart
final result = await model.chat([
  const SystemMessage('You are a helpful assistant.'),
  const UserMessage('What is 2+2?'),
], config: const GenerationConfig(maxTokens: 100));

print(result.message.content);
```

### Streaming

```dart
await for (final chunk in model.completeStream(
  'Once upon a time',
  config: const GenerationConfig(maxTokens: 200),
)) {
  stdout.write(chunk.text);
}
```

### Chat Streaming

```dart
await for (final chunk in model.chatStream([
  const UserMessage('Tell me a joke'),
])) {
  stdout.write(chunk.delta.content);
}
```

### Download from HuggingFace

```dart
final model = await DartLLM.loadFromHuggingFace(
  'Qwen/Qwen2.5-0.5B-Instruct-GGUF',
  filename: 'qwen2.5-0.5b-instruct-q4_k_m.gguf',
  onDownloadProgress: (progress) {
    print('${(progress * 100).toInt()}%');
  },
);
```

---

## Configuration

### Model Loading

```dart
final model = await DartLLM.loadModel(
  'model.gguf',
  config: const ModelConfig(
    contextSize: 2048,    // Context window size
    gpuLayers: -1,        // -1 = auto, 0 = CPU only
    threads: 4,           // CPU threads
  ),
);
```

### Generation

```dart
final result = await model.chat(
  messages,
  config: const GenerationConfig(
    maxTokens: 512,       // Max tokens to generate
    temperature: 0.7,     // Randomness (0.0 - 2.0)
    topP: 0.9,            // Nucleus sampling
    topK: 40,             // Top-K sampling
    repeatPenalty: 1.1,   // Repetition penalty
    stopSequences: ['User:'],  // Stop generation at these
  ),
);
```

---

## Recommended Models

| Model | Size | RAM | Use Case |
|-------|------|-----|----------|
| [Qwen2.5-0.5B-Instruct](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF) | 400MB | 1GB | Mobile, quick responses |
| [Qwen2.5-1.5B-Instruct](https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF) | 1GB | 2GB | Mobile, balanced |
| [Llama-3.2-3B-Instruct](https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF) | 2GB | 4GB | Desktop, quality |
| [Mistral-7B-Instruct](https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF) | 4GB | 8GB | Desktop, high quality |
| [Phi-3-mini-4k](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf) | 2GB | 4GB | Coding, reasoning |

> Use Q4_K_M quantization for best size/quality balance.

---

## Platform Support

| Platform | GPU | Min Version | Notes |
|----------|-----|-------------|-------|
| macOS | Metal | 11.0 | Apple Silicon recommended |
| iOS | Metal | 14.0 | A12+ chip recommended |
| Android | Vulkan | API 24 | 4GB+ RAM recommended |
| Windows | CUDA/Vulkan | 10 | NVIDIA GPU optional |
| Linux | CUDA/Vulkan | glibc 2.31 | NVIDIA GPU optional |
| Web | WebGPU | Chrome 119 | Experimental |

---

## Building from Source (Optional)

Pre-built binaries are included for all platforms. Building from source is only needed for development or custom builds (e.g., CUDA support).

### Prerequisites

- CMake 3.14+
- C++ compiler (Clang, GCC, or MSVC)

### Build

```bash
git clone --recursive https://github.com/samuelkchris/dartllm.git
cd dartllm
dart run dartllm:setup
```

### Custom Builds

```bash
# CUDA support (Linux/Windows with NVIDIA GPU)
cd native && mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DGGML_CUDA=ON
cmake --build . --config Release -j
```

---

## Troubleshooting

### Library not found

```
LibraryLoadException: Failed to load DartLLM native library
```

Pre-built binaries should load automatically. If not, try building from source:

```bash
dart run dartllm:setup
```

### Out of memory

Reduce context size or use a smaller model:

```dart
config: const ModelConfig(contextSize: 512, gpuLayers: 0)
```

### Slow on first load

Model loading involves memory mapping. Subsequent loads are faster. Reduce `contextSize` for faster initialization.

### GPU issues

Force CPU-only mode:

```dart
config: const ModelConfig(gpuLayers: 0)
```

---

## API Reference

### DartLLM

```dart
// Load from file
static Future<LLMModel> loadModel(String path, {ModelConfig? config})

// Load from HuggingFace
static Future<LLMModel> loadFromHuggingFace(
  String repository,
  {String? filename, ModelConfig? config, Function(double)? onDownloadProgress}
)
```

### LLMModel

```dart
// Text completion
Future<TextCompletion> complete(String prompt, {GenerationConfig? config})
Stream<TextCompletionChunk> completeStream(String prompt, {GenerationConfig? config})

// Chat completion
Future<ChatCompletion> chat(List<ChatMessage> messages, {GenerationConfig? config})
Stream<ChatCompletionChunk> chatStream(List<ChatMessage> messages, {GenerationConfig? config})

// Embeddings
Future<List<double>> embed(String text)

// Cleanup
Future<void> dispose()

// Model info
ModelInfo get modelInfo
```

### Messages

```dart
const SystemMessage('You are helpful.')
const UserMessage('Hello!')
const AssistantMessage('Hi there!')
```

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│                 Your Dart/Flutter App            │
├─────────────────────────────────────────────────┤
│                   DartLLM API                    │
│     DartLLM · LLMModel · ChatMessage · Config   │
├─────────────────────────────────────────────────┤
│              Platform Bridge (FFI)               │
│         Isolate-based non-blocking I/O          │
├─────────────────────────────────────────────────┤
│                  Native Core                     │
│           llama.cpp + GGML backend              │
├─────────────────────────────────────────────────┤
│                   Hardware                       │
│         CPU · Metal · CUDA · Vulkan             │
└─────────────────────────────────────────────────┘
```

---

## License

MIT License - see [LICENSE](LICENSE) for details.

Built on [llama.cpp](https://github.com/ggerganov/llama.cpp) by Georgi Gerganov.
