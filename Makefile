.PHONY: help build up down restart logs status shell clean clean-all rebuild stats update auth learn chrome-debug chrome-debug-stop chrome-debug-logs

help: ## Show this help
	@echo "gphotos-cdp Docker Commands"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "First time setup: make auth"

auth: ## Run authentication setup
	@./setup-auth.sh

learn: ## Run learning mode to create new locale
	@echo "Starting Learning Mode..."
	@docker-compose run --rm -it gphotos-cdp \
		gphotos-cdp -learn -profile /data/profile -dldir /data/photos

build: ## Build Docker image
	docker-compose build

up: ## Start service in background
	docker-compose up -d
	@echo "Service started. View logs with: make logs"

down: ## Stop service
	docker-compose down

restart: ## Restart service
	docker-compose restart

logs: ## Follow logs (Ctrl+C to exit)
	docker-compose logs -f --tail=100

status: ## Show container status and recent logs
	@echo "=== Container Status ==="
	@docker-compose ps
	@echo ""
	@echo "=== Recent Logs ==="
	@docker-compose logs --tail=20

shell: ## Open shell in running container
	docker-compose exec gphotos-cdp /bin/bash

clean: ## Remove containers and volumes
	docker-compose down -v

clean-all: ## Remove everything including profile (requires re-auth)
	docker-compose down -v
	rm -rf chrome-profile/*
	@echo "All data cleaned. Run 'make auth' to re-authenticate."

rebuild: ## Rebuild image from scratch
	docker-compose build --no-cache
	docker-compose up -d

stats: ## Show resource usage and disk space
	@echo "=== Resource Usage ==="
	@docker stats --no-stream gphotos-cdp 2>/dev/null || echo "Container not running"
	@echo ""
	@echo "=== Disk Usage ==="
	@echo "Photos: $$(du -sh photos 2>/dev/null | cut -f1 || echo '0')"
	@echo "Profile: $$(du -sh chrome-profile 2>/dev/null | cut -f1 || echo '0')"

update: ## Pull latest code and rebuild
	git pull
	docker-compose build
	docker-compose up -d
	@echo "Updated and restarted."

# Chrome Remote Debugging Commands
chrome-debug: ## Start Chrome in remote debugging mode (port 9222)
	@./chrome-debug.sh

chrome-debug-stop: ## Stop Chrome remote debugging
	docker-compose stop chrome-debug

chrome-debug-logs: ## View Chrome debug logs
	docker-compose logs -f chrome-debug

chrome-debug-status: ## Check Chrome debug status
	@docker-compose ps chrome-debug
	@echo ""
	@curl -s http://localhost:9222/json/version 2>/dev/null | python3 -m json.tool || echo "Chrome not responding on port 9222"
