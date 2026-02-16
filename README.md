# gphotos-cdp

> Automatically download your photos from Google Photos using Chrome DevTools Protocol

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Go Version](https://img.shields.io/badge/Go-1.23-00ADD8?logo=go)](go.mod)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](Dockerfile)

## Features

✅ **Automatic Downloads** - Continuously sync your Google Photos library  
✅ **Headless Mode** - Run on servers without GUI  
✅ **Docker Support** - Easy deployment with Docker Compose  
✅ **Album Support** - Download specific albums  
✅ **Date Filtering** - Download photos from specific date ranges  
✅ **Concurrent Downloads** - Multiple workers for faster syncing  
✅ **Multi-language** - Supports English, Dutch, and more  
✅ **Learning Mode** - Easy tool to add new language support 🎓  
✅ **Systemd Integration** - Run as system service with auto-start  

## Quick Start

### 🐋 Docker (Recommended)

```bash
# Install dependencies
./install.sh

# Authenticate with Google Photos
./setup-auth.sh

# Start syncing
make up

# View logs
make logs
```

📖 **Full Docker Guide:** [DOCKER.md](DOCKER.md)  
🚀 **Quick Reference:** [QUICKSTART.md](QUICKSTART.md)  
📚 **All Documentation:** [INDEX.md](INDEX.md)

### 💻 Native Binary

```bash
# First run (opens browser for login)
gphotos-cdp -dldir photos

# Subsequent runs (headless)
gphotos-cdp -dev -headless -dldir photos

# Sync specific album
gphotos-cdp -dev -dldir photos -album YOUR_ALBUM_ID

# See all options
gphotos-cdp -h
```

## Documentation

| Document | Description |
|----------|-------------|
| [QUICKSTART.md](QUICKSTART.md) | Get started in 5 minutes ⚡ |
| [DOCKER.md](DOCKER.md) | Complete Docker setup guide 🐋 |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Production deployment strategies 🚀 |
| [LEARNING_MODE.md](LEARNING_MODE.md) | Create translations for new languages 🌍 |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Technical architecture documentation 🏗️ |
| [FAQ.md](FAQ.md) | Frequently asked questions ❓ |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contributing guidelines 🤝 |
| [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md) | Development history & session log 📝 |
| [ROADMAP.md](ROADMAP.md) | Future plans & feature roadmap 🗺️ |
| [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) | Repository structure 📁 |
| [systemd/](systemd/) | Systemd service configuration ⚙️ |
| [examples/](examples/) | Example scripts & integrations 💡 |

## Configuration

Edit `.env` file or use command-line flags:

```bash
# .env example
WORKERS=4                    # Concurrent downloads
LOGLEVEL=info               # Log detail level
FROM_DATE=2024-01-01        # Only download from this date
TO_DATE=2024-12-31          # Only download until this date
ALBUM_ID=your_album_id      # Download specific album
```

## Commands

| Command | Description |
|---------|-------------|
| `make up` | Start service |
| `make down` | Stop service |
| `make logs` | View logs |
| `make status` | Check status |
| `make stats` | Resource usage |
| `make restart` | Restart service |
| `make clean` | Clean containers |

Or use `./docker.sh <command>` instead.

## Why?

We want to incrementally download our own photos out of Google Photos. Google offers no APIs to do this, so we have to scrape the website.

We can get our original photos out with [Google Takeout](https://takeout.google.com/), but only manually and slowly. We don't want to remember to do it (or renew time-limited scheduled takeouts) - we want photos mirrored in seconds or minutes, not weeks.

**What if Google breaks this tool?** We'll update it. That's no different than using APIs - companies regularly deprecate and change those too.

## How It Works

1. Uses Chrome DevTools Protocol to automate a real Chrome browser
2. Authenticates with your Google account (you log in once)
3. Navigates through Google Photos and identifies photos
4. Downloads each photo to your specified directory
5. Keeps track of what's downloaded to avoid duplicates
6. Can run external programs on each download (e.g., upload elsewhere)

## Advanced Usage

### Run Custom Program on Downloads

```bash
# Execute script.sh after each download
gphotos-cdp -dldir photos -run ./script.sh

# The script receives the file path as argument
# #!/bin/bash
# FILE="$1"
# # Upload to backup, process, etc.
```

### Add New Language Support

```bash
# Interactive learning mode
gphotos-cdp -learn -dev -dldir photos

# Follow prompts to map UI elements
# Generates locales-XX.yaml automatically
```

See [LEARNING_MODE.md](LEARNING_MODE.md) for complete guide.

### Scheduled Backups

```bash
# Using systemd timer (runs every 6 hours)
sudo systemctl enable --now gphotos-cdp.timer

# Using cron (runs daily at 2 AM)
0 2 * * * cd /opt/gphotos-cdp && docker-compose up --abort-on-container-exit
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for production setups.

## Troubleshooting

### Photos not downloading

```bash
# Check logs for errors
make logs

# Verify container is running
make status

# Try re-authenticating
make clean-all
./setup-auth.sh
make up
```

### Login session expired

```bash
# Remove profile and re-authenticate
rm -rf chrome-profile/
./setup-auth.sh
```

### Out of disk space

```bash
# Check usage
make stats

# Clean up old photos (manual)
cd photos && rm -rf old_photos/
```

### Chrome crashes or hangs

```bash
# Increase shared memory in docker-compose.yml
shm_size: '4gb'

# Reduce workers
WORKERS=1 make restart
```

## Requirements

**Docker Setup:**
- Docker 20.10+
- Docker Compose 2.0+
- 2GB RAM minimum, 4GB recommended
- Disk space for your photo library

**Native Build:**
- Go 1.23+
- Chrome/Chromium browser
- Linux, macOS, or Windows

## Project Structure

```
gphotos-cdp/
├── main.go                 # Main application code
├── locales.go/.yaml        # Multi-language support
├── Dockerfile              # Container image definition
├── docker-compose.yml      # Docker orchestration
├── Makefile               # Build commands
├── install.sh             # Installation script
├── setup-auth.sh          # Authentication helper
├── docker.sh              # Docker management script
├── healthcheck.sh         # Health monitoring
├── DOCKER.md              # Docker documentation
├── QUICKSTART.md          # Quick start guide
├── DEPLOYMENT.md          # Deployment strategies
└── systemd/               # Systemd service files
```

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

### Adding Language Support

Edit `locales.yaml` to add your language:

```yaml
pl:
  selectAllPhotosLabel:
    matchType: startsWith
    matchValue: "Wybierz wszystkie zdjęcia z"
  # ... more translations
```

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.

## Credits

Originally created by [The Perkeep Authors](https://perkeep.org).

Extended with Docker support, systemd integration, and deployment tooling.

## Disclaimer

This tool automates interaction with Google Photos through browser automation. Use responsibly and in accordance with Google's Terms of Service. Google may update their interface, which could break this tool temporarily until updated.

## Support

- 📖 [Documentation](QUICKSTART.md)
- 🐛 [Report Issues](../../issues)
- 💬 [Discussions](../../discussions)

---

**⭐ If this project helped you, consider giving it a star!**
