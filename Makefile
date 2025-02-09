# Define phony targets (targets that don't create files)
.PHONY: all check-docker build run rebuild

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

# Run the container after ensuring image is built
run: build
	# Display run message
	@echo "Ejecutando el contenedor..."
	# Run container with Downloads folder mounted and interactive terminal
	@docker run -it -v $(HOME)/Downloads:/home/cliuser/downloads cli-env

# Check if the Docker image exists, build it if it doesn't
check-image:
	@docker image inspect cli-env >/dev/null 2>&1 || { \
		echo "La imagen Docker 'cli-env' no existe. Construyéndola ahora..."; \
		$(MAKE) build; \
	}
