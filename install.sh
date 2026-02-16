#!/bin/bash
# Quick install script for server setup

set -e

echo "=== gphotos-cdp Server Installation ==="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "❌ Please do not run as root. Run as your regular user."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed. Please log out and back in for group changes to take effect."
    echo "   Then run this script again."
    exit 0
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose not found. Installing..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ docker-compose installed."
fi

echo ""
echo "✅ Prerequisites installed!"
echo ""

# Make scripts executable
chmod +x docker.sh setup-auth.sh test.sh 2>/dev/null || true

# Create .env if doesn't exist
if [ ! -f .env ]; then
    echo "Creating default .env file..."
    cp .env.example .env
    echo "✅ Created .env (you can edit this later)"
fi

echo ""
echo "=== Next Steps ==="
echo ""
echo "1. Authenticate with Google Photos:"
echo "   ./setup-auth.sh"
echo ""
echo "2. Start the service:"
echo "   make up          (or ./docker.sh up)"
echo ""
echo "3. View logs:"
echo "   make logs        (or ./docker.sh logs)"
echo ""
echo "4. (Optional) Install as systemd service:"
echo "   See systemd/README.md for instructions"
echo ""
echo "Configuration: Edit .env file to customize settings"
echo "Documentation: See DOCKER.md and README.md"
echo ""
