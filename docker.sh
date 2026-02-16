#!/bin/bash
# Makefile-like helper script for common Docker operations

set -e

CMD=${1:-help}

case $CMD in
    build)
        echo "Building Docker image..."
        docker-compose build
        ;;
        
    up)
        echo "Starting service..."
        docker-compose up -d
        echo "Service started. View logs with: ./docker.sh logs"
        ;;
        
    down)
        echo "Stopping service..."
        docker-compose down
        ;;
        
    restart)
        echo "Restarting service..."
        docker-compose restart
        ;;
        
    logs)
        docker-compose logs -f --tail=100
        ;;
        
    status)
        echo "=== Container Status ==="
        docker-compose ps
        echo ""
        echo "=== Recent Logs ==="
        docker-compose logs --tail=20
        ;;
        
    shell)
        echo "Opening shell in container..."
        docker-compose exec gphotos-cdp /bin/bash
        ;;
        
    clean)
        echo "⚠️  This will remove containers and anonymous volumes."
        read -p "Continue? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose down -v
            echo "Cleaned."
        fi
        ;;
        
    clean-all)
        echo "⚠️  This will remove containers, volumes, AND profile data."
        echo "You will need to re-authenticate!"
        read -p "Continue? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose down -v
            rm -rf chrome-profile/*
            echo "All data cleaned. Run ./setup-auth.sh to re-authenticate."
        fi
        ;;
        
    rebuild)
        echo "Rebuilding from scratch..."
        docker-compose build --no-cache
        docker-compose up -d
        ;;
        
    stats)
        echo "=== Resource Usage ==="
        docker stats --no-stream gphotos-cdp
        echo ""
        echo "=== Disk Usage ==="
        echo "Photos: $(du -sh photos 2>/dev/null | cut -f1 || echo '0')"
        echo "Profile: $(du -sh chrome-profile 2>/dev/null | cut -f1 || echo '0')"
        ;;
        
    update)
        echo "Pulling latest code and rebuilding..."
        git pull
        docker-compose build
        docker-compose up -d
        echo "Updated and restarted."
        ;;
        
    learn)
        echo "🎓 Starting Learning Mode..."
        docker-compose run --rm -it gphotos-cdp \
            gphotos-cdp -learn -profile /data/profile -dldir /data/photos
        ;;
        
    help|*)
        echo "gphotos-cdp Docker Helper"
        echo ""
        echo "Usage: ./docker.sh <command>"
        echo ""
        echo "Commands:"
        echo "  build       Build Docker image"
        echo "  up          Start service in background"
        echo "  down        Stop service"
        echo "  restart     Restart service"
        echo "  logs        Follow logs (Ctrl+C to exit)"
        echo "  status      Show container status and recent logs"
        echo "  shell       Open shell in running container"
        echo "  clean       Remove containers and volumes"
        echo "  clean-all   Remove everything including profile (requires re-auth)"
        echo "  rebuild     Rebuild image from scratch"
        echo "  stats       Show resource usage and disk space"
        echo "  update      Pull latest code and rebuild"
        echo "  learn       Run learning mode to create locale"
        echo "  help        Show this help"
        echo ""
        echo "First time setup: ./setup-auth.sh"
        ;;
esac
