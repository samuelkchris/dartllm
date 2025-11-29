#!/bin/bash
# Build script for Android (NDK)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NATIVE_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$NATIVE_DIR/build/android"
OUTPUT_DIR="$NATIVE_DIR/../android/src/main/jniLibs"

# Check for NDK
if [ -z "$ANDROID_NDK_HOME" ]; then
    if [ -z "$ANDROID_NDK" ]; then
        echo "Error: ANDROID_NDK_HOME or ANDROID_NDK environment variable not set"
        exit 1
    fi
    ANDROID_NDK_HOME="$ANDROID_NDK"
fi

echo "Building DartLLM for Android..."
echo "NDK: $ANDROID_NDK_HOME"

# Check for llama.cpp
if [ ! -d "$NATIVE_DIR/llama.cpp" ]; then
    echo "Error: llama.cpp not found. Please run:"
    echo "  cd $NATIVE_DIR && git submodule update --init --recursive"
    exit 1
fi

# ABIs to build
ABIS="arm64-v8a armeabi-v7a x86_64"

for ABI in $ABIS; do
    echo "Building for $ABI..."

    ABI_BUILD_DIR="$BUILD_DIR/$ABI"
    mkdir -p "$ABI_BUILD_DIR"
    cd "$ABI_BUILD_DIR"

    cmake "$NATIVE_DIR" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI=$ABI \
        -DANDROID_PLATFORM=android-24 \
        -DANDROID_STL=c++_shared \
        -DBUILD_SHARED_LIBS=ON \
        -DDARTLLM_VULKAN=OFF \
        -DGGML_VULKAN=OFF

    cmake --build . --config Release --parallel

    # Create output directory for this ABI
    mkdir -p "$OUTPUT_DIR/$ABI"

    # Copy library
    if [ -f "$ABI_BUILD_DIR/libllamacpp.so" ]; then
        cp "$ABI_BUILD_DIR/libllamacpp.so" "$OUTPUT_DIR/$ABI/"
        echo "Library copied to: $OUTPUT_DIR/$ABI/"
    else
        echo "Error: Library not found for $ABI"
        exit 1
    fi
done

echo "Android build complete!"
echo "Libraries are in: $OUTPUT_DIR"
