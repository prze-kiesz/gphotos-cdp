#!/bin/bash
# Example post-download script
# This runs after each photo is downloaded
# Usage: gphotos-cdp -dldir photos -run examples/post-download.sh

FILE="$1"

if [ -z "$FILE" ]; then
    echo "Usage: $0 <downloaded-file>"
    exit 1
fi

echo "📸 Processing downloaded file: $FILE"

# Example 1: Get file info
FILE_SIZE=$(stat -f%z "$FILE" 2>/dev/null || stat -c%s "$FILE" 2>/dev/null)
FILE_TYPE=$(file -b --mime-type "$FILE")
echo "  Size: $FILE_SIZE bytes"
echo "  Type: $FILE_TYPE"

# Example 2: Generate thumbnail (requires imagemagick)
if [[ "$FILE_TYPE" == image/* ]] && command -v convert &> /dev/null; then
    THUMB_DIR="$(dirname "$FILE")/thumbnails"
    mkdir -p "$THUMB_DIR"
    THUMB_FILE="$THUMB_DIR/$(basename "$FILE")"
    convert "$FILE" -resize 200x200 "$THUMB_FILE"
    echo "  ✓ Thumbnail created"
fi

# Example 3: Upload to backup server
# Example: rclone copy "$FILE" remote:backup/photos/

# Example 4: Add to database/index
# Example: echo "$FILE|$FILE_SIZE|$(date +%s)" >> photos.db

# Example 5: Extract EXIF data
if command -v exiftool &> /dev/null; then
    DATE_TAKEN=$(exiftool -DateTimeOriginal -s3 "$FILE" 2>/dev/null)
    if [ -n "$DATE_TAKEN" ]; then
        echo "  Date taken: $DATE_TAKEN"
    fi
fi

# Example 6: Organize by year/month
# YEAR=$(date -r "$FILE" +%Y 2>/dev/null || stat -c %y "$FILE" | cut -d- -f1)
# MONTH=$(date -r "$FILE" +%m 2>/dev/null || stat -c %y "$FILE" | cut -d- -f2)
# TARGET_DIR="organized/$YEAR/$MONTH"
# mkdir -p "$TARGET_DIR"
# cp "$FILE" "$TARGET_DIR/"

echo "  ✅ Processing complete"
