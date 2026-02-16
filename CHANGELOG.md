# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### 🎓 Learning Mode (February 2026)
- **Interactive locale creation tool** - Major new feature!
  - `learning.go` - Complete implementation (~500 lines)
  - Automatic label collection from Google Photos interface
  - JavaScript-based collectors for main page, photo detail, and info panel
  - Interactive guided mapping of UI elements via terminal
  - Automatic YAML generation for new locales
  - Usage: `gphotos-cdp -learn -dev -dldir photos`
  - Integration with Docker: `make learn` or `./docker.sh learn`
- **Learning mode documentation:**
  - `LEARNING_MODE.md` - Complete 12KB user guide
  - `ARCHITECTURE.md` - Technical architecture documentation (78KB)
  - Step-by-step tutorials with examples
  - Field mapping reference guide
- **Locale validation tools:**
  - `test-locale.sh` - Python-based YAML validator
  - `locales-pl.example.yaml` - Example Polish locale
  - `examples/create-polish-locale.sh` - Complete workflow example
- **Build system updates:**
  - Added `-learn` flag to main.go
  - Makefile `learn` target for interactive mode
  - docker.sh `learn` command with terminal support

#### 🐋 Docker Infrastructure (February 2026)
- Docker support with multi-stage builds
- Docker Compose configuration for easy deployment
- Automated setup script (`install.sh`) - One-command installation
- Interactive authentication helper (`setup-auth.sh`) - Easy Chrome profile setup
- Docker management script (`docker.sh`) - Unified interface (up/down/logs/stats/learn)
- Makefile for common operations - Simple commands (make up, make logs, make learn)
- Systemd service and timer templates - Run as system service
- Health check script for monitoring (`healthcheck.sh`)
- Validation script (`validate.sh`) - Pre-flight checks
- GitHub Actions workflow for automated Docker builds
- Multi-architecture support (amd64, arm64) - ARM server support (Raspberry Pi, etc.)

#### 📚 Documentation Suite (February 2026)
- **User Guides:**
  - `DOCKER.md` - Complete Docker setup guide (22KB)
  - `QUICKSTART.md` - 5-minute getting started guide (7KB)
  - `DEPLOYMENT.md` - Production deployment strategies (19KB)
  - `FAQ.md` - Frequently asked questions (11KB)
  - `systemd/README.md` - Systemd integration guide (7.5KB)
- **Developer Resources:**
  - `CONTRIBUTING.md` - Contribution guidelines (9KB)
  - `PROJECT_STRUCTURE.md` - Repository structure (18KB)
  - `INDEX.md` - Documentation hub (2.5KB)
  - `DEVELOPMENT_LOG.md` - Complete development history (50KB+)
  - `ROADMAP.md` - Future plans and feature roadmap (15KB)
- **Examples:**
  - Example environment configuration (`.env.example`)
  - Docker Compose override example
  - `examples/backup.sh` - Multi-destination backup script
  - `examples/post-download.sh` - Per-file processing template
  - `examples/create-polish-locale.sh` - Locale creation workflow

### Changed
- Updated README.md with Docker-first approach
- Updated README.md with Learning Mode feature section
- Improved documentation structure with INDEX.md hub
- Enhanced .gitignore for Docker artifacts
- Dockerfile now includes learning.go in build
- Main.go updated with `-learn` flag integration

### Fixed
- Chrome XDG environment variables for newer Chromium versions
- Docker interactive terminal support for learning mode

### Security
- Non-root user in Docker container (gphotos-cdp:gphotos-cdp)
- Resource limits in Docker configuration
- Secure Chrome profile handling
- Privacy-focused: no telemetry, all data local

## [Previous Versions]

See git history for changes before Docker integration.

---

## Release Process

1. Update this CHANGELOG
2. Update version in code
3. Commit changes
4. Tag release: `git tag -a v1.0.0 -m "Release v1.0.0"`
5. Push tag: `git push origin v1.0.0`
6. GitHub Actions will build and publish Docker image
