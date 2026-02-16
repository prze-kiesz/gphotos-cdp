# Example Scripts

This directory contains example scripts for extending gphotos-cdp functionality.

## 🌍 create-polish-locale.sh

Example workflow for creating a new locale using Learning Mode.

### Usage

```bash
./examples/create-polish-locale.sh
```

Demonstrates:
- Changing Google account language
- Running learning mode
- Testing generated locale

See [LEARNING_MODE.md](../LEARNING_MODE.md) for detailed guide.

## 📦 backup.sh

Comprehensive backup script supporting multiple destinations.

### Usage

```bash
# Local backup
BACKUP_METHODS=local ./examples/backup.sh

# Rclone to Google Drive
RCLONE_REMOTE=gdrive:gphotos-backup BACKUP_METHODS=rclone ./examples/backup.sh

# Multiple methods
BACKUP_METHODS=local,rclone,s3 ./examples/backup.sh

# From Docker
docker-compose exec gphotos-cdp /examples/backup.sh
```

### Configuration

Set environment variables:

```bash
# Local backup
export BACKUP_DIR=/path/to/backups

# Rclone
export RCLONE_REMOTE=gdrive:gphotos-backup

# Rsync
export RSYNC_DEST=user@server:/backups/gphotos/

# S3
export S3_BUCKET=s3://my-bucket/gphotos
```

### Scheduled Backups

```bash
# Add to crontab
0 3 * * * cd /opt/gphotos-cdp && ./examples/backup.sh

# Or with Docker
0 3 * * * cd /opt/gphotos-cdp && docker-compose exec -T gphotos-cdp ./examples/backup.sh
```

## post-download.sh

Process each photo immediately after download.

### Usage

```bash
# Run with gphotos-cdp
gphotos-cdp -dldir photos -run examples/post-download.sh

# With Docker (add to command in docker-compose.yml)
command: >
  gphotos-cdp
  -profile /data/profile
  -dldir /data/photos
  -headless
  -run /app/examples/post-download.sh
```

### Customization

Edit the script to:
- Generate thumbnails
- Upload to cloud storage
- Extract EXIF data
- Organize by date
- Update database/index
- Send notifications

## Creating Your Own Scripts

### Template

```bash
#!/bin/bash
# Your custom script

set -e

# Get downloaded file path
FILE="$1"

# Your logic here
echo "Processing: $FILE"

# Return success
exit 0
```

### Best Practices

1. **Error Handling**: Use `set -e` and check return codes
2. **Logging**: Echo status messages for debugging
3. **Idempotent**: Script should be safe to run multiple times
4. **Fast**: Don't block for too long (downloads wait for script)
5. **Exit Codes**: Return 0 on success, non-zero on error

### Integration with Docker

Mount your script into the container:

```yaml
# docker-compose.override.yml
services:
  gphotos-cdp:
    volumes:
      - ./my-script.sh:/app/my-script.sh:ro
    command: >
      gphotos-cdp
      -profile /data/profile
      -dldir /data/photos
      -headless
      -run /app/my-script.sh
```

## More Examples

### Telegram Notifications

```bash
#!/bin/bash
FILE="$1"
TELEGRAM_BOT_TOKEN="your_token"
TELEGRAM_CHAT_ID="your_chat_id"

curl -s -X POST \
  "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  -d text="📸 Downloaded: $(basename "$FILE")"
```

### Upload to Nextcloud

```bash
#!/bin/bash
FILE="$1"
NEXTCLOUD_URL="https://nextcloud.example.com"
NEXTCLOUD_USER="user"
NEXTCLOUD_PASS="pass"

curl -u "$NEXTCLOUD_USER:$NEXTCLOUD_PASS" \
  -T "$FILE" \
  "$NEXTCLOUD_URL/remote.php/dav/files/$NEXTCLOUD_USER/Photos/$(basename "$FILE")"
```

### Convert HEIC to JPEG

```bash
#!/bin/bash
FILE="$1"

if [[ "$FILE" == *.heic ]] || [[ "$FILE" == *.HEIC ]]; then
    heif-convert "$FILE" "${FILE%.heic}.jpg"
    rm "$FILE"  # Remove original
fi
```
