# Frequently Asked Questions (FAQ)

## General

### What is gphotos-cdp?

gphotos-cdp is a tool that automatically downloads photos from Google Photos using browser automation (Chrome DevTools Protocol). It's useful for creating local backups of your photo library.

### Is this official Google software?

No, this is an independent open-source project. It automates a Chrome browser to download photos, similar to how you would manually.

### Is it safe to use?

The tool doesn't store your credentials - you log in through a real Chrome browser. Your login session is saved locally (in `chrome-profile/`) for subsequent runs. Always keep this directory secure.

### Will Google ban my account?

The tool behaves like a regular browser user. However, Google could technically detect automation. Use responsibly and don't abuse rate limits. We haven't heard of any accounts being banned.

## Setup & Installation

### What are the system requirements?

**Docker (Recommended):**
- Docker 20.10+
- Docker Compose 2.0+
- 2-4GB RAM
- Disk space for your photos

**Native:**
- Go 1.23+
- Chrome/Chromium
- Linux, macOS, or Windows

### How do I install it?

```bash
# Quick install
git clone <repository>
cd gphotos-cdp
./install.sh
./setup-auth.sh
make up
```

See [QUICKSTART.md](QUICKSTART.md) for details.

### Can I run this on a headless server?

Yes! That's the main use case. Use Docker with headless mode. You'll need to authenticate once (see [DOCKER.md](DOCKER.md) for authentication methods).

### How do I authenticate on a headless server?

Three options:

1. **X11 Forwarding**: SSH with `-X` flag
2. **Copy Profile**: Authenticate on local machine, copy `chrome-profile/` to server
3. **VNC**: Use VNC to access server GUI

See [DOCKER.md](DOCKER.md) for step-by-step instructions.

## Usage

### How often should I run it?

Depends on your needs:
- **Real-time backup**: Every 1-2 hours
- **Daily backup**: Once per day
- **Weekly**: Once per week

Set up systemd timer or cron job for automation.

### Does it download duplicates?

No, the tool tracks what's been downloaded and skips existing files.

### Can I download specific albums only?

Yes:
```bash
gphotos-cdp -dldir photos -album YOUR_ALBUM_ID
# or with Docker:
ALBUM_ID=YOUR_ALBUM_ID make up
```

### How do I find an album ID?

1. Open album in Google Photos web interface
2. Look at URL: `https://photos.google.com/album/ALBUM_ID_HERE`
3. Copy the ID part

### Can I download photos from a specific date range?

Yes:
```bash
gphotos-cdp -from 2024-01-01 -to 2024-12-31
# or set in .env:
FROM_DATE=2024-01-01
TO_DATE=2024-12-31
```

### How many photos can I download at once?

There's no hard limit, but consider:
- Disk space availability
- Download time (can be hours for large libraries)
- Network bandwidth

Use `-workers` to control concurrent downloads (default: 1, recommended: 2-4).

## Troubleshooting

### Photos aren't downloading

**Check logs:**
```bash
make logs
```

**Common causes:**
- Login session expired → Re-authenticate
- Internet connection issues
- Google Photos UI changed → Update tool
- Insufficient disk space

### "Chrome crashed" or "Out of memory"

Increase shared memory:
```yaml
# docker-compose.yml
shm_size: '4gb'
```

Or reduce workers:
```bash
WORKERS=1 make restart
```

### Login session keeps expiring

- Check `chrome-profile/` directory permissions
- Don't delete `chrome-profile/` between runs
- Google may require re-auth periodically (security feature)

### Downloads are slow

- Increase workers: `WORKERS=4`
- Check internet speed
- Google may rate-limit aggressive downloads

### Container won't start

```bash
# Check Docker
systemctl status docker

# Rebuild
make clean
make build
make up

# Check logs
make logs
```

### Permission denied errors

```bash
# Fix ownership
sudo chown -R $USER:$USER photos chrome-profile

# Or in Docker
docker-compose exec gphotos-cdp chown -R gphotos:gphotos /data
```

## Advanced

### Can I run custom scripts on downloads?

Yes! Use the `-run` flag:
```bash
gphotos-cdp -dldir photos -run ./my-script.sh
```

See [examples/](examples/) for samples.

### Can I upload photos elsewhere automatically?

Yes, use a post-download script:
```bash
gphotos-cdp -dldir photos -run examples/backup.sh
```

Examples provided for:
- Rclone (Google Drive, S3, etc.)
- Rsync to remote server
- AWS S3
- Custom scripts

### How do I monitor it in production?

