#!/bin/bash

# Enable safe scripting
set -euo pipefail

# Validate required commands
for cmd in realpath mogrify zip unzip mktemp find; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: The command '$cmd' is not installed. Please install it before running the script."
        exit 1
    fi
done

# Validate input arguments
if [[ $# -lt 1 || ! -f "$1" || "${1##*.}" != "epub" ]]; then
    echo "Usage: $0 <file.epub> [image_threshold (128k)] [quality (90)] [image_width (650)]"
    exit 1
fi

# Configurable variables
ORIGINAL_EPUB_FILE="$(realpath "$1")"
ORIGINAL_EPUB_DIR="$(dirname "$ORIGINAL_EPUB_FILE")"
IMAGE_THRESHOLD=${2:-128k}   # Minimum image size to optimize (default: 128k)
QUALITY=${3:-90}             # Image compression quality (default: 90)
IMAGE_WIDTH=${4:-650}        # Image width for resizing (default: 650 pixels)

# Create a temporary working directory
tmpdir=$(mktemp -d)

# Cleanup function
function cleanup {
    rm -rf "$tmpdir"
}
trap cleanup ERR EXIT

# Extract the EPUB file into the temporary directory
unzip -q "$ORIGINAL_EPUB_FILE" -d "$tmpdir"

# Optimize JPG images
find "$tmpdir" -type f -name "*.jpg" -size +"$IMAGE_THRESHOLD" -exec mogrify -format jpg -quality "$QUALITY" -resize "$IMAGE_WIDTH" {} \;

# Optimize PNG images
find "$tmpdir" -type f -name "*.png" -size +"$IMAGE_THRESHOLD" -exec mogrify -format png -quality "$QUALITY" -resize "$IMAGE_WIDTH" {} \;

# Create the compressed EPUB file
compressed_epub="compressed_$(basename "$ORIGINAL_EPUB_FILE")"
temp_epub="$tmpdir/$compressed_epub"
cp "$ORIGINAL_EPUB_FILE" "$temp_epub"
cd "$tmpdir"
zip -qru "$compressed_epub" .

# Move the compressed file to the original directory
cp "$temp_epub" "$ORIGINAL_EPUB_DIR"

# Display size statistics
original_size=$(du -h "$ORIGINAL_EPUB_FILE" | cut -f1)
compressed_size=$(du -h "$ORIGINAL_EPUB_DIR/$compressed_epub" | cut -f1)
echo "Original file: $ORIGINAL_EPUB_FILE ($original_size)"
echo "Compressed file: $ORIGINAL_EPUB_DIR/$compressed_epub ($compressed_size)"
echo "Optimization complete."
