cmake_minimum_required(VERSION 3.16)
project(dartllm VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Options
option(DARTLLM_BUILD_SHARED "Build shared library" ON)
option(DARTLLM_BUILD_WASM "Build for WebAssembly" OFF)
option(DARTLLM_METAL "Enable Metal GPU support (macOS/iOS)" OFF)
option(DARTLLM_CUDA "Enable CUDA GPU support" OFF)
option(DARTLLM_VULKAN "Enable Vulkan GPU support" OFF)
option(DARTLLM_BUILD_TESTS "Build native tests" OFF)

# Detect platform
if(DARTLLM_BUILD_WASM OR EMSCRIPTEN)
    set(DARTLLM_PLATFORM "wasm")
    set(DARTLLM_BUILD_WASM ON)
elseif(APPLE)
    if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
        set(DARTLLM_PLATFORM "ios")
    else()
        set(DARTLLM_PLATFORM "macos")
    endif()
    set(DARTLLM_METAL ON CACHE BOOL "Enable Metal" FORCE)
elseif(WIN32)
    set(DARTLLM_PLATFORM "windows")
elseif(UNIX)
    if(ANDROID)
        set(DARTLLM_PLATFORM "android")
        set(DARTLLM_VULKAN ON CACHE BOOL "Enable Vulkan" FORCE)
    else()
        set(DARTLLM_PLATFORM "linux")
    endif()
else()
    set(DARTLLM_PLATFORM "unknown")
endif()

message(STATUS "DartLLM Platform: ${DARTLLM_PLATFORM}")
message(STATUS "DartLLM Metal: ${DARTLLM_METAL}")
message(STATUS "DartLLM CUDA: ${DARTLLM_CUDA}")
message(STATUS "DartLLM Vulkan: ${DARTLLM_VULKAN}")

# llama.cpp configuration
set(LLAMA_BUILD_TESTS OFF CACHE BOOL "")
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "")
set(LLAMA_BUILD_SERVER OFF CACHE BOOL "")

if(DARTLLM_METAL)
    set(GGML_METAL ON CACHE BOOL "")
    set(GGML_METAL_EMBED_LIBRARY ON CACHE BOOL "")
endif()

if(DARTLLM_CUDA)
    set(GGML_CUDA ON CACHE BOOL "")
endif()

if(DARTLLM_VULKAN)
    set(GGML_VULKAN ON CACHE BOOL "")
endif()

# Add llama.cpp as subdirectory
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/llama.cpp/CMakeLists.txt")
    add_subdirectory(llama.cpp)
else()
    message(FATAL_ERROR "llama.cpp not found. Please run: git submodule update --init --recursive")
endif()

# DartLLM library sources
set(DARTLLM_SOURCES
    src/dartllm.cpp
)

set(DARTLLM_HEADERS
    src/dartllm.h
)

# Build library based on platform
if(DARTLLM_BUILD_WASM)
    add_executable(dartllm ${DARTLLM_SOURCES})

    set(WASM_EXPORTED_FUNCTIONS
        "_dartllm_init"
        "_dartllm_version"
        "_dartllm_llama_version"
        "_dartllm_load_model"
        "_dartllm_free_model"
        "_dartllm_get_model_info"
        "_dartllm_tokenize"
        "_dartllm_detokenize"
        "_dartllm_generate"
        "_dartllm_embed"
        "_dartllm_has_gpu_support"
        "_dartllm_gpu_backend_name"
        "_dartllm_get_vram_size"
        "_dartllm_free"
        "_dartllm_get_last_error"
        "_dartllm_clear_error"
        "_malloc"
        "_free"
    )

    string(REPLACE ";" "," WASM_EXPORTS "${WASM_EXPORTED_FUNCTIONS}")

    set_target_properties(dartllm PROPERTIES
        SUFFIX ".js"
        LINK_FLAGS "\
            -s MODULARIZE=1 \
            -s EXPORT_NAME='DartLLMWasm' \
            -s EXPORTED_FUNCTIONS='[${WASM_EXPORTS}]' \
            -s EXPORTED_RUNTIME_METHODS='[\"cwrap\",\"ccall\",\"UTF8ToString\",\"stringToUTF8\",\"lengthBytesUTF8\",\"getValue\",\"setValue\"]' \
            -s ALLOW_MEMORY_GROWTH=1 \
            -s MAXIMUM_MEMORY=4GB \
            -s ENVIRONMENT='web,worker' \
            -s FILESYSTEM=0 \
            -s FETCH=1 \
            -s SINGLE_FILE=0 \
            --pre-js ${CMAKE_CURRENT_SOURCE_DIR}/src/wasm_pre.js \
        "
    )
