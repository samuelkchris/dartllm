/**
 * @file dartllm.h
 * @brief C API for DartLLM - Dart/Flutter llama.cpp bindings
 *
 * This header defines the C ABI that the Dart FFI layer consumes.
 * All functions use C linkage and simple types for cross-language compatibility.
 *
 * Memory Management:
 * - Pointers returned by functions must be freed with dartllm_free()
 * - Model handles must be freed with dartllm_free_model()
 * - Strings are null-terminated UTF-8
 *
 * Thread Safety:
 * - dartllm_init() must be called once before other functions
 * - Model operations are thread-safe per model handle
 * - Multiple models can be loaded concurrently
 */

#ifndef DARTLLM_H
#define DARTLLM_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Platform-specific export macros */
#if defined(_WIN32) || defined(_WIN64)
    #ifdef DARTLLM_BUILDING_DLL
        #define DARTLLM_API __declspec(dllexport)
    #else
        #define DARTLLM_API __declspec(dllimport)
    #endif
#else
    #define DARTLLM_API __attribute__((visibility("default")))
#endif

/**
 * Model information structure.
 *
 * Returned by dartllm_get_model_info(). All strings are null-terminated.
 * The structure uses fixed-size arrays for ABI stability.
 */
typedef struct DartLLMModelInfo {
    /** Model name from GGUF metadata (max 255 chars + null) */
    char name[256];

    /** Total parameter count */
    int64_t parameter_count;

    /** Architecture name (e.g., "llama", "mistral") */
    char architecture[64];

    /** Quantization format (e.g., "Q4_K_M", "Q8_0") */
    char quantization[32];

    /** Maximum context size in tokens */
    int32_t context_size;

    /** Vocabulary size */
    int32_t vocabulary_size;

    /** Embedding dimension */
    int32_t embedding_size;

    /** Number of transformer layers */
    int32_t layer_count;

    /** Number of attention heads */
    int32_t head_count;

    /** Model file size in bytes */
    int64_t file_size_bytes;

    /** Non-zero if model supports embedding generation */
    int8_t supports_embedding;

    /** Non-zero if model supports vision/multimodal */
    int8_t supports_vision;

    /** Chat template from GGUF metadata (may be empty) */
    char chat_template[4096];
} DartLLMModelInfo;

/**
 * Generation result structure.
 *
 * Returned by dartllm_generate(). Contains generated tokens and metadata.
 * Variable-length tokens array follows the fixed fields.
 */
typedef struct DartLLMGenerateResult {
    /** Number of tokens generated */
    int32_t token_count;

    /**
     * Finish reason:
     * - 0: stop (hit stop token or sequence)
     * - 1: length (hit max_tokens limit)
     * - 2: error (generation failed)
     */
    int32_t finish_reason;

    /** Generated token IDs (variable length, token_count elements) */
    int32_t tokens[];
} DartLLMGenerateResult;

/* ============================================================================
 * Library Initialization
 * ============================================================================ */

/**
 * Initialize the DartLLM library.
 *
 * Must be called once before any other functions. Initializes the llama.cpp
 * backend, detects available hardware acceleration, and sets up logging.
 *
 * @return 0 on success, non-zero error code on failure
 */
DARTLLM_API int32_t dartllm_init(void);

/**
 * Get the library version string.
 *
 * @return Version string (e.g., "0.1.0"). Do not free.
 */
DARTLLM_API const char* dartllm_version(void);

/**
 * Get the llama.cpp backend version.
 *
 * @return llama.cpp version string. Do not free.
 */
DARTLLM_API const char* dartllm_llama_version(void);

/* ============================================================================
 * Model Loading and Management
 * ============================================================================ */

/**
 * Load a model from a GGUF file.
 *
 * @param path          Absolute path to the GGUF model file (UTF-8)
 * @param context_size  Context size in tokens (0 for model default)
 * @param gpu_layers    Number of layers to offload to GPU (-1 for auto, 0 for CPU-only)
 * @param threads       Number of CPU threads (0 for auto-detect)
 * @param batch_size    Batch size for prompt processing (0 for default)
 * @param use_mmap      Non-zero to memory-map the model file
 *
 * @return Opaque model handle, or NULL on failure
 */
DARTLLM_API void* dartllm_load_model(
    const char* path,
    int32_t context_size,
    int32_t gpu_layers,
    int32_t threads,
    int32_t batch_size,
    int8_t use_mmap
);

/**
 * Unload a model and free all associated resources.
 *
 * @param model Model handle from dartllm_load_model()
 */
DARTLLM_API void dartllm_free_model(void* model);

/**
 * Get information about a loaded model.
 *
 * @param model Model handle from dartllm_load_model()
 *
 * @return Pointer to DartLLMModelInfo, or NULL on failure.
 *         Must be freed with dartllm_free().
 */
DARTLLM_API DartLLMModelInfo* dartllm_get_model_info(void* model);

/* ============================================================================
 * Tokenization
 * ============================================================================ */

/**
 * Tokenize text to token IDs.
 *
 * @param model         Model handle
 * @param text          Input text (UTF-8, null-terminated)
 * @param add_special   Non-zero to add BOS/EOS tokens
 * @param out_length    Output: number of tokens produced
 *
 * @return Array of token IDs, or NULL on failure.
 *         Must be freed with dartllm_free().
 */
