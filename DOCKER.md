# Docker Setup Guide

## Quick Start

### 1. Initial Setup (First Time Authentication)

Since Google requires authentication, you need to do this once without headless mode:

```bash
# Create necessary directories
mkdir -p photos chrome-profile

# Copy environment example
cp .env.example .env

# Build the image
docker-compose build

# Run in interactive mode to authenticate
docker-compose run --rm -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  gphotos-cdp gphotos-cdp -profile /data/profile -dldir /data/photos
```

**Note:** For truly headless servers without X11, you can:
1. Run initial authentication on your local machine
2. Copy the `chrome-profile/` directory to your server
3. Start the container in headless mode

### 2. Regular Operation (After Authentication)

```bash
# Start in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## Configuration

Edit `.env` file or `docker-compose.yml` to customize:

```bash
# Example .env
LOGLEVEL=info
WORKERS=2
FROM_DATE=2024-01-01
TO_DATE=2024-12-31
```

## Volumes

- `./photos/` - Downloaded photos (persistent)
- `./chrome-profile/` - Chrome session data (keeps you logged in)

## Advanced Usage

### Learning Mode (Create New Language)

To create translations for a new language:

```bash
# 1. Change Google account language to target language
#    https://myaccount.google.com/language

# 2. Run learning mode interactively
docker-compose run --rm -it gphotos-cdp \
  gphotos-cdp -learn -profile /data/profile -dldir /data/photos

# 3. Generated file will be in container, copy it out:
docker-compose run --rm gphotos-cdp \
  cat /home/gphotos/locales-XX.yaml > locales-XX.yaml

# 4. Test the new locale
docker-compose run --rm \
  -v $(pwd)/locales-XX.yaml:/usr/local/bin/locales.yaml:ro \
  gphotos-cdp gphotos-cdp -v -profile /data/profile -dldir /data/photos
```

See [LEARNING_MODE.md](LEARNING_MODE.md) for complete guide.

### Download Specific Album

```bash
# Set in .env
ALBUM_ID=your_album_id_here

# Or run manually
docker-compose run --rm gphotos-cdp \
  gphotos-cdp -profile /data/profile -dldir /data/photos \
  -headless -album your_album_id_here
```

### Increase Performance

```bash
# More workers for faster downloads
WORKERS=4

# Adjust memory limit in docker-compose.yml
# memory: 8G
```

### View Container Logs

```bash
# Follow logs
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100

# JSON formatted logs (for log aggregation)
JSON_LOG=true docker-compose up -d
```

### Rebuild After Code Changes

```bash
docker-compose build --no-cache
docker-compose up -d
```

## Troubleshooting

### Chrome Crashes

```bash
# Increase shared memory
# In docker-compose.yml: shm_size: '4gb'
```

### Permission Errors

```bash
# Fix ownership of volumes
sudo chown -R 1000:1000 photos chrome-profile
```

### Login Session Lost

```bash
# Remove profile and re-authenticate
rm -rf chrome-profile/
# Then run initial setup again
```

### Check Container Health

```bash
docker-compose ps
docker-compose exec gphotos-cdp ps aux
```

## Scheduling with Cron

To run periodically:

```bash
# Add to your crontab (crontab -e)
# Run every 6 hours
0 */6 * * * cd /path/to/gphotos-cdp && docker-compose up --abort-on-container-exit

# Or use systemd timer (see systemd/ directory)
```

## Security Notes

- Chrome runs as non-root user (UID 1000)
- Profile data is stored locally and persists between runs
- No credentials are stored in the Docker image
- Use `JSON_LOG=true` for production environments

## Resource Usage

Default limits:
- CPU: 1-2 cores
- Memory: 2-4 GB
- Disk: Depends on your photo library size

Adjust in `docker-compose.yml` under `deploy.resources`.
