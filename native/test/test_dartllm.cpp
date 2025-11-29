#include "../src/dartllm.h"
#include <cassert>
#include <cstring>
#include <cstdio>

void test_init() {
    printf("Testing dartllm_init...\n");
    int32_t result = dartllm_init();
    assert(result == 0);
    printf("  PASSED\n");
}

void test_version() {
    printf("Testing dartllm_version...\n");
    const char* version = dartllm_version();
    assert(version != nullptr);
    assert(strlen(version) > 0);
    printf("  Version: %s\n", version);
    printf("  PASSED\n");
}

void test_gpu_support() {
    printf("Testing dartllm_has_gpu_support...\n");
    int8_t has_gpu = dartllm_has_gpu_support();
    printf("  GPU support: %s\n", has_gpu ? "yes" : "no");
    printf("  PASSED\n");
}

void test_gpu_backend() {
    printf("Testing dartllm_gpu_backend_name...\n");
    const char* backend = dartllm_gpu_backend_name();
    assert(backend != nullptr);
    printf("  Backend: %s\n", backend);
    printf("  PASSED\n");
}

void test_error_handling() {
    printf("Testing error handling...\n");

    const char* error = dartllm_get_last_error();
    assert(error == nullptr);

    void* model = dartllm_load_model("/nonexistent/path.gguf", 0, 0, 0, 0, 1);
    assert(model == nullptr);

    error = dartllm_get_last_error();
    assert(error != nullptr);
    printf("  Expected error: %s\n", error);

    dartllm_clear_error();
    error = dartllm_get_last_error();
    assert(error == nullptr);

    printf("  PASSED\n");
}

void test_null_model_operations() {
    printf("Testing null model operations...\n");

    DartLLMModelInfo* info = dartllm_get_model_info(nullptr);
    assert(info == nullptr);

    int32_t length = 0;
    int32_t* tokens = dartllm_tokenize(nullptr, "test", 1, &length);
    assert(tokens == nullptr);

    char* text = dartllm_detokenize(nullptr, nullptr, 0);
    assert(text == nullptr);

    printf("  PASSED\n");
}

void test_free_null() {
    printf("Testing dartllm_free with null...\n");
    dartllm_free(nullptr);
    dartllm_free_model(nullptr);
    printf("  PASSED\n");
}

int main() {
    printf("=== DartLLM Native Tests ===\n\n");

    test_init();
    test_version();
    test_gpu_support();
    test_gpu_backend();
    test_error_handling();
    test_null_model_operations();
    test_free_null();

    printf("\n=== All tests passed ===\n");
    return 0;
}
