#!/bin/bash
# Build script for Linux

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NATIVE_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$NATIVE_DIR/build/linux"
OUTPUT_DIR="$NATIVE_DIR/../linux/lib"

# Parse arguments
USE_CUDA=OFF
USE_VULKAN=OFF

while [[ $# -gt 0 ]]; do
    case $1 in
        --cuda)
            USE_CUDA=ON
            shift
            ;;
        --vulkan)
            USE_VULKAN=ON
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "Building DartLLM for Linux..."
echo "CUDA: $USE_CUDA"
echo "Vulkan: $USE_VULKAN"

# Check for llama.cpp
if [ ! -d "$NATIVE_DIR/llama.cpp" ]; then
    echo "Error: llama.cpp not found. Please run:"
    echo "  cd $NATIVE_DIR && git submodule update --init --recursive"
    exit 1
fi

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure with CMake
cmake "$NATIVE_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DDARTLLM_BUILD_SHARED=ON \
    -DDARTLLM_CUDA=$USE_CUDA \
    -DDARTLLM_VULKAN=$USE_VULKAN

# Build
cmake --build . --config Release --parallel

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Copy library
if [ -f "$BUILD_DIR/libllamacpp.so" ]; then
    cp "$BUILD_DIR/libllamacpp.so"* "$OUTPUT_DIR/"
    echo "Library copied to: $OUTPUT_DIR/"
else
    echo "Error: Library not found"
    exit 1
fi

echo "Linux build complete!"
