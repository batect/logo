#! /usr/bin/env bash

set -euo pipefail

BASE_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_DIRECTORY="$BASE_DIRECTORY/source"
OUTPUT_DIRECTORY="$BASE_DIRECTORY/optimised"
SVGO="$BASE_DIRECTORY/node_modules/.bin/svgo"

function main {
  prepareOutputDirectory
  optimise "$INPUT_DIRECTORY/horizontal-white-background.svg"
  optimise "$INPUT_DIRECTORY/icon.svg"
  optimise "$INPUT_DIRECTORY/vertical-white-background.svg"
}

function prepareOutputDirectory {
  echo "Cleaning up existing output..."
  rm -rf "$OUTPUT_DIRECTORY"

  echo "Creating output directory ($OUTPUT_DIRECTORY)..."
  mkdir -p "$OUTPUT_DIRECTORY"
}

function optimise {
  echo "Optimising $1..."
  "$SVGO" --input "$1" --output "$OUTPUT_DIRECTORY" --quiet
}

# Stage 1: export logo to optimised directory (eg. without Inkscape extensions), convert text to outlines in other layouts and export to optimised directory
# Stage 2: generate SVG versions for use with black background (eg. modify text to white fill)
# Stage 3: export SVG as PNG with white background and transparent background
# Stage 4: export SVG as PNG with black background

main
