#!/bin/bash

# Define source file
SOURCE_FILE="main.v" # Replace with your main V source file
NAME="cryodb" # Replace with your main V source file

# Define output directory
OUTPUT_DIR="build"
PROJECT_DIR="."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/osx"
mkdir -p "$OUTPUT_DIR/w64"
mkdir -p "$OUTPUT_DIR/linux"
mkdir -p "$OUTPUT_DIR/js"

# Initialize build commands
declare -a BUILD_COMMANDS=(
    "v -b c -prod -shared -os linux -arch x64 -o $OUTPUT_DIR/linux/$NAME-linux-x64.so $PROJECT_DIR"
    "v -b c -prod -shared -os windows -arch x64 -o $OUTPUT_DIR/w64/$NAME-windows-x64.dll $PROJECT_DIR"
    "v -b c -prod -shared -os macos -arch x64 -o $OUTPUT_DIR/osx/$NAME-macos-x64.dylib $PROJECT_DIR"
    "v -b c -prod -shared -os linux -arch arm64 -o $OUTPUT_DIR/linux/$NAME-linux-arm64.so $PROJECT_DIR"
    "v -b c -prod -shared -os windows -arch arm64 -o $OUTPUT_DIR/w64/$NAME-windows-arm64.dll $PROJECT_DIR"
    "v -b c -prod -shared -os macos -arch arm64 -o $OUTPUT_DIR/osx/$NAME-macos-arm64.dylib $PROJECT_DIR"
    "v -b js -prod -o $OUTPUT_DIR/js/$NAME.js $PROJECT_DIR"
    "v -b js_browser -prod -o $OUTPUT_DIR/js/$NAME-browser.js $PROJECT_DIR"
    "v -b js_node -prod -o $OUTPUT_DIR/js/$NAME-node.js $PROJECT_DIR"
    "v -b js_freestanding -prod -o $OUTPUT_DIR/js/$NAME-freestanding.js $PROJECT_DIR"
    "v -b native -prod -arch x64 -os linux -o $OUTPUT_DIR/linux/$NAME-native-linux-x64.so $PROJECT_DIR"
    "v -b native -prod -arch arm64 -os linux -o $OUTPUT_DIR/linux/$NAME-native-linux-arm64.so $PROJECT_DIR"
    "v -b native -prod -arch x64 -os macos -o $OUTPUT_DIR/osx/$NAME-native-macos-x64.dylib $PROJECT_DIR"
    "v -b native -prod -arch arm64 -os macos -o $OUTPUT_DIR/osx/$NAME-native-macos-arm64.dylib $PROJECT_DIR"
    "v -b native -prod -arch arm64 -os windows -o $OUTPUT_DIR/w64/$NAME-native-windows-arm64.dll $PROJECT_DIR"
    "v -b native -prod -arch x64 -os windows -o $OUTPUT_DIR/w64/$NAME-native-windows-x64.dll $PROJECT_DIR"
    "v -b wasm -prod -os wasi -o $OUTPUT_DIR/js/$NAME.wasm $PROJECT_DIR"
    "v -b wasm -prod -os browser -o $OUTPUT_DIR/js/$NAME-browser.wasm $PROJECT_DIR"
)

# Execute build commands
for cmd in "${BUILD_COMMANDS[@]}"; do
    echo "=== Executing build: $cmd ======================================================================="
    echo "================================================================================================="
    eval "$cmd" || {
        echo "Build failed: $cmd"
    }
done

echo "All builds completed successfully!"
