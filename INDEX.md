# 📚 Documentation Index

Welcome to gphotos-cdp documentation! Find what you need quickly.

## 🚀 Getting Started

**New user? Start here:**
1. [README.md](README.md) - Project overview & features
2. [QUICKSTART.md](QUICKSTART.md) - Get running in 5 minutes
3. [FAQ.md](FAQ.md) - Common questions answered

**Returning after a break?**
- [SESSION_SUMMARY.md](SESSION_SUMMARY.md) - Quick context refresh
- [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md) - Complete development history

## 📖 User Guides

### Setup & Installation
- [install.sh](install.sh) - Automated installer (run this first)
- [DOCKER.md](DOCKER.md) - Complete Docker setup guide
- [setup-auth.sh](setup-auth.sh) - Authentication helper
- [LEARNING_MODE.md](LEARNING_MODE.md) - Create new language translations
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical architecture guide

### Daily Operations
- [docker.sh](docker.sh) - Docker management commands
- [Makefile](Makefile) - Quick commands (`make up`, `make logs`, etc.)
- [validate.sh](validate.sh) - Validate your setup
- [test-locale.sh](test-locale.sh) - Validate locale YAML files

### Configuration
- [.env.example](.env.example) - Environment variables (copy to `.env`)
- [docker-compose.yml](docker-compose.yml) - Docker orchestration
- [docker-compose.override.yml.example](docker-compose.override.yml.example) - Customization template

## 🏢 Production Deployment

- [DEPLOYMENT.md](DEPLOYMENT.md) - Production strategies
  - Single server
  - Docker Swarm
  - Kubernetes
  - Cloud platforms (AWS, GCP, Azure)
  - NAS devices (Synology, QNAP)
- [systemd/](systemd/) - System service integration
  - [systemd/README.md](systemd/README.md) - Systemd setup guide
  - [systemd/gphotos-cdp.service](systemd/gphotos-cdp.service) - Service unit
  - [systemd/gphotos-cdp.timer](systemd/gphotos-cdp.timer) - Timer unit

## 🔧 Advanced Usage

### Scripts & Automation
- [examples/](examples/) - Example scripts
  - [examples/backup.sh](examples/backup.sh) - Multi-destination backup
  - [examples/post-download.sh](examples/post-download.sh) - Per-file processing
  - [examples/README.md](examples/README.md) - Examples documentation

### Monitoring & Maintenance
- [healthcheck.sh](healthcheck.sh) - Health monitoring script
- [DOCKER.md#monitoring](DOCKER.md) - Monitoring setup
- [DEPLOYMENT.md#monitoring](DEPLOYMENT.md) - Production monitoring

## 🤝 Contributing

- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute
  - Code guidelines
  - Adding languages
  - Reporting bugs
  - Feature requests
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - Repository structure
- [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md) - Development history & session log
- [ROADMAP.md](ROADMAP.md) - Future plans & feature roadmap

## 📋 Reference

### Code Structure
- [main.go](main.go) - Main application (2378 lines)
- [learning.go](learning.go) - Learning mode implementation (500 lines)
- [locales.go](locales.go) - Language support
- [locales.yaml](locales.yaml) - Translations (EN, NL)
- [locales-pl.example.yaml](locales-pl.example.yaml) - Example Polish locale
- [go.mod](go.mod) - Go dependencies

### Docker & CI/CD
- [Dockerfile](Dockerfile) - Container image definition
- [.dockerignore](.dockerignore) - Build exclusions
- [.github/workflows/](.github/workflows/) - GitHub Actions
  - [docker-build.yml](.github/workflows/docker-build.yml) - Build automation

### Configuration Files
- [.editorconfig](.editorconfig) - Code style settings
- [.gitignore](.gitignore) - Git exclusions
- [LICENSE](LICENSE) - Apache 2.0 License

## 🔍 Find by Topic

### Authentication
- [QUICKSTART.md#authentication](QUICKSTART.md)
- [DOCKER.md#authentication](DOCKER.md)
- [FAQ.md#authentication](FAQ.md)
- [setup-auth.sh](setup-auth.sh)

### Troubleshooting
- [FAQ.md#troubleshooting](FAQ.md)
- [README.md#troubleshooting](README.md)
- [DOCKER.md#troubleshooting](DOCKER.md)

### Backup & Recovery
- [examples/backup.sh](examples/backup.sh)
- [DEPLOYMENT.md#backup-strategies](DEPLOYMENT.md)
- [FAQ.md#backup](FAQ.md)

### Performance Tuning
- [DOCKER.md#performance](DOCKER.md)
- [docker-compose.yml](docker-compose.yml) - Resource limits
- [FAQ.md#performance](FAQ.md)

### Security
- [DEPLOYMENT.md#security](DEPLOYMENT.md)
- [FAQ.md#security-privacy](FAQ.md)
- [CONTRIBUTING.md#security](CONTRIBUTING.md)

## 📊 Quick Command Reference

```bash
# Installation
./install.sh                  # Install dependencies
./validate.sh                 # Validate setup

# Authentication
./setup-auth.sh               # Interactive auth

# Operations (Make)
make up                       # Start service
make down                     # Stop service
make logs                     # View logs
make status                   # Check status
make stats                    # Resource usage
make restart                  # Restart
make clean                    # Clean containers
make clean-all                # Reset everything

# Operations (Docker Script)
./docker.sh up                # Start
./docker.sh logs              # View logs
./docker.sh status            # Status
./docker.sh help              # All commands

# Backup
./examples/backup.sh          # Backup photos
```

## 🎯 Find by Role

### Home User
1. [QUICKSTART.md](QUICKSTART.md)
2. [FAQ.md](FAQ.md)
3. [docker.sh](docker.sh)

### System Administrator
1. [DOCKER.md](DOCKER.md)
2. [DEPLOYMENT.md](DEPLOYMENT.md)
3. [systemd/README.md](systemd/README.md)
4. [healthcheck.sh](healthcheck.sh)

### Developer
1. [CONTRIBUTING.md](CONTRIBUTING.md)
2. [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
3. [main.go](main.go)
4. [.github/workflows/](.github/workflows/)

### DevOps Engineer
1. [DEPLOYMENT.md](DEPLOYMENT.md)
2. [Dockerfile](Dockerfile)
3. [docker-compose.yml](docker-compose.yml)
4. [.github/workflows/docker-build.yml](.github/workflows/docker-build.yml)

## 📞 Get Help

- 📖 Read documentation above
- 🐛 [Report bug](../../issues/new?template=bug_report.md)
- 💡 [Request feature](../../issues/new?template=feature_request.md)
- 💬 [Start discussion](../../discussions)
- ⭐ [Star the project](../../stargazers)

## 🗺️ Documentation Map

```
                    INDEX.md (you are here)
                         |
        +----------------+----------------+
        |                |                |
   New User?        Need Help?      Contributing?
        |                |                |
   QUICKSTART.md      FAQ.md      CONTRIBUTING.md
        |                |                |
        v                v                v
    DOCKER.md       README.md     PROJECT_STRUCTURE.md
        |                                 |
        v                                 v
  DEPLOYMENT.md                      CHANGELOG.md
        |
        v
   systemd/README.md
```

---

**💡 Tip:** Bookmark this page for quick access to all documentation!

**Last Updated:** February 2026
