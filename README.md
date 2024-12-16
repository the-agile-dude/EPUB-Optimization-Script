# EPUB Optimization Script

This script optimizes the images within an EPUB file to reduce its overall size, producing a compressed version of the original EPUB.

## Features
- **Automated EPUB Optimization**: Extracts the content of an EPUB, compresses and resizes large images, and reassembles the optimized EPUB.
- **Configurable Parameters**: Allows setting custom thresholds for image size, compression quality, and image width.
- **Error Handling**: Ensures cleanup of temporary files even if an error occurs.
- **Space-Saving Statistics**: Displays the size of the original and compressed EPUB files.

---

## Requirements

Ensure the following commands are installed and available in your system:

- `realpath`
- `mogrify` (part of ImageMagick)
- `zip`
- `unzip`
- `mktemp`
- `find`

You can install these tools using your package manager. For example, on Debian-based systems:

```bash
sudo apt update
sudo apt install imagemagick zip unzip
