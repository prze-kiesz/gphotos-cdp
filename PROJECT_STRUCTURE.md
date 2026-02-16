# Project Structure

Complete overview of gphotos-cdp repository structure.

## 📁 Root Directory

```
gphotos-cdp/
├── 📄 Core Application Files
│   ├── main.go                 # Main application logic (2378 lines)
│   ├── learning.go             # Learning mode implementation (500 lines) 🆕
│   ├── locales.go              # Multi-language support code
│   ├── locales.yaml            # Translation strings (EN, NL, etc.)
│   ├── locales-pl.example.yaml # Example Polish locale 🆕
│   ├── go.mod                  # Go dependencies
│   └── go.sum                  # Go dependency checksums
│
├── 🐋 Docker Files
│   ├── Dockerfile              # Multi-stage Docker build
│   ├── docker-compose.yml      # Main orchestration config
│   ├── docker-compose.override.yml.example  # Customization template
│   ├── .dockerignore           # Docker build exclusions
│   └── .env.example            # Environment variables template
│
├── 🔧 Scripts & Tools
│   ├── install.sh              # One-command installer
│   ├── setup-auth.sh           # Interactive authentication helper
│   ├── docker.sh               # Docker management commands
│   ├── healthcheck.sh          # Health monitoring script
│   ├── validate.sh             # Docker validation script 🆕
│   ├── test-locale.sh          # Locale YAML validation 🆕
│   ├── test.sh                 # Test runner (original)
│   └── Makefile                # Build automation commands
│
├── 📚 Documentation
│   ├── README.md               # Main project documentation
│   ├── INDEX.md                # Documentation hub 🆕
│   ├── QUICKSTART.md           # 5-minute getting started guide
│   ├── DOCKER.md               # Complete Docker guide
│   ├── DEPLOYMENT.md           # Production deployment strategies
│   ├── LEARNING_MODE.md        # Learning mode user guide 🆕
│   ├── ARCHITECTURE.md         # Technical architecture 🆕
│   ├── DEVELOPMENT_LOG.md      # Development history 🆕
│   ├── PROJECT_STRUCTURE.md    # This file - repository structure
│   ├── FAQ.md                  # Frequently asked questions
│   ├── CONTRIBUTING.md         # Contribution guidelines
│   ├── CHANGELOG.md            # Version history
│   └── LICENSE                 # Apache License 2.0
│
├── 📂 Subdirectories
│   ├── .github/                # GitHub-specific files
│   ├── systemd/                # Systemd service files
│   └── examples/               # Example scripts
│
├── ⚙️ Configuration
│   ├── .gitignore              # Git exclusions
│   ├── .editorconfig           # Editor settings
│   └── .env                    # Local environment (not in git)
│
└── 📦 Runtime Data (created, not in git)
    ├── photos/                 # Downloaded photos
    ├── chrome-profile/         # Browser session data
    └── *.log                   # Log files
```

## 📂 .github/ Directory

```
.github/
├── workflows/
│   ├── docker-build.yml        # CI/CD: Build & publish Docker images
│   └── README.md               # Workflow documentation
```

**Purpose:** GitHub Actions automation
- Builds on push/PR
- Publishes to GitHub Container Registry
- Multi-arch support (amd64, arm64)

## 📂 systemd/ Directory

```
systemd/
├── gphotos-cdp.service         # Systemd service unit
├── gphotos-cdp.timer           # Systemd timer unit
└── README.md                   # Installation & usage guide
```

**Purpose:** Run as system service
- Auto-start on boot
- Scheduled syncs (timer)
- System integration

## 📂 examples/ Directory

```
examples/
├── backup.sh                   # Multi-destination backup script
├── post-download.sh            # Per-file processing template
└── README.md                   # Examples documentation
```

**Purpose:** Extension examples
- Automated backups
- Cloud uploads
- Custom processing
- Integration patterns

## 📄 Key Files Explained

### Core Application

| File | Purpose | Lines |
|------|---------|-------|
| `main.go` | Main application logic, Chrome automation | ~2400 |
| `locales.go` | Language detection and locale handling | ~150 |
| `locales.yaml` | UI text translations for Google Photos | ~140 |

### Docker Infrastructure

| File | Purpose |
|------|---------|
| `Dockerfile` | Multi-stage build: Go compile → Debian runtime |
| `docker-compose.yml` | Service definition, volumes, networks |
| `.dockerignore` | Build context exclusions |
| `.env.example` | Configuration template |

### Scripts

| File | Purpose | User Action |
|------|---------|-------------|
| `install.sh` | Install Docker, docker-compose | Run once |
| `setup-auth.sh` | Interactive auth setup | First time only |
| `docker.sh` | Docker command wrapper | Daily use |
| `healthcheck.sh` | Health monitoring | Cron/monitoring |

### Documentation

