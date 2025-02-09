# CLI Environment

This repository provides a command-line interface (CLI) environment. The project folder is:

## File Structure

Below is the directory structure for the project:

/cli-env  
├── README.md  
├── Dockerfile  
├── docker_dev_env.sh  
└── downloads/         # Folder for storing downloaded files

## Docker Environment

This project includes a Docker environment to provide a consistent and isolated CLI setup.

### Dockerfile

- **Base Image**:  
    Uses Ubuntu 22.04 as the base image, providing a stable Linux environment.

- **Environment Variable**:  
    Sets `DEBIAN_FRONTEND` to `noninteractive` to avoid prompts during package installations.

- **System Preparation**:  
    Runs `apt-get update` followed by installing essential tools (like `python3-pip`, `ffmpeg`, `wget`, `git`, text editors, and compilers). After installation, it cleans up the package lists to reduce image size.

- **Python Package Installation**:  
    Installs the latest version of `yt-dlp` using pip, ensuring that the container has the necessary Python tool for downloading media.

- **Workspace Setup & Volumes**:  
    Creates a working directory at `/home/cliuser` and a dedicated folder `/home/cliuser/downloads` for file storage. The `VOLUME` instruction indicates that this downloads folder can be mapped to a host directory.

- **Default Command**:  
    The container starts an interactive Bash shell by default.

### docker_dev_env.sh

- **Docker Availability Check (Mac-specific)**:  
    The script checks if Docker is running. If not, it opens the Docker application (Mac-only feature) and waits until Docker is ready.

- **Variables**:  
    - `IMAGE_NAME` defines the name for the Docker image.  
    - `DOCKERFILE` specifies the Dockerfile to use for building.  
    - `DOWNLOADS_HOST` and `DOWNLOADS_CONTAINER` determine the paths on the host and container to map the downloads folder.

- **Image Building**:  
    The script echoes progress messages, builds the Docker image from the provided Dockerfile, and checks for any errors during the build process.

- **Container Execution**:  
    Finally, it runs the container interactively (`-it`) and mounts the host's downloads folder into the container. This way, any files downloaded within the container will be accessible on the host system.

## Why This Solution Works Well

1. **Operating System Independence**
    - Your older MacBook might be stuck on an older macOS version
    - Some modern CLI tools require newer OS versions or dependencies
    - The Docker environment runs Ubuntu 22.04, giving you access to the latest tools regardless of your host OS

2. **Consistent Environment**
    - Provides a fresh, clean Ubuntu environment every time
    - All necessary tools are pre-installed (`ffmpeg`, `python3-pip`, `wget`, etc.)
    - No conflicts with your existing MacBook setup

3. **Resource Management**
    - Docker containers are lightweight compared to full VMs
    - You can use modern tools without upgrading your hardware
    - The environment only uses resources when you need it

4. **File Access**
    - The `downloads` folder is shared between your Mac and the container
    - Work in the container but easily access files on your MacBook

## How to Use It

1. Install Docker for Mac (compatible with older versions)
2. Run the `Makefile`
3. Work inside the container with all tools available
4. Find your downloaded files in the local `downloads` folder