DARTLLM_API int32_t* dartllm_tokenize(
    void* model,
    const char* text,
    int8_t add_special,
    int32_t* out_length
);

/**
 * Convert token IDs back to text.
 *
 * @param model         Model handle
 * @param tokens        Array of token IDs
 * @param token_count   Number of tokens
 *
 * @return UTF-8 string, or NULL on failure.
 *         Must be freed with dartllm_free().
 */
DARTLLM_API char* dartllm_detokenize(
    void* model,
    const int32_t* tokens,
    int32_t token_count
);

/* ============================================================================
 * Text Generation
 * ============================================================================ */

/**
 * Generate tokens from a prompt.
 *
 * @param model             Model handle
 * @param prompt_tokens     Input token IDs
 * @param prompt_length     Number of prompt tokens
 * @param max_tokens        Maximum tokens to generate
 * @param temperature       Sampling temperature (0.0-2.0)
 * @param top_p             Nucleus sampling threshold (0.0-1.0)
 * @param top_k             Top-K sampling limit
 * @param min_p             Minimum probability threshold
 * @param repetition_penalty Penalty for repeated tokens (1.0-2.0)
 * @param seed              Random seed (-1 for random)
 *
 * @return Generation result, or NULL on failure.
 *         Must be freed with dartllm_free().
 */
DARTLLM_API DartLLMGenerateResult* dartllm_generate(
    void* model,
    const int32_t* prompt_tokens,
    int32_t prompt_length,
    int32_t max_tokens,
    float temperature,
    float top_p,
    int32_t top_k,
    float min_p,
    float repetition_penalty,
    int32_t seed
);

/* ============================================================================
 * Streaming Generation
 * ============================================================================ */

/**
 * Callback function type for streaming token generation.
 *
 * @param token     Generated token ID
 * @param text      Token text (UTF-8, null-terminated)
 * @param is_final  Non-zero if this is the last token
 * @param finish_reason  0=stop, 1=length, 2=error (only valid when is_final)
 * @param user_data User-provided context pointer
 *
 * @return Non-zero to continue generation, zero to abort
 */
typedef int32_t (*DartLLMStreamCallback)(
    int32_t token,
    const char* text,
    int8_t is_final,
    int32_t finish_reason,
    void* user_data
);

/**
 * Generate tokens with streaming callback.
 *
 * Calls the callback for each generated token. Generation continues
 * until max_tokens is reached, a stop token is hit, or the callback
 * returns zero.
 *
 * @param model             Model handle
 * @param prompt_tokens     Input token IDs
 * @param prompt_length     Number of prompt tokens
 * @param max_tokens        Maximum tokens to generate
 * @param temperature       Sampling temperature (0.0-2.0)
 * @param top_p             Nucleus sampling threshold (0.0-1.0)
 * @param top_k             Top-K sampling limit
 * @param min_p             Minimum probability threshold
 * @param repetition_penalty Penalty for repeated tokens (1.0-2.0)
 * @param seed              Random seed (-1 for random)
 * @param callback          Streaming callback function
 * @param user_data         User context passed to callback
 *
 * @return 0 on success, non-zero error code on failure
 */
DARTLLM_API int32_t dartllm_generate_stream(
    void* model,
    const int32_t* prompt_tokens,
    int32_t prompt_length,
    int32_t max_tokens,
    float temperature,
    float top_p,
    int32_t top_k,
    float min_p,
    float repetition_penalty,
    int32_t seed,
    DartLLMStreamCallback callback,
    void* user_data
);

/* ============================================================================
 * Embeddings
 * ============================================================================ */

/**
 * Generate embeddings for tokens.
 *
 * @param model         Model handle
 * @param tokens        Input token IDs
 * @param token_count   Number of tokens
 * @param normalize     Non-zero to L2-normalize the output
 * @param out_dimension Output: embedding dimension
 *
 * @return Array of floats (embedding vector), or NULL on failure.
 *         Must be freed with dartllm_free().
 */
DARTLLM_API float* dartllm_embed(
    void* model,
    const int32_t* tokens,
    int32_t token_count,
    int8_t normalize,
    int32_t* out_dimension
);

/* ============================================================================
 * Hardware Detection
 * ============================================================================ */

/**
 * Check if GPU acceleration is available.
 *
 * @return Non-zero if GPU is available
 */
DARTLLM_API int8_t dartllm_has_gpu_support(void);

/**
 * Get the name of the active GPU backend.
 *
 * @return Backend name ("metal", "cuda", "vulkan", "cpu"). Do not free.
 */
DARTLLM_API const char* dartllm_gpu_backend_name(void);

/**
 * Get available VRAM in bytes.
 *
 * @return VRAM size, or 0 if GPU not available
 */
DARTLLM_API int64_t dartllm_get_vram_size(void);

/* ============================================================================
 * Memory Management
 * ============================================================================ */

/**
 * Free memory allocated by DartLLM functions.
 *
 * @param ptr Pointer returned by dartllm_* functions
 */
DARTLLM_API void dartllm_free(void* ptr);

/* ============================================================================
 * Error Handling
 * ============================================================================ */

/**
 * Get the last error message.
 *
 * @return Error message string, or NULL if no error. Do not free.
 */
DARTLLM_API const char* dartllm_get_last_error(void);

/**
 * Clear the last error.
 */
DARTLLM_API void dartllm_clear_error(void);

#ifdef __cplusplus
}
#endif

#endif /* DARTLLM_H */
