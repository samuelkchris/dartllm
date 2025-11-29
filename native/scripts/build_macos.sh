#!/bin/bash
# Build script for macOS (Universal Binary with Metal support)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NATIVE_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$NATIVE_DIR/build/macos"
OUTPUT_DIR="$NATIVE_DIR/../macos/Frameworks"

echo "Building DartLLM for macOS..."
echo "Native dir: $NATIVE_DIR"
echo "Build dir: $BUILD_DIR"

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
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DDARTLLM_BUILD_SHARED=ON \
    -DDARTLLM_METAL=ON

# Build
cmake --build . --config Release --parallel

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Copy framework
if [ -d "$BUILD_DIR/llamacpp.framework" ]; then
    rm -rf "$OUTPUT_DIR/llamacpp.framework"
    cp -R "$BUILD_DIR/llamacpp.framework" "$OUTPUT_DIR/"
    echo "Framework copied to: $OUTPUT_DIR/llamacpp.framework"
else
    echo "Error: Framework not found at $BUILD_DIR/llamacpp.framework"
    exit 1
fi

echo "macOS build complete!"
