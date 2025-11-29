/**
 * @file dartllm.cpp
 * @brief DartLLM C API implementation wrapping llama.cpp
 */

#include "dartllm.h"
#include "llama.h"
#include "ggml.h"

#include <cstring>
#include <cmath>
#include <string>
#include <vector>
#include <mutex>
#include <memory>
#include <thread>

namespace {

thread_local std::string g_last_error;
bool g_initialized = false;
std::mutex g_init_mutex;
const char* VERSION = "0.1.0";

struct ModelContext {
    llama_model* model = nullptr;
    llama_context* ctx = nullptr;
    llama_sampler* sampler = nullptr;
    const llama_vocab* vocab = nullptr;
    std::string model_path;
    int32_t context_size = 0;
    int32_t n_threads = 0;

    ~ModelContext() {
        if (sampler) {
            llama_sampler_free(sampler);
        }
        if (ctx) {
            llama_free(ctx);
        }
        if (model) {
            llama_model_free(model);
        }
    }
};

void set_error(const std::string& msg) {
    g_last_error = msg;
}

void clear_error() {
    g_last_error.clear();
}

void copy_string(char* dest, size_t dest_size, const std::string& src) {
    size_t len = std::min(src.length(), dest_size - 1);
    std::memcpy(dest, src.c_str(), len);
    dest[len] = '\0';
}

int32_t get_optimal_threads() {
    int32_t n = std::thread::hardware_concurrency();
    if (n <= 2) return 1;
    if (n <= 4) return n - 1;
    return n - 2;
}

} // anonymous namespace

