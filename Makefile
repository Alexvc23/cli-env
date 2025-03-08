# Define phony targets (targets that don't create files)
.PHONY: all check-docker build run rebuild clean-rebuild

# Default target that runs the container
all: run

# Check if Docker daemon is running, if not start Docker.app
check-docker:
	@if ! docker info >/dev/null 2>&1; then \
		echo "Docker no se está ejecutando. Iniciando Docker..."; \
		open /Applications/Docker.app; \
		while ! docker info >/dev/null 2>&1; do \
			sleep 1; \
		done; \
	fi

# Build the Docker image after checking Docker is running
build: check-docker
	# Display build message
	@echo "Construyendo la imagen Docker..."
	# Build Docker image with tag 'cli-env' using Dockerfile in current directory
	@docker build -t cli-env -f Dockerfile .
	# Check if build was successful, exit with error if not
	@if [ $$? -ne 0 ]; then \
		echo "Error: Falló la construcción de la imagen. Revisa el Dockerfile y tu configuración de Docker."; \
		exit 1; \
	fi

# Rebuild the Docker image from scratch
rebuild: check-docker
	# Stop and remove containers using the image
	@echo "Deteniendo contenedores que usan la imagen (si existen)..."
	@docker ps -a --filter ancestor=cli-env -q | xargs -r docker rm -f
	# Remove existing image if it exists
	@echo "Eliminando la imagen existente (si existe)..."
	@docker image rm cli-env || true
	# Call build target to create new image
	@$(MAKE) build

# Force rebuild without using cache
clean-rebuild: check-docker
	# Stop and remove container by name if it exists
	@echo "Deteniendo y eliminando el contenedor cli-env-container (si existe)..."
	@docker rm -f cli-env-container 2>/dev/null || true
	# Stop and remove any other containers using the image
	@echo "Deteniendo contenedores que usan la imagen (si existen)..."
	@docker ps -a --filter ancestor=cli-env -q | xargs -r docker rm -f
	# Remove existing image if it exists
	@echo "Eliminando la imagen existente (si existe)..."
	@docker image rm cli-env || true
	# Build without cache
	@echo "Construyendo la imagen Docker sin cache..."
	@docker build --no-cache -t cli-env -f Dockerfile .
	# Check if build was successful, exit with error if not
	@if [ $$? -ne 0 ]; then \
		echo "Error: Falló la construcción de la imagen. Revisa el Dockerfile y tu configuración de Docker."; \
		exit 1; \
	fi

# Run the container after ensuring image is built
run: build
	@echo "Ejecutando el contenedor..."
	@if docker ps --filter "name=cli-env-container" --filter "status=running" -q | grep -q .; then \
		echo "El contenedor cli-env-container ya está en ejecución."; \
		echo "Entrando al contenedor..."; \
		docker exec -it cli-env-container /bin/bash; \
	elif docker ps -a --filter "name=cli-env-container" -q | grep -q .; then \
		echo "Reiniciando contenedor cli-env-container existente..."; \
		docker start -ai cli-env-container; \
	else \
		docker run --name cli-env-container -it -v $(HOME)/Downloads:/home/cliuser/downloads cli-env; \
	fi

# Check if the Docker image exists, build it if it doesn't
check-image:
	@docker image inspect cli-env >/dev/null 2>&1 || { \
		echo "La imagen Docker 'cli-env' no existe. Construyéndola ahora..."; \
		$(MAKE) build; \
	}
