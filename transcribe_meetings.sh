#!/bin/bash

# Configuration
SERVER_BIN="./Users/rakeshrakshit/projects/sobdo/go-whisper/build/gowhisper"
CLI_BIN="./gowhisper"
MODEL="ggml-medium-q5_0.bin"
SOURCE_DIR="/Users/rakeshrakshit/Downloads/attachments"
DEST_DIR="/Users/rakeshrakshit/Downloads/meetings"

# 1. Ensure the destination directory exists
mkdir -p "$DEST_DIR"

# 2. Start the server in the background
echo "🚀 Starting gowhisper server..."
$SERVER_BIN run &
SERVER_PID=$!

# Give the server a few seconds to initialize Metal and load
sleep 5

# 3. Check for files in attachments
FILES=("$SOURCE_DIR"/*)
if [ ${#FILES[@]} -eq 0 ] || [ ! -e "${FILES[0]}" ]; then
    echo "⚠️  No files found in $SOURCE_DIR. Exiting."
    kill $SERVER_PID
    exit 0
fi

echo "📝 Found files. Starting transcription..."

# 4. Process each file one by one
for file in "$SOURCE_DIR"/*; do
    # Get filename without path and extension
    filename=$(basename -- "$file")
    filename_no_ext="${filename%.*}"
    
    echo "Processing: $filename"
    
    # Run transcription and pipe through your sed filter
    $CLI_BIN transcribe "$MODEL" "$file" --format text | \
    sed 's/\[.*\]  //' > "$DEST_DIR/${filename_no_ext}_clean_text.txt"
    
    echo "✅ Finished: $filename_no_ext"
done

# 5. Cleanup
echo "🧹 All tasks complete. Deleting source files..."
rm -rf "$SOURCE_DIR"/*

# 6. Stop the server
echo "🛑 Shutting down server..."
kill $SERVER_PID

echo "✨ Done. Transcripts are in $DEST_DIR"