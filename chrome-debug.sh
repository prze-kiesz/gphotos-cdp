#!/bin/bash
# Start Chrome in Remote Debugging Mode
# This allows you to connect from your local browser to Chrome running in Docker

set -e

echo "=========================================="
echo "Chrome Remote Debugging Mode"
echo "=========================================="
echo ""

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "ERROR: docker-compose not found!"
    exit 1
fi

# Check if port 9222 is already in use
if netstat -tuln 2>/dev/null | grep -q ":9222 "; then
    echo "WARNING: Port 9222 is already in use!"
    echo "Stop the existing service or choose a different port."
    exit 1
fi

echo "Starting Chrome in remote debugging mode..."
echo ""
echo "This will:"
echo "  - Start Chrome with remote debugging enabled"
echo "  - Expose Chrome DevTools Protocol on port 9222"
echo "  - Use ./chrome-profile for session persistence"
echo ""

# Start only the chrome-debug service
docker-compose up -d chrome-debug

echo ""
echo "=========================================="
echo "Chrome is starting..."
echo "=========================================="
echo ""

# Wait for Chrome to be ready
echo -n "Waiting for Chrome to be ready"
for i in {1..30}; do
    if curl -s http://localhost:9222/json/version > /dev/null 2>&1; then
        echo " READY!"
        break
    fi
    echo -n "."
    sleep 1
done
echo ""

# Get Chrome version info
echo ""
echo "Chrome DevTools Protocol Info:"
curl -s http://localhost:9222/json/version | python3 -m json.tool 2>/dev/null || curl -s http://localhost:9222/json/version
echo ""

echo ""
echo "=========================================="
echo "SUCCESS! Chrome is running"
echo "=========================================="
echo ""
echo "Connect from your local browser:"
echo ""
echo "  1. Open Chrome/Edge on your computer"
echo "  2. Go to: chrome://inspect/#devices"
echo "  3. Click 'Configure...' next to 'Discover network targets'"
echo "  4. Add: YOUR_SERVER_IP:9222"
echo "  5. Click 'Done'"
echo "  6. Wait a moment, then you'll see the remote Chrome instance"
echo "  7. Click 'inspect' to open DevTools"
echo ""
echo "Or connect directly:"
echo "  http://localhost:9222/json"
echo "  http://YOUR_SERVER_IP:9222/json"
echo ""
echo "To stop Chrome:"
echo "  docker-compose stop chrome-debug"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f chrome-debug"
echo ""