extern "C" {

DARTLLM_API int32_t dartllm_init(void) {
    std::lock_guard<std::mutex> lock(g_init_mutex);

    if (g_initialized) {
        return 0;
    }

    ggml_backend_load_all();
    g_initialized = true;
    clear_error();

    return 0;
}

DARTLLM_API const char* dartllm_version(void) {
    return VERSION;
}

DARTLLM_API const char* dartllm_llama_version(void) {
    return "unknown";
}

DARTLLM_API void* dartllm_load_model(
    const char* path,
    int32_t context_size,
    int32_t gpu_layers,
    int32_t threads,
    int32_t batch_size,
    int8_t use_mmap
) {
    if (!g_initialized) {
        set_error("Library not initialized. Call dartllm_init() first.");
        return nullptr;
    }

    if (!path) {
        set_error("Model path is null");
        return nullptr;
    }

    clear_error();

    auto model_ctx = std::make_unique<ModelContext>();
    model_ctx->model_path = path;

    llama_model_params model_params = llama_model_default_params();
    model_params.n_gpu_layers = (gpu_layers < 0) ? 999 : gpu_layers;
    model_params.use_mmap = use_mmap != 0;

    model_ctx->model = llama_model_load_from_file(path, model_params);
    if (!model_ctx->model) {
        set_error("Failed to load model from: " + std::string(path));
        return nullptr;
    }

    model_ctx->vocab = llama_model_get_vocab(model_ctx->model);

    int32_t model_ctx_size = llama_model_n_ctx_train(model_ctx->model);
    if (context_size <= 0) {
        context_size = model_ctx_size;
    }
    model_ctx->context_size = std::min(context_size, model_ctx_size);
    model_ctx->n_threads = (threads <= 0) ? get_optimal_threads() : threads;

    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = model_ctx->context_size;
    ctx_params.n_batch = (batch_size <= 0) ? 512 : batch_size;
    ctx_params.n_threads = model_ctx->n_threads;
    ctx_params.n_threads_batch = model_ctx->n_threads;

    model_ctx->ctx = llama_init_from_model(model_ctx->model, ctx_params);
    if (!model_ctx->ctx) {
        set_error("Failed to create context");
        return nullptr;
    }

    llama_sampler_chain_params sampler_params = llama_sampler_chain_default_params();
    model_ctx->sampler = llama_sampler_chain_init(sampler_params);

    return model_ctx.release();
}

DARTLLM_API void dartllm_free_model(void* model) {
    if (model) {
        delete static_cast<ModelContext*>(model);
    }
}

DARTLLM_API DartLLMModelInfo* dartllm_get_model_info(void* model) {
    if (!model) {
        set_error("Model handle is null");
        return nullptr;
    }

    clear_error();

    auto* ctx = static_cast<ModelContext*>(model);
    auto* info = static_cast<DartLLMModelInfo*>(std::malloc(sizeof(DartLLMModelInfo)));
    if (!info) {
        set_error("Failed to allocate model info");
        return nullptr;
    }

    std::memset(info, 0, sizeof(DartLLMModelInfo));

    char meta_buf[256];
    int32_t meta_len = llama_model_meta_val_str(ctx->model, "general.name", meta_buf, sizeof(meta_buf));
    if (meta_len > 0) {
        copy_string(info->name, sizeof(info->name), meta_buf);
    } else {
        std::string path = ctx->model_path;
        size_t last_sep = path.find_last_of("/\\");
        std::string filename = (last_sep != std::string::npos) ? path.substr(last_sep + 1) : path;
        copy_string(info->name, sizeof(info->name), filename);
    }

    meta_len = llama_model_meta_val_str(ctx->model, "general.architecture", meta_buf, sizeof(meta_buf));
    if (meta_len > 0) {
        copy_string(info->architecture, sizeof(info->architecture), meta_buf);
    } else {
        copy_string(info->architecture, sizeof(info->architecture), "unknown");
    }

    meta_len = llama_model_meta_val_str(ctx->model, "general.quantization_version", meta_buf, sizeof(meta_buf));
    if (meta_len > 0) {
        copy_string(info->quantization, sizeof(info->quantization), meta_buf);
    } else {
        copy_string(info->quantization, sizeof(info->quantization), "unknown");
    }

    info->parameter_count = llama_model_n_params(ctx->model);
    info->context_size = ctx->context_size;
    info->vocabulary_size = llama_vocab_n_tokens(ctx->vocab);
    info->embedding_size = llama_model_n_embd(ctx->model);
    info->layer_count = llama_model_n_layer(ctx->model);
    info->head_count = llama_model_n_head(ctx->model);
    info->file_size_bytes = llama_model_size(ctx->model);
    info->supports_embedding = llama_model_has_encoder(ctx->model) ? 1 : 0;
    info->supports_vision = 0;

    std::vector<char> template_buf(4096);
    int32_t template_len = llama_model_meta_val_str(
        ctx->model,
        "tokenizer.chat_template",
        template_buf.data(),
        template_buf.size()
    );
    if (template_len > 0) {
        copy_string(info->chat_template, sizeof(info->chat_template), template_buf.data());
    } else {
        info->chat_template[0] = '\0';
    }

    return info;
}

DARTLLM_API int32_t* dartllm_tokenize(
    void* model,
    const char* text,
    int8_t add_special,
    int32_t* out_length
) {
    if (!model || !text || !out_length) {
        set_error("Invalid parameters");
        return nullptr;
    }

    clear_error();

    auto* ctx = static_cast<ModelContext*>(model);
    size_t text_len = std::strlen(text);

    int32_t n_tokens = -llama_tokenize(ctx->vocab, text, text_len, nullptr, 0, add_special != 0, true);

    if (n_tokens <= 0) {
        set_error("Tokenization failed");
        return nullptr;
    }

    std::vector<llama_token> tokens(n_tokens);
    int32_t actual = llama_tokenize(ctx->vocab, text, text_len, tokens.data(), tokens.size(), add_special != 0, true);

    if (actual < 0) {
        set_error("Tokenization failed");
        return nullptr;
    }

    auto* result = static_cast<int32_t*>(std::malloc(actual * sizeof(int32_t)));
    if (!result) {
        set_error("Failed to allocate token array");
        return nullptr;
    }

    for (int32_t i = 0; i < actual; i++) {
        result[i] = tokens[i];
    }

    *out_length = actual;
    return result;
}

DARTLLM_API char* dartllm_detokenize(
    void* model,
    const int32_t* tokens,
    int32_t token_count
) {
    if (!model || !tokens || token_count <= 0) {
        set_error("Invalid parameters");
        return nullptr;
    }

    clear_error();

    auto* ctx = static_cast<ModelContext*>(model);

    std::string result;
    result.reserve(token_count * 8);

    for (int32_t i = 0; i < token_count; i++) {
        char buf[256];
        int32_t n = llama_token_to_piece(ctx->vocab, tokens[i], buf, sizeof(buf), 0, true);
        if (n > 0) {
            result.append(buf, n);
        }
    }

    char* output = static_cast<char*>(std::malloc(result.length() + 1));
    if (!output) {
        set_error("Failed to allocate output string");
        return nullptr;
    }

    std::memcpy(output, result.c_str(), result.length() + 1);
    return output;
}

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
) {
    (void)repetition_penalty;

    if (!model || !prompt_tokens || prompt_length <= 0) {
        set_error("Invalid parameters");
        return nullptr;
    }

    clear_error();

    auto* ctx = static_cast<ModelContext*>(model);

    llama_sampler_reset(ctx->sampler);
    llama_sampler_chain_add(ctx->sampler, llama_sampler_init_top_k(top_k));
    llama_sampler_chain_add(ctx->sampler, llama_sampler_init_top_p(top_p, 1));
    llama_sampler_chain_add(ctx->sampler, llama_sampler_init_min_p(min_p, 1));
    llama_sampler_chain_add(ctx->sampler, llama_sampler_init_temp(temperature));
    llama_sampler_chain_add(ctx->sampler, llama_sampler_init_dist(seed >= 0 ? seed : LLAMA_DEFAULT_SEED));

    std::vector<llama_token> prompt_vec(prompt_tokens, prompt_tokens + prompt_length);
    llama_batch batch = llama_batch_get_one(prompt_vec.data(), prompt_vec.size());

    if (llama_decode(ctx->ctx, batch) != 0) {
        set_error("Failed to process prompt");
        return nullptr;
    }

    std::vector<llama_token> generated;
    generated.reserve(max_tokens);

    int32_t finish_reason = 1;

    for (int32_t i = 0; i < max_tokens; i++) {
        llama_token new_token = llama_sampler_sample(ctx->sampler, ctx->ctx, -1);

        if (llama_vocab_is_eog(ctx->vocab, new_token)) {
            finish_reason = 0;
            break;
        }

        generated.push_back(new_token);

        llama_batch next_batch = llama_batch_get_one(&new_token, 1);

        if (llama_decode(ctx->ctx, next_batch) != 0) {
            finish_reason = 2;
            break;
        }
    }

    size_t result_size = sizeof(DartLLMGenerateResult) + generated.size() * sizeof(int32_t);
    auto* result = static_cast<DartLLMGenerateResult*>(std::malloc(result_size));
    if (!result) {
        set_error("Failed to allocate result");
        return nullptr;
    }

    result->token_count = static_cast<int32_t>(generated.size());
    result->finish_reason = finish_reason;

    for (size_t i = 0; i < generated.size(); i++) {
        result->tokens[i] = generated[i];
    }

    return result;
}

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
) {
    (void)repetition_penalty;

    if (!model || !prompt_tokens || prompt_length <= 0 || !callback) {
        set_error("Invalid parameters");
        return -1;
    }

    clear_error();

    auto* ctx = static_cast<ModelContext*>(model);

    llama_sampler_reset(ctx->sampler);
    llama_sampler_chain_add(ctx->sampler, llama_sampler_init_top_k(top_k));
    llama_sampler_chain_add(ctx->sampler, llama_sampler_init_top_p(top_p, 1));
    llama_sampler_chain_add(ctx->sampler, llama_sampler_init_min_p(min_p, 1));
    llama_sampler_chain_add(ctx->sampler, llama_sampler_init_temp(temperature));
    llama_sampler_chain_add(ctx->sampler, llama_sampler_init_dist(seed >= 0 ? seed : LLAMA_DEFAULT_SEED));

    std::vector<llama_token> prompt_vec(prompt_tokens, prompt_tokens + prompt_length);
    llama_batch batch = llama_batch_get_one(prompt_vec.data(), prompt_vec.size());

    if (llama_decode(ctx->ctx, batch) != 0) {
        set_error("Failed to process prompt");
        return -2;
    }

    int32_t finish_reason = 1;
    char token_buf[256];

    for (int32_t i = 0; i < max_tokens; i++) {
        llama_token new_token = llama_sampler_sample(ctx->sampler, ctx->ctx, -1);

        int8_t is_eog = llama_vocab_is_eog(ctx->vocab, new_token) ? 1 : 0;
        if (is_eog) {
            finish_reason = 0;
        }

        int32_t text_len = llama_token_to_piece(ctx->vocab, new_token, token_buf, sizeof(token_buf) - 1, 0, true);
        if (text_len > 0) {
            token_buf[text_len] = '\0';
        } else {
            token_buf[0] = '\0';
        }

        int32_t should_continue = callback(
            new_token,
            token_buf,
            is_eog ? 1 : 0,
            is_eog ? finish_reason : -1,
            user_data
        );

        if (is_eog || !should_continue) {
            break;
        }

        llama_batch next_batch = llama_batch_get_one(&new_token, 1);

        if (llama_decode(ctx->ctx, next_batch) != 0) {
            callback(0, "", 1, 2, user_data);
            return -3;
        }
    }

    if (finish_reason == 1) {
        callback(0, "", 1, 1, user_data);
    }

    return 0;
}

