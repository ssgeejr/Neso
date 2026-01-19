!/bin/bash

# Define the target directory (Updated to match the actual model)
TARGET_DIR="/home/vmlinux/models/TheDrummer_Behemoth"
mkdir -p "$TARGET_DIR"

echo "🚀 Starting download for TheDrummer Behemoth (Bartowski Q5_K_M)..."
echo "📂 Saving to: $TARGET_DIR"

# URLs
URL1="https://huggingface.co/bartowski/TheDrummer_Behemoth-X-123B-v2-GGUF/resolve/main/TheDrummer_Behemoth-X-123B-v2-Q5_K_M/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00001-of-00003.gguf"
URL2="https://huggingface.co/bartowski/TheDrummer_Behemoth-X-123B-v2-GGUF/resolve/main/TheDrummer_Behemoth-X-123B-v2-Q5_K_M/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00002-of-00003.gguf"
URL3="https://huggingface.co/bartowski/TheDrummer_Behemoth-X-123B-v2-GGUF/resolve/main/TheDrummer_Behemoth-X-123B-v2-Q5_K_M/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00003-of-00003.gguf"

# Download Part 1
echo "⬇️  Downloading Part 1 of 3..."
curl --limit-rate 75M -C - -L -o "$TARGET_DIR/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00001-of-00003.gguf" "$URL1"

# Download Part 2
echo "⬇️  Downloading Part 2 of 3..."
curl --limit-rate 75M -C - -L -o "$TARGET_DIR/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00002-of-00003.gguf" "$URL2"

# Download Part 3
echo "⬇️  Downloading Part 3 of 3..."
curl --limit-rate 75M -C - -L -o "$TARGET_DIR/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00003-of-00003.gguf" "$URL3"

echo ""
echo "🔗 Merging parts using llama-gguf-split (The Proper Way)..."
INPUT_FILE="/models/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00001-of-00003.gguf"
OUTPUT_FILE="/models/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-Combined.gguf"

# We use the container to run the merge tool since it's pre-installed there
docker run --rm \
  -v "$TARGET_DIR:/models" \
  kyuz0/amd-strix-halo-toolboxes:rocm7-nightlies \
  llama-gguf-split --merge "$INPUT_FILE" "$OUTPUT_FILE"

# Check the exit code of the docker command
if [ $? -eq 0 ]; then
    echo "✅ Success! Proper Combined file created: $TARGET_DIR/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-Combined.gguf"
    echo "🧹 Cleaning up the 3 split parts to save space..."
    rm "$TARGET_DIR/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00001-of-00003.gguf"
    rm "$TARGET_DIR/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00002-of-00003.gguf"
    rm "$TARGET_DIR/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00003-of-00003.gguf"
    echo "✨ All done! Ready to share."
else
    echo "❌ Error: Merge failed. I kept the split files just in case."
fi








