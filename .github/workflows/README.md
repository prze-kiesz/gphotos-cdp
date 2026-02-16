# GitHub Actions CI/CD

This directory contains GitHub Actions workflows for automated building and testing.

## Workflows

### docker-build.yml

Automatically builds and tests the Docker image on:
- Push to main/master/develop branches
- Pull requests
- Version tags (v*)
- Manual trigger

**Features:**
- Runs Go tests
- Builds Docker image
- Pushes to GitHub Container Registry (ghcr.io)
- Multi-arch support (amd64, arm64)
- Cache optimization

## Using Pre-built Images

Instead of building locally, you can use pre-built images:

```yaml
# docker-compose.yml
services:
  gphotos-cdp:
    image: ghcr.io/YOUR_USERNAME/gphotos-cdp:latest
    # ... rest of config
```

Or pull directly:
```bash
docker pull ghcr.io/YOUR_USERNAME/gphotos-cdp:latest
```

## Available Tags

- `latest` - Latest build from main branch
- `develop` - Latest build from develop branch
- `v1.2.3` - Specific version tags
- `sha-abc1234` - Specific commit

## Setup

1. Enable GitHub Container Registry:
   - Go to repository Settings → Packages
   - Enable package visibility

2. No additional secrets needed - uses `GITHUB_TOKEN` automatically

## Manual Trigger

You can manually trigger a build from GitHub:
- Go to Actions tab
- Select "Docker Build" workflow
- Click "Run workflow"
