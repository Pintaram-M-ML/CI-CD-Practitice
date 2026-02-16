.PHONY: help build up down restart logs clean test install dev

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build Docker images
	docker-compose build

up: ## Start all services
	docker-compose up -d
	@echo ""
	@echo "✅ Application is running!"
	@echo "📱 Frontend: http://localhost:3000"
	@echo "🔌 API: http://localhost:3000/api"
	@echo "🗄️  Database: localhost:5432"
	@echo ""
	@echo "Run 'make logs' to view logs"

down: ## Stop all services
	docker-compose down

restart: down up ## Restart all services

logs: ## View logs from all services
	docker-compose logs -f

logs-backend: ## View backend logs
	docker-compose logs -f backend

logs-db: ## View database logs
	docker-compose logs -f db

clean: ## Stop services and remove volumes
	docker-compose down -v
	@echo "All services stopped and data removed"

clean-all: clean ## Remove all Docker artifacts
	docker system prune -f
	@echo "Docker system cleaned"

ps: ## Show running containers
	docker-compose ps

status: ps ## Alias for ps

test-api: ## Test the API endpoints
	@echo "Testing API health..."
	@curl -s http://localhost:3000/api/health | jq . || echo "❌ API not responding"
	@echo ""
	@echo "Testing tasks endpoint..."
	@curl -s http://localhost:3000/api/tasks | jq . || echo "❌ Tasks endpoint not responding"

install-backend: ## Install backend dependencies
	cd backend && npm install

install-frontend: ## Install frontend dependencies (if needed)
	@echo "Frontend uses vanilla JS - no dependencies to install"

install: install-backend ## Install all dependencies

dev-backend: ## Run backend in development mode (local)
	cd backend && npm run dev

dev: dev-backend ## Run in development mode (local)

shell-backend: ## Open shell in backend container
	docker exec -it taskmanager-backend sh

shell-db: ## Open PostgreSQL shell
	docker exec -it taskmanager-db psql -U postgres -d taskmanager

backup-db: ## Backup database
	docker exec taskmanager-db pg_dump -U postgres taskmanager > backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "Database backed up"

restore-db: ## Restore database (usage: make restore-db FILE=backup.sql)
	@if [ -z "$(FILE)" ]; then echo "Usage: make restore-db FILE=backup.sql"; exit 1; fi
	docker exec -i taskmanager-db psql -U postgres taskmanager < $(FILE)
	@echo "Database restored"

structure: ## Show project structure
	@tree -I 'node_modules|.git' -L 3

