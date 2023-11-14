#!/bin/bash

# Check if an environment name is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [environment]"
  exit 1
fi

ENV=$1

# Specify the entry point file based on the environment
MAIN_FILE="main_$ENV.dart"

# Check if the entry point file exists
if [ ! -f "lib/$MAIN_FILE" ]; then
  echo "Entry point file lib/$MAIN_FILE does not exist."
  exit 1
fi

# Build the Flutter web app
echo "Building for environment: $ENV"
flutter build web --release --web-renderer html -t lib/$MAIN_FILE

# Move the build output to the specified directory
OUTPUT_DIR="build/$ENV/web"
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR
mv build/web/* $OUTPUT_DIR

echo "Build complete. Output directory: $OUTPUT_DIR"