- Use `healthcheck.sh` for health monitoring
- Set up log aggregation (JSON logs with `JSON_LOG=true`)
- Monitor disk space
- Set up alerts for failures

See [DEPLOYMENT.md](DEPLOYMENT.md) for production setups.

### Can I run multiple instances?

⚠️ **Not recommended** - could cause:
- Duplicate downloads
- Account issues
- Concurrent writes

If needed, use different profiles and download directories.

### How do I update the tool?

```bash
make update
# or manually:
git pull
make rebuild
```

### Can I use a different Chrome/Chromium path?

Yes:
```bash
gphotos-cdp -execpath /path/to/chrome
```

For Docker, modify `Dockerfile` to install specific version.

## Storage & Backup

### Where are photos saved?

Default: `./photos/`

Change with:
```bash
gphotos-cdp -dldir /path/to/photos
```

### What format are photos saved in?

Original format from Google Photos (usually JPEG for photos, MP4 for videos).

### How much disk space do I need?

Check your Google Photos storage:
1. Go to photos.google.com
2. Click profile icon → Storage
3. See "Photos and videos" usage

Add 20% buffer for metadata and temporary files.

### How do I back up downloaded photos?

See [examples/backup.sh](examples/backup.sh) for automated backup scripts supporting:
- Local backup (tar.gz)
- Rclone (cloud storage)
- Rsync (remote server)
- AWS S3

### Should I delete photos from `photos/` directory?

⚠️ Be careful - the tool tracks what's downloaded. If you delete files:
- They won't be re-downloaded (unless you clear tracking)
- You might lose photos if they're deleted from Google Photos

**Better approach**: Back up to another location, keep originals.

## Docker Specific

### How do I view Docker logs?

```bash
make logs
# or
docker-compose logs -f
```

### How do I exec into the container?

```bash
make shell
# or
docker-compose exec gphotos-cdp /bin/bash
```

### Where are volumes stored?

```bash
# Check volumes
docker volume ls | grep gphotos

# Inspect volume
docker volume inspect gphotos-cdp_photos
```

### How do I backup Docker volumes?

```bash
# Export volume
docker run --rm \
  -v gphotos-cdp_photos:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/photos-backup.tar.gz /data
```

### Container uses too much memory/CPU

Adjust in `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 2G
```

## Security & Privacy

### Where are my credentials stored?

Credentials are stored by Chrome in `chrome-profile/` directory. This uses Chrome's secure storage.

**Keep `chrome-profile/` secure:**
- Don't share it
- Don't commit to git (already in .gitignore)
- Set proper file permissions
- Back it up securely if needed

### Can others access my photos?

If someone has access to:
- Your `chrome-profile/` directory
- Your server with proper permissions
- Your Google account credentials

**Security tips:**
- Use proper file permissions (chmod 700)
- Use full disk encryption
- Restrict SSH access
- Use firewall rules

### Does the tool send data anywhere?

No. The tool only:
- Connects to Google Photos (photos.google.com)
- Downloads photos to local disk

No telemetry, no third-party servers.

## Comparison

### vs Google Takeout?

| Feature | gphotos-cdp | Google Takeout |
|---------|-------------|----------------|
| Speed | Fast (minutes-hours) | Slow (days-weeks) |
| Automation | Fully automated | Manual request |
| Incremental | Yes (sync new photos) | No (full export) |
| Format | Original | Original + metadata |
| Setup | Technical | Simple |

**Use Takeout if:** You want one-time full export with metadata
**Use gphotos-cdp if:** You want continuous automated backup

### vs Other downloaders?

gphotos-cdp is:
- ✅ Open source (Apache 2.0)
- ✅ Docker-ready
- ✅ Headless server support
- ✅ Active maintenance
- ✅ Multi-language support
- ✅ Comprehensive documentation

## Contributing

### How can I help?

- Report bugs
- Add language support
- Improve documentation
- Submit features

See [CONTRIBUTING.md](CONTRIBUTING.md).

### How do I add language support?

**Easy way:** Use Learning Mode!

```bash
# 1. Change Google account to target language
# 2. Run learning mode
gphotos-cdp -learn -dev -dldir photos
```

See [LEARNING_MODE.md](LEARNING_MODE.md) for complete guide.

**Manual way:** Edit `locales.yaml` with translations. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Still Need Help?

- 📖 Read [QUICKSTART.md](QUICKSTART.md)
- 🐛 Check [Issues](../../issues)
- 💬 Ask in [Discussions](../../discussions)
- 📚 See [Full Documentation](README.md)