elseif(DARTLLM_BUILD_SHARED)
    add_library(llamacpp SHARED ${DARTLLM_SOURCES} ${DARTLLM_HEADERS})
    target_compile_definitions(llamacpp PRIVATE DARTLLM_BUILDING_DLL)
else()
    add_library(llamacpp STATIC ${DARTLLM_SOURCES} ${DARTLLM_HEADERS})
endif()

# Set target name based on build type
if(DARTLLM_BUILD_WASM)
    set(DARTLLM_TARGET dartllm)
else()
    set(DARTLLM_TARGET llamacpp)
endif()

# Include directories
target_include_directories(${DARTLLM_TARGET} PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_include_directories(${DARTLLM_TARGET} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/llama.cpp/include
    ${CMAKE_CURRENT_SOURCE_DIR}/llama.cpp/ggml/include
)

# Link llama.cpp
target_link_libraries(${DARTLLM_TARGET} PRIVATE llama)

# Platform-specific settings (skip for WASM)
if(DARTLLM_BUILD_WASM)
    # WASM settings are handled above
elseif(APPLE)
    set_target_properties(llamacpp PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION A
        MACOSX_FRAMEWORK_IDENTIFIER com.dartllm.llamacpp
        MACOSX_FRAMEWORK_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${PROJECT_VERSION}
        PUBLIC_HEADER "${DARTLLM_HEADERS}"
    )

    if(DARTLLM_METAL)
        target_link_libraries(llamacpp PRIVATE
            "-framework Metal"
            "-framework Foundation"
            "-framework MetalKit"
        )
    endif()

    # Universal binary for macOS
    if(DARTLLM_PLATFORM STREQUAL "macos" AND NOT CMAKE_OSX_ARCHITECTURES)
        set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "Build architectures" FORCE)
    endif()

elseif(WIN32)
    set_target_properties(llamacpp PROPERTIES
        WINDOWS_EXPORT_ALL_SYMBOLS OFF
        OUTPUT_NAME "llamacpp"
        PREFIX ""
    )

elseif(ANDROID)
    set_target_properties(llamacpp PROPERTIES
        OUTPUT_NAME "llamacpp"
    )

    # Link Android-specific libraries
    find_library(LOG_LIB log)
    target_link_libraries(llamacpp PRIVATE ${LOG_LIB})

elseif(UNIX)
    set_target_properties(llamacpp PROPERTIES
        OUTPUT_NAME "llamacpp"
        VERSION ${PROJECT_VERSION}
        SOVERSION 0
    )
endif()

# Compiler warnings
if(NOT DARTLLM_BUILD_WASM)
    if(MSVC)
        target_compile_options(${DARTLLM_TARGET} PRIVATE /W4)
    else()
        target_compile_options(${DARTLLM_TARGET} PRIVATE -Wall -Wextra -Wpedantic)
    endif()
endif()

# Installation
include(GNUInstallDirs)

install(TARGETS ${DARTLLM_TARGET}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    FRAMEWORK DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

if(NOT DARTLLM_BUILD_WASM)
    install(FILES ${DARTLLM_HEADERS}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endif()

# Tests
if(DARTLLM_BUILD_TESTS)
    enable_testing()
    add_subdirectory(test)
endif()

# Print configuration summary
message(STATUS "")
message(STATUS "DartLLM Configuration Summary:")
message(STATUS "  Version:      ${PROJECT_VERSION}")
message(STATUS "  Platform:     ${DARTLLM_PLATFORM}")
message(STATUS "  Build type:   ${CMAKE_BUILD_TYPE}")
message(STATUS "  Shared lib:   ${DARTLLM_BUILD_SHARED}")
message(STATUS "  WASM:         ${DARTLLM_BUILD_WASM}")
message(STATUS "  Metal:        ${DARTLLM_METAL}")
message(STATUS "  CUDA:         ${DARTLLM_CUDA}")
message(STATUS "  Vulkan:       ${DARTLLM_VULKAN}")
message(STATUS "")
