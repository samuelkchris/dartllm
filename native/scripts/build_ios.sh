#!/bin/bash
# Build script for iOS (XCFramework with Metal support)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NATIVE_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$NATIVE_DIR/build/ios"
OUTPUT_DIR="$NATIVE_DIR/../ios/Frameworks"

echo "Building DartLLM for iOS..."

# Check for llama.cpp
if [ ! -d "$NATIVE_DIR/llama.cpp" ]; then
    echo "Error: llama.cpp not found. Please run:"
    echo "  cd $NATIVE_DIR && git submodule update --init --recursive"
    exit 1
fi

# Build for device (arm64)
echo "Building for iOS device (arm64)..."
BUILD_DIR_DEVICE="$BUILD_DIR/device"
mkdir -p "$BUILD_DIR_DEVICE"
cd "$BUILD_DIR_DEVICE"

cmake "$NATIVE_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
    -DDARTLLM_BUILD_SHARED=ON \
    -DDARTLLM_METAL=ON

cmake --build . --config Release --parallel

# Build for simulator (arm64)
echo "Building for iOS simulator (arm64)..."
BUILD_DIR_SIM="$BUILD_DIR/simulator"
mkdir -p "$BUILD_DIR_SIM"
cd "$BUILD_DIR_SIM"

cmake "$NATIVE_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_SYSROOT=iphonesimulator \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
    -DDARTLLM_BUILD_SHARED=ON \
    -DDARTLLM_METAL=ON

cmake --build . --config Release --parallel

# Create XCFramework
echo "Creating XCFramework..."
mkdir -p "$OUTPUT_DIR"
rm -rf "$OUTPUT_DIR/llamacpp.xcframework"

xcodebuild -create-xcframework \
    -framework "$BUILD_DIR_DEVICE/llamacpp.framework" \
    -framework "$BUILD_DIR_SIM/llamacpp.framework" \
    -output "$OUTPUT_DIR/llamacpp.xcframework"

echo "XCFramework created at: $OUTPUT_DIR/llamacpp.xcframework"
echo "iOS build complete!"
