#!/bin/bash
# Validation script - checks if setup is correct

set -e

echo "🔍 Validating gphotos-cdp setup..."
echo ""

ERRORS=0
WARNINGS=0

# Check Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker installed: $(docker --version | head -1)"
else
    echo "❌ Docker not found"
    ERRORS=$((ERRORS + 1))
fi

# Check docker-compose
if command -v docker-compose &> /dev/null; then
    echo "✅ docker-compose installed: $(docker-compose --version)"
else
    echo "❌ docker-compose not found"
    ERRORS=$((ERRORS + 1))
fi

# Check if Docker daemon is running
if docker info &> /dev/null; then
    echo "✅ Docker daemon running"
else
    echo "❌ Docker daemon not running"
    ERRORS=$((ERRORS + 1))
fi

# Check required files
REQUIRED_FILES=(
    "Dockerfile"
    "docker-compose.yml"
    "main.go"
    "locales.yaml"
    "go.mod"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ Found: $file"
    else
        echo "❌ Missing: $file"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check executable scripts
SCRIPTS=(
    "install.sh"
    "setup-auth.sh"
    "docker.sh"
    "healthcheck.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -x "$script" ]; then
        echo "✅ Executable: $script"
    else
        echo "⚠️  Not executable: $script (run: chmod +x $script)"
        WARNINGS=$((WARNINGS + 1))
    fi
done

# Check .env file
if [ -f ".env" ]; then
    echo "✅ Configuration file exists: .env"
else
    echo "⚠️  No .env file (copy .env.example to .env)"
    WARNINGS=$((WARNINGS + 1))
fi

# Check directories
if [ -d "photos" ]; then
    PHOTO_COUNT=$(find photos -type f 2>/dev/null | wc -l)
    echo "✅ Photos directory exists ($PHOTO_COUNT files)"
else
    echo "ℹ️  Photos directory will be created on first run"
fi

if [ -d "chrome-profile" ]; then
    if [ -d "chrome-profile/Default" ]; then
        echo "✅ Chrome profile exists (authenticated)"
    else
        echo "⚠️  Chrome profile directory exists but empty"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "ℹ️  Chrome profile will be created during authentication"
fi

# Check disk space
AVAILABLE_SPACE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -gt 10 ]; then
    echo "✅ Disk space: ${AVAILABLE_SPACE}GB available"
else
    echo "⚠️  Low disk space: ${AVAILABLE_SPACE}GB available"
    WARNINGS=$((WARNINGS + 1))
fi

# Try to build Docker image
echo ""
echo "🔨 Testing Docker build..."
if docker-compose build --quiet 2>&1 | grep -q "error"; then
    echo "❌ Docker build failed"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Docker build successful"
fi

# Summary
echo ""
echo "========================"
echo "Validation Summary"
echo "========================"
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "✅ Setup looks good!"
    echo ""
    echo "Next steps:"
    echo "  1. Authenticate: ./setup-auth.sh"
    echo "  2. Start service: make up"
    echo "  3. View logs: make logs"
    exit 0
else
    echo "❌ Setup has errors. Please fix them and try again."
    exit 1
fi
