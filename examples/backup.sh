#!/bin/bash
# Example script for backing up downloaded photos
# Can be used with -run flag or scheduled separately

set -e

# Configuration
PHOTOS_DIR="${PHOTOS_DIR:-./photos}"
BACKUP_METHODS="${BACKUP_METHODS:-local}"  # local, rclone, rsync, s3

# ========================================
# Local Backup
# ========================================
backup_local() {
    local BACKUP_DIR="${BACKUP_DIR:-./backups}"
    local BACKUP_NAME="gphotos-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    echo "📦 Creating local backup: $BACKUP_NAME"
    mkdir -p "$BACKUP_DIR"
    tar czf "$BACKUP_DIR/$BACKUP_NAME" -C "$(dirname "$PHOTOS_DIR")" "$(basename "$PHOTOS_DIR")"
    
    # Keep only last 7 backups
    ls -t "$BACKUP_DIR"/gphotos-backup-*.tar.gz | tail -n +8 | xargs -r rm
    
    echo "✅ Local backup complete: $BACKUP_DIR/$BACKUP_NAME"
}

# ========================================
# Rclone Backup (Google Drive, S3, etc.)
# ========================================
backup_rclone() {
    local RCLONE_REMOTE="${RCLONE_REMOTE:-gdrive:gphotos-backup}"
    
    if ! command -v rclone &> /dev/null; then
        echo "❌ rclone not installed"
        return 1
    fi
    
    echo "☁️  Syncing to rclone remote: $RCLONE_REMOTE"
    rclone sync "$PHOTOS_DIR" "$RCLONE_REMOTE" \
        --progress \
        --stats 1m \
        --exclude ".DS_Store" \
        --exclude "Thumbs.db"
    
    echo "✅ Rclone sync complete"
}

# ========================================
# Rsync Backup (to remote server)
# ========================================
backup_rsync() {
    local RSYNC_DEST="${RSYNC_DEST:-user@backup-server:/backups/gphotos/}"
    
    if ! command -v rsync &> /dev/null; then
        echo "❌ rsync not installed"
        return 1
    fi
    
    echo "🔄 Syncing to remote: $RSYNC_DEST"
    rsync -avz --delete \
        --exclude ".DS_Store" \
        --exclude "Thumbs.db" \
        "$PHOTOS_DIR/" "$RSYNC_DEST"
    
    echo "✅ Rsync complete"
}

# ========================================
# S3 Backup (AWS S3 or compatible)
# ========================================
backup_s3() {
    local S3_BUCKET="${S3_BUCKET:-s3://my-bucket/gphotos-backup}"
    
    if ! command -v aws &> /dev/null; then
        echo "❌ aws-cli not installed"
        return 1
    fi
    
    echo "☁️  Syncing to S3: $S3_BUCKET"
    aws s3 sync "$PHOTOS_DIR" "$S3_BUCKET" \
        --delete \
        --storage-class STANDARD_IA \
        --exclude ".DS_Store" \
        --exclude "Thumbs.db"
    
    echo "✅ S3 sync complete"
}

# ========================================
# Statistics
# ========================================
show_stats() {
    echo ""
    echo "📊 Backup Statistics"
    echo "===================="
    local TOTAL_FILES=$(find "$PHOTOS_DIR" -type f | wc -l)
    local TOTAL_SIZE=$(du -sh "$PHOTOS_DIR" | cut -f1)
    local PHOTOS=$(find "$PHOTOS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | wc -l)
    local VIDEOS=$(find "$PHOTOS_DIR" -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" \) | wc -l)
    
    echo "Total files: $TOTAL_FILES"
    echo "Total size: $TOTAL_SIZE"
    echo "Photos: $PHOTOS"
    echo "Videos: $VIDEOS"
    echo "===================="
    echo ""
}

# ========================================
# Main
# ========================================
main() {
    echo "🚀 Starting gphotos-cdp backup"
    echo "Photos directory: $PHOTOS_DIR"
    echo "Backup methods: $BACKUP_METHODS"
    echo ""
    
    # Check if photos directory exists
    if [ ! -d "$PHOTOS_DIR" ]; then
        echo "❌ Photos directory not found: $PHOTOS_DIR"
        exit 1
    fi
    
    # Perform backups
    IFS=',' read -ra METHODS <<< "$BACKUP_METHODS"
    for method in "${METHODS[@]}"; do
        method=$(echo "$method" | xargs)  # trim whitespace
        case "$method" in
            local)
                backup_local
                ;;
            rclone)
                backup_rclone
                ;;
            rsync)
                backup_rsync
                ;;
            s3)
                backup_s3
                ;;
            *)
                echo "⚠️  Unknown backup method: $method"
                ;;
        esac
    done
    
    # Show statistics
    show_stats
    
    echo "🎉 Backup complete!"
}

# Run if executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" -eq "$0" ]; then
    main "$@"
fi
