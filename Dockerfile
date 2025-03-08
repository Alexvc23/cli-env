# Use the latest stable version of Ubuntu
FROM ubuntu:latest

# Sets environment variable to prevent interactive prompts during package installation
# This is particularly useful for automated builds where user input isn't possible
# The noninteractive frontend ensures apt-get doesn't stop for user input
ENV DEBIAN_FRONTEND=noninteractive

# Actualizamos el sistema e instalamos paquetes básicos y dependencias
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-get update && \
    apt-get install -y \
    python3-pip \
    python3-venv \
    ffmpeg \
    wget \
    ca-certificates \
    git \
    vim \
    nano \
    less \
    curl \
    build-essential \
    tree && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Get Python version and install appropriate venv package
RUN PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2) && \
    apt-get update && \
    apt-get install -y python${PYTHON_VERSION}-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Instalamos la última versión de yt-dlp usando pip
RUN pip3 install --no-cache-dir --upgrade yt-dlp --break-system-packages

# Creamos un directorio de trabajo (opcional)
WORKDIR /home/cliuser

# Indicamos que se pueda montar un volumen para descargas (opcional)
VOLUME ["/home/cliuser/downloads"]

# Establecemos el directorio de descargas
RUN mkdir -p /home/cliuser/downloads

# Install zsh and other useful terminal tools
RUN apt-get update && \
    apt-get install -y zsh \
    powerline \
    fonts-powerline \
    locales && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Oh My Zsh for better terminal experience
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Configure zsh with some sensible defaults
RUN echo 'export LANG=en_US.UTF-8' >> /root/.zshrc && \
    echo 'export TERM=xterm-256color' >> /root/.zshrc && \
    echo 'plugins=(git python pip docker)' >> /root/.zshrc && \
    echo 'ZSH_THEME="agnoster"' >> /root/.zshrc

# Set zsh as default shell
RUN chsh -s $(which zsh)

# Use zsh as the default command
CMD ["zsh"]
