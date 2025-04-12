.PHONY: help build up down restart cli notebook logs clean

# Display available commands.
help:
	@echo "Makefile commands:"
	@echo "  make build       - Build Docker images for CLI and Notebook"
	@echo "  make up          - Start both CLI and Notebook containers (detached)"
	@echo "  make down        - Stop and remove both containers"
	@echo "  make restart     - Restart the entire environment"
	@echo "  make cli         - Open an interactive shell in the CLI container"
	@echo "  make notebook    - Open an interactive shell in the Notebook container"
	@echo "  make logs        - Follow logs from both containers"
	@echo "  make clean       - Stop containers and remove built images"

# Build the Docker images via Docker Compose.
build: ensure-docker
	docker compose build

# Start the containers in detached mode.
up: ensure-docker
	docker compose up -d

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
