#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NATIVE_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$NATIVE_DIR/build/wasm"
OUTPUT_DIR="$NATIVE_DIR/../web/lib"

if ! command -v emcc &> /dev/null; then
    echo "Error: Emscripten not found. Please install and activate emsdk:"
    echo "  git clone https://github.com/emscripten-core/emsdk.git"
    echo "  cd emsdk && ./emsdk install latest && ./emsdk activate latest"
    echo "  source emsdk_env.sh"
    exit 1
fi

echo "Building DartLLM for WebAssembly..."
echo "Emscripten: $(emcc --version | head -n1)"

if [ ! -d "$NATIVE_DIR/llama.cpp" ]; then
    echo "Error: llama.cpp not found. Please run:"
    echo "  cd $NATIVE_DIR && git submodule update --init --recursive"
    exit 1
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

emcmake cmake "$NATIVE_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DDARTLLM_BUILD_WASM=ON \
    -DLLAMA_NATIVE=OFF \
    -DLLAMA_LTO=OFF

emmake make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

mkdir -p "$OUTPUT_DIR"

if [ -f "$BUILD_DIR/dartllm.js" ]; then
    cp "$BUILD_DIR/dartllm.js" "$OUTPUT_DIR/"
    cp "$BUILD_DIR/dartllm.wasm" "$OUTPUT_DIR/"
    echo "WASM files copied to: $OUTPUT_DIR/"
else
    echo "Error: WASM build files not found"
    exit 1
fi

echo "WASM build complete!"
