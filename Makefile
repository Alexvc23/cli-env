.PHONY: help build up up-cli up-notebook down stop restart cli notebook logs clean validate-path

# Display available commands.
help:
	@echo "Makefile commands:"
	@echo "  make help          - Display this help information"
	@echo "  make build         - Build Docker images"
	@echo "  make up            - Start all containers (detached)"
	@echo "  make up-cli        - Start only the CLI container (detached)"
	@echo "  make up-notebook   - Start only the Notebook container (detached)"
	@echo "  make up-postgres   - Start only the Postgres container (detached)"
	@echo "  make up-pgadmin    - Start only the pgAdmin container (detached)"
	@echo "  make down          - Stop and remove containers"
	@echo "  make stop          - Stop containers without removing them"
	@echo "  make restart       - Restart the entire environment"
	@echo "  make cli           - Open an interactive shell in the CLI container"
	@echo "  make notebook      - Open an interactive shell in the Notebook container"
	@echo "  make logs          - Follow logs from all containers"
	@echo "  make clean         - Stop containers and remove built images"
	@echo "  make re-cli        - Clean and rebuild the CLI container"
	@echo "  make re-notebook   - Clean and rebuild the Notebook container"
	@echo "  make re-postgres   - Clean and rebuild the Postgres container"
	@echo "  make re-pgadmin    - Clean and rebuild the pgAdmin container"
	@echo "  make clean-cli     - Clean only the CLI container"
	@echo "  make clean-notebook- Clean only the Notebook container"
	@echo "  make clean-postgres- Clean only the Postgres container"
	@echo "  make clean-pgadmin - Clean only the pgAdmin container"
	@echo "  make ensure-docker - Ensure Docker is running"
	@echo "  make validate-path - Validate that the volume path exists"


# Validate that the volume path exists and is accessible
validate-path:
	@VOLUME_PATH=$${LOCAL_VOLUME_PATH:-~/Downloads}; \
	EXPANDED_PATH=$$(eval echo $$VOLUME_PATH); \
	if [ ! -d "$$EXPANDED_PATH" ]; then \
		echo "Error: Volume path '$$EXPANDED_PATH' does not exist."; \
		echo "Please create the directory or update LOCAL_VOLUME_PATH in your .env file."; \
		echo "To create the directory, run: mkdir -p $$EXPANDED_PATH"; \
		exit 1; \
	fi; \
	echo "Volume path validated: $$EXPANDED_PATH"

# Build the Docker images via Docker Compose.
build: ensure-docker
	docker compose build

# Start the containers in detached mode.
up: ensure-docker validate-path
	docker compose up -d

# Start only the CLI container
up-cli: ensure-docker validate-path
	docker compose up -d cli

# Start only the Notebook container
up-notebook: ensure-docker validate-path
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

# Stop containers without removing them.
stop:
	docker compose stop

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
