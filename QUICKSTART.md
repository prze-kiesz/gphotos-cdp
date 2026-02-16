# 🚀 Quick Start Guide

## For Servers (Docker - Recommended)

### 1️⃣ Install Dependencies
```bash
./install.sh
```

### 2️⃣ First-Time Authentication
```bash
./setup-auth.sh
# Follow the instructions for your setup type
```

### 3️⃣ Start Service
```bash
make up
# or: ./docker.sh up
```

### 4️⃣ Monitor
```bash
make logs
# or: ./docker.sh logs
```

---

## Files You Created

After setup, you'll have:
- `photos/` - Downloaded photos (backup this!)
- `chrome-profile/` - Login session (don't lose this!)
- `.env` - Your configuration

---

## Common Commands

| Command | Description |
|---------|-------------|
| `make up` | Start service |
| `make down` | Stop service |
| `make logs` | View logs |
| `make status` | Check status |
| `make stats` | Resource usage |
| `make restart` | Restart service |
| `make clean-all` | Reset everything (requires re-auth) |

Or use `./docker.sh <command>` instead of `make`.

---

## Configuration

Edit `.env` file:
```bash
nano .env
```

Common settings:
- `WORKERS=4` - More workers = faster downloads
- `LOGLEVEL=debug` - More verbose logging
- `FROM_DATE=2024-01-01` - Only download photos from this date
- `TO_DATE=2024-12-31` - Only download photos until this date

After editing `.env`:
```bash
make restart
```

---

## Running as Systemd Service (Auto-start on Boot)

See [systemd/README.md](systemd/README.md) for full instructions.

Quick version:
```bash
sudo cp -r $(pwd) /opt/gphotos-cdp
cd /opt/gphotos-cdp
sudo cp systemd/*.{service,timer} /etc/systemd/system/
sudo systemctl enable --now gphotos-cdp.timer
```

---

## Troubleshooting

### Photos not downloading?
```bash
make logs  # Check for errors
make status  # Check if running
```

### Need to re-login?
```bash
make down
rm -rf chrome-profile/
./setup-auth.sh
make up
```

### Out of disk space?
```bash
make stats  # Check disk usage
# Clean up old photos manually from photos/
```

### Container won't start?
```bash
make clean  # Clean containers
make build  # Rebuild image
make up     # Start again
```

---

## Where to Get Help

- Main docs: [README.md](README.md)
- Docker docs: [DOCKER.md](DOCKER.md)
- Systemd docs: [systemd/README.md](systemd/README.md)
- Issues: Check the logs with `make logs`

---

## Adding Language Support

### Want to use gphotos-cdp in your language?

Use **Learning Mode** to create translations:

```bash
# 1. Change your Google Photos language
#    Go to Google Account → Language → Select your language

# 2. Run learning mode
make down  # Stop if running
gphotos-cdp -learn -dev -dldir photos

# 3. Follow interactive prompts
#    - Tool will collect all labels from Google Photos
#    - You'll map them to required fields
#    - Generates locales-XX.yaml file

# 4. Test your locale
cp locales-XX.yaml locales.yaml
make up
```

📚 **Full Guide:** [LEARNING_MODE.md](LEARNING_MODE.md)

---

**Always backup:**
- `photos/` - Your downloaded photos
- `chrome-profile/` - Keeps you logged in
- `.env` - Your settings

**Don't need to backup:**
- Docker images (can be rebuilt)
- Log files
