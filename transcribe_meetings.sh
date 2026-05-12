#!/bin/bash

# --- Fail Early Configuration ---
set -e          # Exit immediately if a command exits with a non-zero status
set -u          # Treat unset variables as an error
set -o pipefail # Ensure pipe errors (transcribe | sed) are caught

# --- Configuration ---
# Using the path you confirmed works
GOWHISPER_BIN="./build"
MODEL="ggml-medium-q5_0"
SOURCE_DIR="/Users/rakeshrakshit/Downloads/attachments"
DEST_DIR="/Users/rakeshrakshit/Downloads/meetings"

# --- Cleanup Logic ---
# This function runs automatically if the script exits or crashes
cleanup() {
    if [ -n "${SERVER_PID:-}" ]; then
        echo "🛑 Shutting down server (PID: $SERVER_PID)..."
        kill "$SERVER_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT

# --- Step 1: Pre-checks ---
if [ ! -f "$GOWHISPER_BIN" ]; then
    echo "❌ Error: Binary not found at $GOWHISPER_BIN"
    exit 1
fi

mkdir -p "$DEST_DIR"

# Check if there are actually files to process before starting the server
# Use nullglob so it doesn't process the literal string "*.m4a" if empty
shopt -s nullglob
files=("$SOURCE_DIR"/*.m4a)
if [ ${#files[@]} -eq 0 ]; then
    echo "Check: No .m4a files found in $SOURCE_DIR. Nothing to do."
    exit 0
fi

# --- Step 2: Start Server ---
echo "🚀 Starting gowhisper server..."
$GOWHISPER_BIN run &
SERVER_PID=$!

# Wait for server to initialize (Medium model takes a moment to load into memory/Metal)
echo "⏳ Waiting for server to initialize..."
sleep 8 

# --- Step 3: Transcription Loop ---
for file in "${files[@]}"; do
    base_name=$(basename "$file")
    no_ext="${base_name%.*}"
    output_file="$DEST_DIR/${no_ext}_clean_text.txt"

    # Check file size (max 70 MB)
    file_size_bytes=$(stat -f%z "$file")
    max_size_bytes=$((70 * 1024 * 1024))
    if [ "$file_size_bytes" -ge "$max_size_bytes" ]; then
        echo "⚠️  Skipping $base_name (file size > 70 MB)"
        continue
    fi

    echo "──────────────────────────────────────────────────"
    echo "🎤 Transcribing: $base_name"

    # Transcribe -> Format as mm:ss <text> -> Save
    $GOWHISPER_BIN transcribe "$MODEL" "$file" --format srt | \
    awk '/^[0-9]+$/ {getline; split($0, t, " --> "); start=t[1]; getline; text=$0; split(start, ts, ","); split(ts[1], t2, ":"); mm=t2[1]; ss=t2[2]; printf("%02d:%02d %s\n", mm, ss, text)}' > "$output_file"

    echo "✅ Saved to: $output_file"

    # Move the processed file to Trash immediately after transcription
    mv "$file" ~/.Trash/
    echo "🗑️  Moved $base_name to Trash."
done

# --- Step 4: Final Cleanup ---
echo "──────────────────────────────────────────────────"
echo "🧹 All transcriptions successful."
echo "✨ Process Complete."