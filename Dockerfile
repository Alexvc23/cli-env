# Use Ubuntu 22.04 as base image
FROM ubuntu:22.04

# Set noninteractive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and Python3
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       python3 \
       python3-pip \
       ffmpeg \
       wget \
       git \
       build-essential \
       vim \
       tree \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Copy requirements file and install Python dependencies as root.
# This will install packages into the system site-packages.
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Create a non-root user for improved security.
RUN useradd -ms /bin/bash cliuser

# Switch to non-root user.
USER cliuser

# Set working directory to the non-root user's home.
WORKDIR /home/cliuser

# Create a directory for downloads and mark it as a Docker volume.
RUN mkdir -p downloads
VOLUME ["/home/cliuser/downloads"]

# Default command launches an interactive Bash shell.
CMD ["/bin/bash"]