DARTLLM_API float* dartllm_embed(
    void* model,
    const int32_t* tokens,
    int32_t token_count,
    int8_t normalize,
    int32_t* out_dimension
) {
    if (!model || !tokens || token_count <= 0 || !out_dimension) {
        set_error("Invalid parameters");
        return nullptr;
    }

    clear_error();

    auto* ctx = static_cast<ModelContext*>(model);

    if (!llama_model_has_encoder(ctx->model)) {
        set_error("Model does not support embeddings");
        return nullptr;
    }

    std::vector<llama_token> token_vec(tokens, tokens + token_count);
    llama_batch batch = llama_batch_get_one(token_vec.data(), token_vec.size());

    if (llama_encode(ctx->ctx, batch) != 0) {
        set_error("Failed to encode tokens");
        return nullptr;
    }

    int32_t n_embd = llama_model_n_embd(ctx->model);
    float* embeddings = llama_get_embeddings(ctx->ctx);

    if (!embeddings) {
        set_error("Failed to get embeddings");
        return nullptr;
    }

    float* result = static_cast<float*>(std::malloc(n_embd * sizeof(float)));
    if (!result) {
        set_error("Failed to allocate embedding array");
        return nullptr;
    }

    std::memcpy(result, embeddings, n_embd * sizeof(float));

    if (normalize) {
        float norm = 0.0f;
        for (int32_t i = 0; i < n_embd; i++) {
            norm += result[i] * result[i];
        }
        norm = std::sqrt(norm);
        if (norm > 0.0f) {
            for (int32_t i = 0; i < n_embd; i++) {
                result[i] /= norm;
            }
        }
    }

    *out_dimension = n_embd;
    return result;
}

DARTLLM_API int8_t dartllm_has_gpu_support(void) {
#if defined(GGML_USE_METAL) || defined(GGML_USE_CUDA) || defined(GGML_USE_VULKAN)
    return 1;
#else
    return 0;
#endif
}

DARTLLM_API const char* dartllm_gpu_backend_name(void) {
#if defined(GGML_USE_METAL)
    return "metal";
#elif defined(GGML_USE_CUDA)
    return "cuda";
#elif defined(GGML_USE_VULKAN)
    return "vulkan";
#else
    return "cpu";
#endif
}

DARTLLM_API int64_t dartllm_get_vram_size(void) {
    return 0;
}

DARTLLM_API void dartllm_free(void* ptr) {
    std::free(ptr);
}

DARTLLM_API const char* dartllm_get_last_error(void) {
    return g_last_error.empty() ? nullptr : g_last_error.c_str();
}

DARTLLM_API void dartllm_clear_error(void) {
    clear_error();
}

} // extern "C"
