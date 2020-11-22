#! /usr/bin/env bash

set -euo pipefail

BASE_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_DIRECTORY="$BASE_DIRECTORY/source"
OUTPUT_DIRECTORY="$BASE_DIRECTORY/optimised"
SVGO="$BASE_DIRECTORY/node_modules/.bin/svgo"
INKSCAPE="/Applications/Inkscape.app/Contents/MacOS/inkscape"

function main {
  prepareOutputDirectory
  optimise "$INPUT_DIRECTORY/horizontal-for-white-background.svg"
  optimise "$INPUT_DIRECTORY/icon.svg"
  optimise "$INPUT_DIRECTORY/vertical-for-white-background.svg"
  optimiseForBlackBackground "$INPUT_DIRECTORY/horizontal-for-white-background.svg" "$OUTPUT_DIRECTORY/horizontal-for-black-background.svg"
  optimiseForBlackBackground "$INPUT_DIRECTORY/vertical-for-white-background.svg" "$OUTPUT_DIRECTORY/vertical-for-black-background.svg"
}

function prepareOutputDirectory {
  echo "Cleaning up existing output..."
  rm -rf "$OUTPUT_DIRECTORY"

  echo "Creating output directory ($OUTPUT_DIRECTORY)..."
  mkdir -p "$OUTPUT_DIRECTORY"
}

function optimise {
  input=$1
  output="$OUTPUT_DIRECTORY/$(basename "$input")"

  echo "Optimising $input..."
  cat "$input" | convertTextToPathAndOptimise "$output"
}

function optimiseForBlackBackground {
  input=$1
  output=$2

  echo "Optimising $input for black background..."
  sed "s/#555555/#ffffff/g" "$input" | convertTextToPathAndOptimise "$output"
}

function convertTextToPathAndOptimise {
  output=$1

  "$INKSCAPE" --export-filename="$output" --export-area-page --export-text-to-path --export-type=svg --pipe
  "$SVGO" --input "$output" --output "$output" --quiet
}

# Stage 3: export SVG as PNG with white background
# Stage 4: export SVG as PNG with transparent background
# Stage 4: export SVG as PNG with black background

main
