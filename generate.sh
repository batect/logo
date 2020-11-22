#! /usr/bin/env bash

set -euo pipefail

BASE_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_DIRECTORY="$BASE_DIRECTORY/source"
OUTPUT_DIRECTORY="$BASE_DIRECTORY/optimised"
SVGO="$BASE_DIRECTORY/node_modules/.bin/svgo"
INKSCAPE="/Applications/Inkscape.app/Contents/MacOS/inkscape"

BLACK="#000000"
WHITE="#FFFFFF"
DPI="300"

function main {
  prepareOutputDirectory
  optimise "$INPUT_DIRECTORY/horizontal-for-white-background.svg"
  optimise "$INPUT_DIRECTORY/icon.svg"
  optimise "$INPUT_DIRECTORY/vertical-for-white-background.svg"
  optimiseForBlackBackground "$INPUT_DIRECTORY/horizontal-for-white-background.svg" "$OUTPUT_DIRECTORY/horizontal-for-black-background.svg"
  optimiseForBlackBackground "$INPUT_DIRECTORY/vertical-for-white-background.svg" "$OUTPUT_DIRECTORY/vertical-for-black-background.svg"

  exportTransparentPNG "$OUTPUT_DIRECTORY/icon.svg" "$OUTPUT_DIRECTORY/icon-on-transparent-background.png"
  exportPNG "$OUTPUT_DIRECTORY/icon.svg" "$OUTPUT_DIRECTORY/icon-on-white-background.png" "$WHITE"
  exportPNG "$OUTPUT_DIRECTORY/icon.svg" "$OUTPUT_DIRECTORY/icon-on-black-background.png" "$BLACK"

  exportTransparentPNG "$OUTPUT_DIRECTORY/horizontal-for-white-background.svg" "$OUTPUT_DIRECTORY/horizontal-on-transparent-background.png"
  exportPNG "$OUTPUT_DIRECTORY/horizontal-for-white-background.svg" "$OUTPUT_DIRECTORY/horizontal-on-white-background.png" "$WHITE"
  exportPNG "$OUTPUT_DIRECTORY/horizontal-for-black-background.svg" "$OUTPUT_DIRECTORY/horizontal-on-black-background.png" "$BLACK"

  exportTransparentPNG "$OUTPUT_DIRECTORY/vertical-for-white-background.svg" "$OUTPUT_DIRECTORY/vertical-on-transparent-background.png"
  exportPNG "$OUTPUT_DIRECTORY/vertical-for-white-background.svg" "$OUTPUT_DIRECTORY/vertical-on-white-background.png" "$WHITE"
  exportPNG "$OUTPUT_DIRECTORY/vertical-for-black-background.svg" "$OUTPUT_DIRECTORY/vertical-on-black-background.png" "$BLACK"
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

function exportPNG {
  input=$1
  output=$2
  background=$3

  echo "Exporting $input as $output..."
  "$INKSCAPE" --export-filename="$output" --export-area-page --export-background="$background" --export-type=png --export-dpi=$DPI "$input"
}

function exportTransparentPNG {
  input=$1
  output=$2

  echo "Exporting $input as $output..."
  "$INKSCAPE" --export-filename="$output" --export-area-page --export-background-opacity="0" --export-type=png --export-dpi=$DPI "$input"
}

main
