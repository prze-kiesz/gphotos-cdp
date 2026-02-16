#!/bin/bash
# Helper script for initial authentication on headless server

set -e

echo "=== gphotos-cdp First Time Setup ==="
echo ""
echo "This script will help you authenticate with Google Photos"
echo "for the first time on a headless server."
echo ""

# Check if directories exist
if [ ! -d "photos" ]; then
    echo "Creating photos directory..."
    mkdir -p photos
fi

if [ ! -d "chrome-profile" ]; then
    echo "Creating chrome-profile directory..."
    mkdir -p chrome-profile
fi

# Check if already authenticated
if [ -d "chrome-profile/Default" ]; then
    echo "⚠️  Warning: chrome-profile already exists."
    echo "Do you want to re-authenticate? This will delete existing session."
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
    rm -rf chrome-profile/*
fi

echo ""
echo "Choose authentication method:"
echo "1) I have X11 forwarding enabled (SSH with -X)"
echo "2) I'll copy profile from another machine"
echo "3) I'll use VNC to view the browser"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "Starting authentication with X11..."
        echo "A Chrome window should open. Log in to Google Photos."
        echo "After successful login, close the browser window."
        echo ""
        
        if [ -z "$DISPLAY" ]; then
            echo "❌ Error: DISPLAY not set. Make sure X11 forwarding is enabled."
            echo "Connect with: ssh -X user@server"
            exit 1
        fi
        
        docker-compose build
        docker-compose run --rm \
            -e DISPLAY=$DISPLAY \
            -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
            gphotos-cdp gphotos-cdp -profile /data/profile -dldir /data/photos -v
        ;;
        
    2)
        echo ""
        echo "Instructions:"
        echo "1. On your local machine, run this tool and authenticate"
        echo "2. Tar the chrome-profile directory:"
        echo "   tar czf chrome-profile.tar.gz chrome-profile/"
        echo "3. Copy to this server:"
        echo "   scp chrome-profile.tar.gz user@server:~/gphotos-cdp/"
        echo "4. Extract here:"
        echo "   tar xzf chrome-profile.tar.gz"
        echo ""
        echo "After copying, run: docker-compose up -d"
        ;;
        
    3)
        echo ""
        echo "VNC Setup:"
        echo "1. Install VNC server on this machine"
        echo "2. Start VNC: vncserver :1"
        echo "3. Connect with VNC client from your computer"
        echo "4. In VNC session, run: docker-compose build"
        echo "5. Then run: docker-compose run --rm -e DISPLAY=:1 gphotos-cdp ..."
        echo ""
        echo "See DOCKER.md for full command."
        ;;
        
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

if [ -d "chrome-profile/Default" ]; then
    echo ""
    echo "✅ Authentication successful!"
    echo ""
    echo "Next steps:"
    echo "1. Edit .env file if needed: cp .env.example .env"
    echo "2. Start the service: docker-compose up -d"
    echo "3. View logs: docker-compose logs -f"
    echo ""
else
    echo ""
    echo "❌ Authentication incomplete or failed."
    echo "Please check the logs and try again."
fi
