#!/bin/bash
# Health check script for monitoring

set -e

PHOTOS_DIR="${PHOTOS_DIR:-/data/photos}"
MAX_AGE_HOURS="${MAX_AGE_HOURS:-24}"

# Check if process is running
if ! pgrep -f "gphotos-cdp" > /dev/null; then
    echo "ERROR: gphotos-cdp process not found"
    exit 1
fi

# Check if photos directory exists
if [ ! -d "$PHOTOS_DIR" ]; then
    echo "ERROR: Photos directory not found: $PHOTOS_DIR"
    exit 1
fi

# Check for recent activity (files modified in last N hours)
RECENT_FILES=$(find "$PHOTOS_DIR" -type f -mmin -$((MAX_AGE_HOURS * 60)) 2>/dev/null | wc -l)

if [ "$RECENT_FILES" -eq 0 ]; then
    echo "WARNING: No files downloaded in last $MAX_AGE_HOURS hours"
    # Don't exit with error - might be no new photos
fi

# Check disk space
DISK_USAGE=$(df "$PHOTOS_DIR" | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
    echo "WARNING: Disk usage high: ${DISK_USAGE}%"
fi

# Count total photos
TOTAL_PHOTOS=$(find "$PHOTOS_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.mp4" -o -iname "*.mov" \) 2>/dev/null | wc -l)
echo "OK: Process running, $TOTAL_PHOTOS photos, ${DISK_USAGE}% disk used"
exit 0
