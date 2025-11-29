# DartLLM Technical Documentation

**Version:** 1.0.0  
**Last Updated:** November 2025  
**Status:** Pre-release Specification

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Architecture Overview](#2-architecture-overview)
3. [Core Concepts](#3-core-concepts)
4. [API Reference](#4-api-reference)
5. [Platform Integration](#5-platform-integration)
6. [Model Management](#6-model-management)
7. [Memory and Performance](#7-memory-and-performance)
8. [Configuration Reference](#8-configuration-reference)
9. [Error Handling](#9-error-handling)
10. [Security Considerations](#10-security-considerations)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. Introduction

### 1.1 Purpose

DartLLM is a unified local large language model inference toolkit designed for the Dart and Flutter ecosystem. It enables developers to run LLM inference entirely on-device across mobile, desktop, and web platforms without requiring cloud connectivity or API keys.

### 1.2 Design Philosophy

DartLLM adheres to four core principles:

**Simplicity First:** A developer with no prior LLM experience should be able to integrate local inference into their application within minutes. The API surface is intentionally minimal, exposing complexity only when explicitly requested.

**Production Ready:** Every feature ships with proper error handling, memory management, and platform-specific optimizations. The library handles edge cases that developers should not need to consider.

**Platform Parity:** Functionality remains consistent across all supported platforms. When platform limitations exist, they are documented explicitly and graceful degradation is provided.

**Zero Configuration:** Sensible defaults eliminate the need for configuration in typical use cases. Advanced users retain full control over every parameter.

### 1.3 Supported Platforms

| Platform | Minimum Version | GPU Acceleration | Binary Distribution |
|----------|-----------------|------------------|---------------------|
| Android | API 24 (Android 7.0) | Vulkan 1.2, OpenCL 2.0 | AAR via Maven |
| iOS | iOS 14.0 | Metal 2.0 | XCFramework via CocoaPods/SPM |
| macOS | macOS 11.0 | Metal 2.0 | Universal Binary (arm64/x86_64) |
| Windows | Windows 10 (1809) | CUDA 11.0+, Vulkan 1.2 | DLL via NuGet |
| Linux | glibc 2.31+ | CUDA 11.0+, Vulkan 1.2 | Shared Object |
| Web | Chrome 119+, Firefox 120+ | WebGPU (experimental) | WASM Module |

### 1.4 Supported Model Architectures

DartLLM supports all model architectures compatible with the GGUF format through the llama.cpp backend:

**Text Generation Models:**
- LLaMA family (1, 2, 3, 3.1, 3.2)
- Mistral and Mixtral
- Phi (1, 2, 3, 3.5)
- Qwen (1, 1.5, 2, 2.5)
- Gemma (1, 2)
- DeepSeek (v1, v2, v3)
- Command R and Command R+
- Falcon
- StableLM
- RWKV
- Mamba

**Multimodal Models (Vision):**
- LLaVA (1.5, 1.6, NeXT)
- Qwen-VL and Qwen2-VL
- MiniCPM-V
- InternVL
- Moondream

**Embedding Models:**
- Nomic Embed
- BGE family
- E5 family
- GTE family

---

## 2. Architecture Overview

### 2.1 Layer Structure

DartLLM employs a four-layer architecture designed for maintainability and platform abstraction:

```
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                        │
│         (User code, Flutter widgets, business logic)         │
├─────────────────────────────────────────────────────────────┤
│                      Public API Layer                        │
│    (DartLLM, LLMModel, ChatMessage, ModelConfig classes)    │
├─────────────────────────────────────────────────────────────┤
│                    Platform Bridge Layer                     │
│     (FFI bindings, WASM bindings, Isolate management)       │
├─────────────────────────────────────────────────────────────┤
│                      Native Core Layer                       │
│           (C++ wrapper, llama.cpp, GGML backend)            │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Component Responsibilities

**Public API Layer**

This layer provides the developer-facing interface. All classes in this layer are designed for ease of use and follow Dart conventions. The layer handles parameter validation, type conversion, and documentation.

**Platform Bridge Layer**

This layer abstracts platform-specific implementation details. On native platforms (Android, iOS, macOS, Windows, Linux), it uses Dart FFI to communicate with compiled C++ code. On web, it uses JavaScript interop to communicate with WASM modules. This layer also manages isolate-based execution to prevent UI thread blocking.

**Native Core Layer**

This layer contains the C++ implementation that wraps llama.cpp. It provides a stable C ABI that the Platform Bridge Layer consumes. The native core handles all inference computation, memory allocation for model weights, and GPU backend selection.

### 2.3 Threading Model

DartLLM employs a dedicated inference isolate to ensure UI responsiveness:

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   Main Isolate   │────▶│  Bridge Isolate  │────▶│   Native Thread  │
│   (UI Thread)    │◀────│  (Dart Isolate)  │◀────│   (llama.cpp)    │
└──────────────────┘     └──────────────────┘     └──────────────────┘
        │                        │                        │
        │   SendPort/           │   FFI Calls            │   GGML
        │   ReceivePort         │                        │   Operations
        │                        │                        │
```

**Main Isolate:** Handles all UI operations and user-facing API calls. Never blocks on inference operations.

**Bridge Isolate:** Manages communication between the main isolate and native code. Handles serialization of requests and responses. Maintains the inference context lifecycle.

**Native Thread:** Executes actual inference computation within llama.cpp. May spawn additional threads for parallel tensor operations based on hardware capabilities.

### 2.4 Memory Architecture

Model weights reside in native memory managed by llama.cpp. The Dart garbage collector does not track this memory. Explicit lifecycle management through the dispose pattern ensures proper cleanup.

```
┌─────────────────────────────────────────────────────────────┐
│                      Dart Heap Memory                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  LLMModel   │  │ ChatMessage │  │ Response Objects    │  │
│  │  (wrapper)  │  │  (copies)   │  │ (String, List)      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                     Native Heap Memory                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Model     │  │     KV      │  │    Scratch          │  │
│  │   Weights   │  │    Cache    │  │    Buffers          │  │
│  │  (mmap'd)   │  │             │  │                     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                      GPU Memory (VRAM)                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Offloaded  │  │  Compute    │  │   Intermediate      │  │
│  │   Layers    │  │   Buffers   │  │   Tensors           │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Core Concepts

### 3.1 Models

A model in DartLLM represents a loaded neural network ready for inference. Models are loaded from GGUF files, which contain both the network architecture and quantized weights.

**Model Lifecycle:**

1. **Loading:** The model file is read from disk or downloaded from a remote source. Weights are loaded into memory (potentially memory-mapped for efficiency).

2. **Initialization:** The inference context is created with specified parameters (context size, batch size, thread count). GPU layers are offloaded if acceleration is available.

3. **Ready:** The model accepts inference requests. Multiple concurrent requests share the same model weights but use separate KV caches.

4. **Disposed:** All native resources are released. The model instance becomes invalid and cannot be reused.

### 3.2 Contexts

A context represents an active inference session with its own key-value cache. The KV cache stores computed attention states, enabling efficient generation of subsequent tokens without recomputing the entire sequence.

**Context Properties:**

- **Context Size:** Maximum number of tokens the context can hold (prompt + generated tokens combined)
- **KV Cache:** Memory storing attention key-value pairs for previously processed tokens
- **Sampling State:** Current sampler configuration and random state

### 3.3 Messages

DartLLM uses a message-based API compatible with the OpenAI chat format:

**System Message:** Establishes the assistant's behavior, personality, and constraints. Processed first in the prompt.

**User Message:** Contains input from the human user. May include text and, for multimodal models, images.

**Assistant Message:** Contains responses from the model. Used in conversation history to maintain context.

### 3.4 Tokenization

Text processing in LLMs operates on tokens, not characters. DartLLM handles tokenization internally but exposes utilities for developers who need direct access:

**Tokenization:** Converting text to token IDs using the model's vocabulary
**Detokenization:** Converting token IDs back to text
**Token Counting:** Determining the number of tokens in a text string

### 3.5 Sampling

Sampling determines how the next token is selected from the model's probability distribution:

**Temperature:** Controls randomness. Lower values (0.1-0.5) produce focused, deterministic output. Higher values (0.7-1.0) increase creativity and variability.

**Top-P (Nucleus Sampling):** Considers only tokens comprising the top P probability mass. A value of 0.9 means only tokens in the top 90% of probability are considered.

**Top-K:** Considers only the K most probable tokens. A value of 40 limits selection to the 40 highest-probability tokens.

**Repetition Penalty:** Reduces the probability of recently generated tokens to prevent loops and repetition.

---

## 4. API Reference

### 4.1 DartLLM Class

The primary entry point for the library. Provides static methods for model loading and global configuration.

**Methods:**

`loadModel`
Loads a model from a local file path or remote source. Returns a Future that resolves to an LLMModel instance.

Parameters:
- `path` (String, optional): Absolute path to a local GGUF file
- `huggingFaceRepo` (String, optional): HuggingFace repository identifier (format: "owner/repo")
- `huggingFaceFile` (String, optional): Specific GGUF file within the repository
- `modelUrl` (String, optional): Direct URL to a GGUF file
- `config` (ModelConfig, optional): Configuration options for model loading
- `onProgress` (Function, optional): Callback invoked during download with progress percentage (0.0 to 1.0)

Returns: `Future<LLMModel>`

Throws:
- `ModelNotFoundException`: The specified path or URL does not exist
- `InvalidModelException`: The file is not a valid GGUF model
- `InsufficientMemoryException`: Device lacks sufficient memory to load the model
- `DownloadException`: Network error during remote model download

`listCachedModels`
Returns a list of models currently stored in the local cache.

Returns: `Future<List<CachedModelInfo>>`

`clearCache`
Removes all cached models or a specific model from local storage.

Parameters:
- `modelId` (String, optional): Specific model to remove. If null, clears entire cache.

Returns: `Future<void>`

`setGlobalConfig`
Applies configuration that affects all subsequently loaded models.

Parameters:
- `config` (GlobalConfig): Configuration object

### 4.2 LLMModel Class

Represents a loaded model instance capable of performing inference.

**Properties:**

`modelInfo` (ModelInfo): Metadata about the loaded model including name, parameter count, architecture, and quantization level.

`isDisposed` (bool): Whether the model has been disposed. Disposed models throw exceptions on method calls.

`contextSize` (int): Maximum context length supported by this model instance.

**Methods:**

`chat`
Generates a complete response for a conversation.

Parameters:
- `messages` (List<ChatMessage>): Conversation history including the current user message
- `config` (GenerationConfig, optional): Parameters controlling generation behavior

Returns: `Future<ChatCompletion>`

`chatStream`
Generates a streaming response, yielding tokens as they are produced.

Parameters:
- `messages` (List<ChatMessage>): Conversation history including the current user message
- `config` (GenerationConfig, optional): Parameters controlling generation behavior

Returns: `Stream<ChatCompletionChunk>`

`complete`
Generates a completion for a raw text prompt without chat formatting.

Parameters:
- `prompt` (String): Raw text prompt
- `config` (GenerationConfig, optional): Parameters controlling generation behavior

Returns: `Future<TextCompletion>`

`completeStream`
Generates a streaming completion for a raw text prompt.

Parameters:
- `prompt` (String): Raw text prompt
- `config` (GenerationConfig, optional): Parameters controlling generation behavior

Returns: `Stream<TextCompletionChunk>`

`embed`
Generates vector embeddings for input text.

Parameters:
- `text` (String): Text to embed
- `normalize` (bool, optional): Whether to L2-normalize the output vector. Defaults to true.

Returns: `Future<List<double>>`

`embedBatch`
Generates embeddings for multiple texts efficiently.

Parameters:
- `texts` (List<String>): Texts to embed
- `normalize` (bool, optional): Whether to L2-normalize output vectors. Defaults to true.

Returns: `Future<List<List<double>>>`

`countTokens`
Counts the number of tokens in the provided text using this model's tokenizer.

Parameters:
- `text` (String): Text to tokenize

Returns: `Future<int>`

`tokenize`
Converts text to token IDs.

Parameters:
- `text` (String): Text to tokenize
- `addSpecialTokens` (bool, optional): Whether to add BOS/EOS tokens. Defaults to false.

Returns: `Future<List<int>>`

`detokenize`
Converts token IDs back to text.

Parameters:
- `tokens` (List<int>): Token IDs to convert

Returns: `Future<String>`

`dispose`
Releases all native resources associated with this model. The model instance becomes invalid after this call.

Returns: `void`

### 4.3 ChatMessage Class

Represents a single message in a conversation.

**Factory Constructors:**

`ChatMessage.system(String content)`
Creates a system message that sets the assistant's behavior.

`ChatMessage.user(String content)`
Creates a user message containing text input.

`ChatMessage.userWithImage(String content, Uint8List imageData, {String mimeType})`
Creates a user message containing both text and an image for multimodal models.

`ChatMessage.assistant(String content)`
Creates an assistant message representing model output.

**Properties:**

`role` (MessageRole): The role of this message (system, user, or assistant)

`content` (String): The text content of the message

`imageData` (Uint8List?): Optional image data for multimodal messages

`imageMimeType` (String?): MIME type of the image (image/jpeg, image/png, image/webp)

### 4.4 GenerationConfig Class

Controls the behavior of text generation.

**Properties:**

`maxTokens` (int): Maximum number of tokens to generate. Default: 1024

`temperature` (double): Sampling temperature. Range: 0.0 to 2.0. Default: 0.7

`topP` (double): Nucleus sampling threshold. Range: 0.0 to 1.0. Default: 0.9

`topK` (int): Top-K sampling limit. Range: 1 to vocabulary size. Default: 40

`repetitionPenalty` (double): Penalty for repeated tokens. Range: 1.0 to 2.0. Default: 1.1

`stopSequences` (List<String>): Strings that trigger generation stop when encountered

`seed` (int?): Random seed for reproducible generation. Null for random seed.

`presencePenalty` (double): Penalty for tokens that have appeared at all. Range: 0.0 to 2.0. Default: 0.0

`frequencyPenalty` (double): Penalty based on token frequency. Range: 0.0 to 2.0. Default: 0.0

### 4.5 ModelConfig Class

Configuration for model loading behavior.

**Properties:**

`contextSize` (int): Override the model's default context size. Larger values require more memory.

`gpuLayers` (int): Number of layers to offload to GPU. Use -1 for automatic detection, 0 for CPU-only.

`threads` (int): Number of CPU threads for inference. Default: platform optimal.

`batchSize` (int): Batch size for prompt processing. Larger values use more memory but process faster.

`useMemoryMap` (bool): Whether to memory-map the model file. Reduces initial load time. Default: true.

`cacheDirectory` (String): Directory for storing downloaded models. Uses platform default if not specified.

`kvCacheType` (KVCacheType): Quantization level for the KV cache. Lower precision reduces memory at slight quality cost.

### 4.6 Response Types

**ChatCompletion**

`message` (ChatMessage): The generated assistant message

`usage` (UsageStats): Token usage statistics

`finishReason` (FinishReason): Why generation stopped (length, stop, error)

`generationTimeMs` (int): Time spent generating in milliseconds

**ChatCompletionChunk**

`delta` (MessageDelta): The incremental content in this chunk

`finishReason` (FinishReason?): Non-null only in the final chunk

**TextCompletion**

`text` (String): The generated text

`usage` (UsageStats): Token usage statistics

`finishReason` (FinishReason): Why generation stopped

**UsageStats**

`promptTokens` (int): Tokens in the input prompt

`completionTokens` (int): Tokens generated

`totalTokens` (int): Sum of prompt and completion tokens

---

## 5. Platform Integration

### 5.1 Android Integration

**Gradle Configuration**

DartLLM requires minSdkVersion 24 or higher. The package automatically includes native libraries for supported ABIs (arm64-v8a, armeabi-v7a, x86_64).

Required manifest permissions:
- `android.permission.INTERNET` (only for remote model download)

Optional manifest features:
- `android.hardware.vulkan.level` (for GPU acceleration)

**ProGuard Rules**

DartLLM includes consumer ProGuard rules. No additional configuration required.

**Memory Considerations**

Android imposes per-app memory limits that vary by device. Recommended model sizes:
- Devices with 4GB RAM: Up to 2B parameter models (Q4 quantization)
- Devices with 6GB RAM: Up to 3B parameter models (Q4 quantization)
- Devices with 8GB+ RAM: Up to 7B parameter models (Q4 quantization)

### 5.2 iOS Integration

**Podfile Requirements**

DartLLM requires iOS 14.0 or later. The package uses static linking to avoid framework signing issues.

**Info.plist Entries**

For models larger than 3GB, add the extended virtual addressing entitlement:
- Key: `com.apple.developer.kernel.extended-virtual-addressing`
- Value: `true`

**App Store Considerations**

Models bundled with the app count toward the 4GB binary size limit. Consider downloading models on first launch instead.

### 5.3 macOS Integration

**Entitlements**

For sandboxed apps using network model download:
- `com.apple.security.network.client`

For apps exceeding default memory limits:
- `com.apple.developer.kernel.extended-virtual-addressing`

**Code Signing**

DartLLM's native libraries are signed with a hardened runtime. No additional signing configuration required.

### 5.4 Windows Integration

**Visual C++ Runtime**

DartLLM requires the Visual C++ 2019 Redistributable (x64). Include this as a prerequisite in your installer.

**CUDA Support**

For CUDA acceleration, users must have CUDA 11.0+ installed separately. DartLLM detects CUDA availability at runtime and falls back to CPU/Vulkan if unavailable.

### 5.5 Linux Integration

**Shared Library Dependencies**

Required system libraries:
- glibc 2.31+
- libstdc++6
- libm
- libpthread

Optional for GPU:
- Vulkan 1.2+ loader and ICD
- CUDA 11.0+ toolkit

### 5.6 Web Integration

**Browser Requirements**

Required features:
- WebAssembly (all modern browsers)
- SharedArrayBuffer (requires cross-origin isolation headers)
- WebWorker

Optional for GPU acceleration:
- WebGPU (Chrome 119+, Firefox 120+ behind flag)

**Cross-Origin Isolation**

WASM multi-threading requires these HTTP headers:
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Embedder-Policy: require-corp`

**Performance Expectations**

Web inference is significantly slower than native platforms. Expect 2-10 tokens per second depending on model size and browser. Web support is intended for demos and development, not production workloads.

---

## 6. Model Management

### 6.1 Model Sources

**Local Files**

Load models from absolute paths on the device filesystem. The application must have read access to the specified path.

**HuggingFace Hub**

Download models directly from HuggingFace repositories. DartLLM handles authentication for public repositories. Private repositories require a token.

**Direct URLs**

Download models from any HTTP/HTTPS URL. Supports redirects and resume for interrupted downloads.

**Asset Bundle**

For Flutter apps, models can be bundled as assets. Note that bundled models increase app binary size significantly.

### 6.2 Caching

DartLLM maintains a local cache of downloaded models. The cache location is platform-specific:

- Android: `{app_data}/models/`
- iOS: `{app_support}/models/`
- macOS: `~/Library/Caches/dartllm/models/`
- Windows: `%LOCALAPPDATA%/dartllm/models/`
- Linux: `~/.cache/dartllm/models/`

Cache entries are identified by a hash of the model URL. Re-downloading the same model URL uses the cached version.

### 6.3 Model Selection Guidelines

**Mobile Devices (phones, tablets):**
- Parameter count: 0.5B to 3B
- Quantization: Q4_K_M or Q4_K_S
- Context size: 2048 to 4096
- Examples: Phi-3-mini, Qwen2-0.5B, TinyLlama

**Desktop Devices (laptops, desktops without discrete GPU):**
- Parameter count: 3B to 7B
- Quantization: Q4_K_M to Q6_K
- Context size: 4096 to 8192
- Examples: Llama-3.2-3B, Mistral-7B, Phi-3-small

**Desktop Devices (with discrete GPU, 8GB+ VRAM):**
- Parameter count: 7B to 13B
- Quantization: Q5_K_M to Q8_0
- Context size: 8192 to 16384
- Examples: Llama-3.1-8B, Qwen2.5-14B

### 6.4 Quantization Formats

GGUF supports multiple quantization levels trading quality for size:

| Format | Bits/Weight | Quality | Size (7B model) |
|--------|-------------|---------|-----------------|
| Q2_K | 2.5 | Low | ~2.5 GB |
| Q3_K_S | 3.0 | Low-Medium | ~3.0 GB |
| Q3_K_M | 3.5 | Medium | ~3.5 GB |
| Q4_K_S | 4.0 | Medium | ~4.0 GB |
| Q4_K_M | 4.5 | Medium-High | ~4.5 GB |
| Q5_K_S | 5.0 | High | ~5.0 GB |
| Q5_K_M | 5.5 | High | ~5.5 GB |
| Q6_K | 6.0 | Very High | ~6.0 GB |
| Q8_0 | 8.0 | Near Original | ~7.5 GB |
| F16 | 16.0 | Original | ~14 GB |

Q4_K_M provides the best balance of quality and size for most use cases.

---

## 7. Memory and Performance

### 7.1 Memory Requirements

Model memory consumption has three components:

**Model Weights:** Determined by parameter count and quantization. A 7B parameter Q4 model requires approximately 4GB.

**KV Cache:** Scales with context size and model dimensions. A 7B model with 4096 context requires approximately 1GB for the KV cache.

**Scratch Buffers:** Temporary computation buffers. Typically 256MB to 512MB.

Total memory formula (approximate):
```
Total = (Parameters × BitsPerWeight / 8) + (ContextSize × Layers × HeadDim × 2 × Precision / 8) + ScratchBuffer
```

### 7.2 Performance Characteristics

**Prompt Processing (Time to First Token):**

Processing speed depends on prompt length, model size, and hardware. Typical ranges:
- Mobile CPU: 10-50 tokens/second
- Desktop CPU: 50-200 tokens/second
- GPU (Metal/CUDA): 500-2000 tokens/second

**Generation Speed (Tokens per Second):**

Generation is memory-bandwidth bound. Typical ranges:
- Mobile: 5-20 tokens/second
- Desktop CPU: 10-40 tokens/second
- GPU: 30-100 tokens/second

### 7.3 Optimization Strategies

**Context Size Reduction:** Smaller context sizes reduce KV cache memory and improve cache efficiency. Use the minimum context size your application requires.

**Batch Processing:** When processing multiple independent prompts, batch them for better throughput (at the cost of latency).

**GPU Layer Offloading:** Offload as many layers to GPU as VRAM permits. Partial offloading provides proportional speedup.

**KV Cache Quantization:** Enable Q8 or Q4 KV cache quantization to reduce memory usage with minimal quality impact.

---

## 8. Configuration Reference

### 8.1 Global Configuration Options

`defaultCacheDirectory` (String): Base directory for model cache

`defaultGpuLayers` (int): Default GPU layer count for new models (-1 for auto)

`defaultThreadCount` (int): Default CPU thread count (0 for auto-detect)

`enableLogging` (bool): Enable internal debug logging

`logLevel` (LogLevel): Minimum log level to output (error, warning, info, debug)

### 8.2 Model Configuration Options

`contextSize` (int): Maximum context length. Higher values require more memory.

`gpuLayers` (int): Layers to offload to GPU. -1 for automatic, 0 for CPU-only.

`threads` (int): CPU threads for computation. 0 for automatic detection.

`batchSize` (int): Tokens processed per batch. Higher values improve prompt processing speed.

`ropeFrequencyBase` (double): RoPE frequency base override. Used for context extension.

`ropeFrequencyScale` (double): RoPE frequency scale override. Used for context extension.

`useMemoryMap` (bool): Memory-map the model file instead of loading into RAM.

`lockMemory` (bool): Lock model memory to prevent swapping. Requires elevated privileges on some platforms.

`kvCacheType` (KVCacheType): Quantization for KV cache (f16, q8_0, q4_0).

### 8.3 Generation Configuration Options

`maxTokens` (int): Maximum tokens to generate

`temperature` (double): Sampling temperature (0.0-2.0)

`topP` (double): Nucleus sampling probability mass (0.0-1.0)

`topK` (int): Top-K sampling limit

`minP` (double): Minimum probability threshold

`repetitionPenalty` (double): Penalty for repeated tokens (1.0-2.0)

`frequencyPenalty` (double): Penalty based on token frequency (0.0-2.0)

`presencePenalty` (double): Penalty for token presence (0.0-2.0)

`repeatLastN` (int): Tokens to consider for repetition penalty

`stopSequences` (List<String>): Strings that stop generation

`seed` (int): Random seed for reproducibility

`grammar` (String): GBNF grammar for constrained generation

`jsonSchema` (Map): JSON schema for structured output

---

## 9. Error Handling

### 9.1 Exception Hierarchy

```
DartLLMException (base class)
├── ModelException
│   ├── ModelNotFoundException
│   ├── InvalidModelException
│   ├── ModelVersionException
│   └── ModelCorruptedException
├── MemoryException
│   ├── InsufficientMemoryException
│   ├── MemoryAllocationException
│   └── ContextOverflowException
├── InferenceException
│   ├── GenerationException
│   ├── TokenizationException
│   └── SamplingException
├── NetworkException
│   ├── DownloadException
│   ├── ConnectionException
│   └── AuthenticationException
└── PlatformException
    ├── UnsupportedPlatformException
    ├── GpuInitializationException
    └── PermissionException
```

### 9.2 Error Recovery

**ModelNotFoundException:** Verify the file path or URL is correct. For HuggingFace models, verify the repository and filename.

**InsufficientMemoryException:** Reduce context size, use a smaller model, or close other applications. On mobile, the system may terminate the app if memory pressure is extreme.

**ContextOverflowException:** The combined prompt and generation exceeded the context size. Reduce prompt length or increase context size configuration.

**GpuInitializationException:** GPU acceleration failed. The library automatically falls back to CPU. Check that GPU drivers are installed and up to date.

### 9.3 Graceful Degradation

DartLLM implements automatic fallback for common failure scenarios:

1. GPU unavailable → Falls back to CPU
2. CUDA unavailable on Windows → Falls back to Vulkan, then CPU
3. Multi-threading unavailable on web → Falls back to single-threaded WASM
4. Memory-mapping fails → Falls back to direct loading

---

## 10. Security Considerations

### 10.1 Model Security

**Model Provenance:** Only load models from trusted sources. GGUF files can execute arbitrary computation defined by the model architecture. Malicious models could potentially cause excessive resource consumption.

**Model Tampering:** Verify model checksums when downloading from remote sources. DartLLM validates file integrity but cannot detect semantic tampering.

### 10.2 Data Privacy

**Local Processing:** All inference occurs on-device. No data is transmitted to external servers unless explicitly downloading remote models.

**Memory Residue:** Prompt and response data may remain in memory after generation completes. For sensitive applications, consider explicitly clearing conversation history and calling dispose promptly.

**Model Cache:** Downloaded models are stored unencrypted in the cache directory. On shared devices, consider implementing application-level encryption or clearing the cache when appropriate.

### 10.3 Resource Limits

**Denial of Service:** Extremely long prompts or generation requests can consume excessive resources. Implement application-level limits on prompt length and generation duration.

**Memory Exhaustion:** Loading models larger than available memory can crash the application or system. Validate available memory before loading and provide appropriate error messages.

---

## 11. Troubleshooting

### 11.1 Common Issues

**Model fails to load with "insufficient memory"**

The model requires more RAM than available. Solutions:
- Close other applications
- Use a smaller quantization (Q4_K_S instead of Q5_K_M)
- Use a smaller model (3B instead of 7B)
- Reduce context size in ModelConfig

**Generation is extremely slow**

Possible causes:
- GPU acceleration not active (check logs for backend selection)
- Model too large for hardware (causing memory swapping)
- Context size too large

Solutions:
- Verify GPU is being used via the modelInfo property
- Reduce context size
- Use smaller model or quantization

**Output quality is poor**

Possible causes:
- Model too small or heavily quantized
- Inappropriate sampling parameters
- Missing or incorrect system prompt

Solutions:
- Use larger model or higher quality quantization
- Adjust temperature (0.7 is a good starting point)
- Provide clear system instructions

**App crashes during inference on iOS**

Likely cause: Memory pressure triggering OOM termination

Solutions:
- Enable extended virtual addressing entitlement
- Use smaller model
- Monitor memory usage and implement limits

**Web version shows "SharedArrayBuffer not available"**

Cross-origin isolation headers are missing. Configure your server to send:
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Embedder-Policy: require-corp`

### 11.2 Diagnostic Tools

**Enable Debug Logging**

Activate verbose logging to diagnose issues:
- Set `enableLogging: true` in GlobalConfig
- Set `logLevel: LogLevel.debug` for maximum detail
- Logs include backend selection, memory allocation, and performance metrics

**Model Information**

Access model metadata through the `modelInfo` property to verify:
- Model architecture and parameter count
- Quantization level
- Context size and vocabulary size
- Supported features (embedding, vision)

**Performance Metrics**

The response objects include timing information:
- `generationTimeMs`: Total generation time
- `usage.promptTokens`: Input token count
- `usage.completionTokens`: Output token count

Calculate tokens per second: `completionTokens * 1000 / generationTimeMs`

---

## Appendices

### Appendix A: GGUF Format Reference

GGUF (GPT-Generated Unified Format) is a binary format for storing quantized language models. Key characteristics:

- Self-contained: All metadata, vocabulary, and weights in a single file
- Extensible: Supports arbitrary key-value metadata
- Efficient: Designed for memory-mapping and fast loading
- Versioned: Format version ensures compatibility

### Appendix B: Supported Chat Templates

DartLLM automatically applies the appropriate chat template based on model metadata:

- ChatML (default for many fine-tuned models)
- Llama 2 Chat
- Llama 3 Instruct
- Mistral Instruct
- Vicuna
- Alpaca
- Phi-3
- Qwen Chat
- Command R
- Gemma Instruct

Custom templates can be specified in GenerationConfig when needed.

### Appendix C: Glossary

**GGML:** The tensor computation library underlying llama.cpp

**GGUF:** The model file format used by DartLLM

**KV Cache:** Key-Value cache storing attention states for previously processed tokens

**Quantization:** Reducing model precision to decrease memory usage and increase speed

**Context Size:** Maximum number of tokens a model can process in a single session

**Token:** The fundamental unit of text in LLMs, typically representing word parts

**Sampling:** The process of selecting the next token from probability distribution

**BOS/EOS:** Beginning of Sequence / End of Sequence special tokens

---

*End of Technical Documentation*
