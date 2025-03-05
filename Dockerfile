# Usamos una imagen base de Ubuntu 22.04
FROM ubuntu:22.04

# Sets environment variable to prevent interactive prompts during package installation
# This is particularly useful for automated builds where user input isn't possible
# The noninteractive frontend ensures apt-get doesn't stop for user input
ENV DEBIAN_FRONTEND=noninteractive

# Actualizamos el sistema e instalamos paquetes básicos y dependencias
RUN apt-get update && apt-get install -y \
    python3-pip \
    ffmpeg \
    wget \
    ca-certificates \
    git \
    vim \
    nano \
    less \
    curl \
    build-essential \
    tree \
    && rm -rf /var/lib/apt/lists/*

# Instalamos la última versión de yt-dlp usando pip
RUN pip3 install --no-cache-dir --upgrade yt-dlp

# Creamos un directorio de trabajo (opcional)
WORKDIR /home/cliuser

# Indicamos que se pueda montar un volumen para descargas (opcional)
VOLUME ["/home/cliuser/downloads"]

# Establecemos el directorio de descargas
RUN mkdir -p /home/cliuser/downloads

# Comando por defecto: abrir una shell interactiva
CMD ["bash"]