| File | Target Audience | Content |
|------|----------------|---------|
| `README.md` | Everyone | Overview, quick start |
| `QUICKSTART.md` | New users | 5-min setup guide |
| `DOCKER.md` | Docker users | Detailed Docker guide |
| `DEPLOYMENT.md` | DevOps/SysAdmins | Production scenarios |
| `FAQ.md` | Support | Common questions |
| `CONTRIBUTING.md` | Contributors | How to contribute |

### Automation

| File | Use Case |
|------|----------|
| `Makefile` | Quick commands (`make up`, `make logs`) |
| `.github/workflows/` | CI/CD automation |
| `systemd/` | System service integration |

## 🗂️ Runtime Data Directories

These are created during setup/runtime (not in git):

### photos/
```
photos/
├── IMG_0001.jpg
├── IMG_0002.jpg
├── VID_0001.mp4
└── ... (your downloaded photos)
```
- **Created by:** Downloads
- **Backed up:** Yes, this is your data!
- **Size:** Depends on library

### chrome-profile/
```
chrome-profile/
├── Default/
│   ├── Cookies
│   ├── Preferences
│   └── ... (Chrome session data)
```
- **Created by:** Chrome/setup
- **Backed up:** Recommended (keeps login)
- **Size:** ~100MB
- **Security:** Keep private!

### Logs (optional)
```
sync.log                        # Sync output log
docker-logs/                    # Docker log files
```

## 📋 File Categories

### Version Control (Git)
✅ **Included:**
- Source code (`.go`)
- Documentation (`.md`)
- Configuration templates (`.example`)
- Scripts (`.sh`)
- Docker files
- CI/CD workflows

❌ **Excluded (.gitignore):**
- Binary (`gphotos-cdp`)
- Build artifacts
- Runtime data (`photos/`, `chrome-profile/`)
- Local config (`.env`)
- Logs (`*.log`)

### Docker Build Context
✅ **Included:**
- Source files
- `locales.yaml`
- `go.mod`, `go.sum`

❌ **Excluded (.dockerignore):**
- `.git/`
- Documentation
- Data directories
- IDE files
- Test scripts

## 🔄 Data Flow

```
1. Source Code
   ├── main.go
   ├── locales.go
   └── locales.yaml
        ↓
2. Docker Build
   ├── Dockerfile (build)
   └── gphotos-cdp binary
        ↓
3. Container Runtime
   ├── Chrome/Chromium
   ├── Session (chrome-profile/)
   └── Downloads (photos/)
        ↓
4. Optional Processing
   ├── examples/backup.sh
   ├── examples/post-download.sh
   └── Custom scripts
```

## 📊 Size Estimates

| Component | Typical Size |
|-----------|-------------|
| Source code | < 1MB |
| Docker image | ~500MB |
| Chrome profile | ~100MB |
| Photos | Varies (GB-TB) |
| Logs | ~1-10MB |

## 🔒 Security-Sensitive Files

| File/Dir | Contains | Action |
|----------|----------|--------|
| `chrome-profile/` | Login session | Keep private, backup securely |
| `.env` | Config (may have secrets) | Don't commit, restrict access |
| `photos/` | Personal photos | Backup, encrypt if sensitive |

## 🚀 Quick Reference

### First Time Setup
```bash
./install.sh          # Install dependencies
./setup-auth.sh       # Authenticate
cp .env.example .env  # Create config
make up               # Start service
```

### Daily Operations
```bash
make logs             # View activity
make status           # Check health
make stats            # Resource usage
make restart          # Restart service
```

### Maintenance
```bash
make update           # Update & rebuild
make clean            # Clean containers
./examples/backup.sh  # Backup photos
```

### Troubleshooting
```bash
make logs             # Check errors
make clean-all        # Nuclear reset
./setup-auth.sh       # Re-authenticate
make build && make up # Fresh start
```

## 📖 Documentation Map

```
Start Here
    ↓
README.md ──────→ QUICKSTART.md ──┐
    │                               │
    ↓                               ↓
Need Docker?                   Need Setup?
    ↓                               │
DOCKER.md                           │
    │                               │
    ↓                               ↓
Production?                   Questions?
    ↓                               │
DEPLOYMENT.md                  FAQ.md
    │                               │
    ↓                               ↓
Systemd?                      Want to Help?
    ↓                               │
systemd/README.md          CONTRIBUTING.md
```

## 🛠️ Developer Reference

### Adding Features
1. Edit `main.go`
2. Update docs
3. Add tests
4. Update `CHANGELOG.md`
5. Submit PR

### Adding Languages
1. Edit `locales.yaml`
2. Test with that locale
3. Submit PR

### Modifying Docker
1. Edit `Dockerfile` or `docker-compose.yml`
2. Test: `make rebuild`
3. Update `DOCKER.md`
4. Commit changes

---

**Last Updated:** February 2026  
**Maintainers:** See git history and CONTRIBUTING.md
