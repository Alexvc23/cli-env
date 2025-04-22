.PHONY: help build up up-cli up-notebook down restart cli notebook logs clean

# Display available commands.
help:
	@echo "Makefile commands:"
	@echo "  make help        - Display this help information"
	@echo "  make build       - Build Docker images"
	@echo "  make up          - Start all containers (detached)"
	@echo "  make up-cli      - Start only the CLI container (detached)"
	@echo "  make up-notebook - Start only the Notebook container (detached)"
	@echo "  make up-postgres - Start only the Postgres container (detached)"
	@echo "  make up-pgadmin  - Start only the pgAdmin container (detached)"
	@echo "  make down        - Stop and remove containers"
	@echo "  make restart     - Restart the entire environment"
	@echo "  make cli         - Open an interactive shell in the CLI container"
	@echo "  make notebook    - Open an interactive shell in the Notebook container"
	@echo "  make logs        - Follow logs from all containers"
	@echo "  make clean       - Stop containers and remove built images"
	@echo "  make ensure-docker - Ensure Docker is running"

# Build the Docker images via Docker Compose.
build: ensure-docker
	docker compose build

# Start the containers in detached mode.
up: ensure-docker
	docker compose up -d

# Start only the CLI container
up-cli: ensure-docker
	docker compose up -d cli

# Start only the Notebook container
up-notebook: ensure-docker
	docker compose up -d notebook

# Start only the Postgres container
up-postgres: ensure-docker
	docker compose up -d postgres 
	
# Start only the pgAdmin container
up-pgadmin: ensure-docker
	docker compose up -d pgadmin 

# Stop and remove the containers.
down:
	docker compose down

# Restart the containers.
restart: down up

# Open an interactive shell in the CLI container.
cli:
	docker compose exec cli /bin/bash

# Open an interactive shell in the Notebook container.
notebook:
	docker compose exec notebook /bin/bash

# Follow logs from all containers.
logs:
	docker compose logs -f

# Stop containers and remove the built images.
clean:
	docker compose down --rmi all

# Clean and rebuild the CLI container
re-cli: clean-cli
	docker compose build cli
	docker compose up -d cli

# Clean and rebuild the Notebook container
re-notebook: clean-notebook
	docker compose build notebook
	docker compose up -d notebook

# Clean and rebuild the Postgres container
re-postgres: clean-postgres
	docker compose build postgres
	docker compose up -d postgres

# Clean and rebuild the pgAdmin container
re-pgadmin: clean-pgadmin
	docker compose build pgadmin
	docker compose up -d pgadmin

# Clean only the CLI container
clean-cli:
	docker compose rm -sf cli
	docker rmi $(shell docker images -q cli:latest 2>/dev/null) 2>/dev/null || true

# Clean only the Notebook container
clean-notebook:
	docker compose rm -sf notebook
	docker rmi $(shell docker images -q notebook:latest 2>/dev/null) 2>/dev/null || true

# Clean only the Postgres container
clean-postgres:
	docker compose rm -sf postgres
	docker rmi $(shell docker images -q postgres:latest 2>/dev/null) 2>/dev/null || true

# Clean only the pgAdmin container
clean-pgadmin:
	docker compose rm -sf pgadmin
	docker rmi $(shell docker images -q pgadmin:latest 2>/dev/null) 2>/dev/null || true

# Ensure Docker is running
ensure-docker:
	@if ! docker info > /dev/null 2>&1; then \
		echo "Docker is not running. Starting Docker..."; \
		open -a Docker; \
		echo "Waiting for Docker to start..."; \
		until docker info > /dev/null 2>&1; do \
			sleep 2; \
		done; \
		echo "Docker is now running."; \
	else \
		echo "Docker is already running."; \
	fi
