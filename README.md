# CLI Environment & Jupyter Notebook Environment

This repository provides a Docker-based development environment that includes two main services:

1. **CLI Environment**: An interactive Bash shell running in an Ubuntu 22.04 container.  
2. **Jupyter Notebook Environment**: A Jupyter Notebook server (pinned to a fixed version to avoid known bugs) running in its own container.

Both services share a common volume so that files (e.g. downloaded or generated data) persist between containers and are accessible from the host.

---

## Table of Contents

- [Overview](#overview)
- [File Structure](#file-structure)
- [Docker Setup](#docker-setup)
  - [Dockerfile](#dockerfile)
  - [docker-compose.yml](#docker-composeyml)
  - [requirements.txt](#requirementstxt)
- [Makefile](#makefile)
- [Usage Instructions](#usage-instructions)
  - [Building the Environment](#building-the-environment)
  - [Starting the Containers](#starting-the-containers)
  - [Using the CLI Environment](#using-the-cli-environment)
  - [Using the Jupyter Notebook Environment](#using-the-jupyter-notebook-environment)
- [Volume Mapping](#volume-mapping)
- [Troubleshooting](#troubleshooting)
- [Additional Information](#additional-information)
- [License](#license)

---

## Overview

This project is designed to provide a consistent, reproducible development environment using Docker. It is especially useful for users who want to avoid dependency and configuration issues on their host systems. The environment includes:

- **CLI Environment**: A command-line interface (shell) where you can run standard Linux commands, Python scripts, and other tools.
- **Jupyter Notebook Environment**: A web-based interactive environment for Python development, useful for data science, education, or prototyping code interactively.

The two environments are managed via Docker Compose, and all operations (build, start, stop, clean) are controlled through a Makefile. This makes the workflow simple and unified.

---

## File Structure

```
.
├── Dockerfile              # Defines the custom Docker image (Ubuntu 22.04, installs required packages)
├── Makefile                # Provides targets to build, run, and manage the Docker containers
├── PiscinePython42.code-workspace  # (Optional) Workspace file for IDE configuration
├── README.md               # This documentation file
├── docker-compose.yml      # Docker Compose configuration to run two services: cli and notebook
└── requirements.txt        # Python dependencies (with fixed versions to avoid known issues)
```

---

## Docker Setup

### Dockerfile

The `Dockerfile` is designed to:
- Start from Ubuntu 22.04.
- Install essential system packages such as `python3-pip`, `ffmpeg`, `wget`, `git`, and development tools.
- Install Python dependencies from `requirements.txt` (including:
  - `notebook==6.5.6`: includes the fix for the module import issue.
  - `traitlets==5.9.0`: downgraded to avoid the warn() bug).
- Create a non-root user (`cliuser`) for security.
- Set the working directory and create the `downloads` folder which is mounted as a volume.
- Set the default command to launch an interactive Bash shell.

### docker-compose.yml

The `docker-compose.yml` defines **two services**:
- **cli**: Runs the CLI environment with an interactive Bash shell.
- **notebook**: Runs the Jupyter Notebook server using the command:
  ```
  jupyter notebook --ip=0.0.0.0 --no-browser
  ```
  This binds the server to all interfaces and exposes it on port 8888.

Both services mount the local `./downloads` folder into `/home/cliuser/downloads` within the container.

### requirements.txt

This file specifies the Python dependencies with fixed versions to avoid known conflicts. For example:
```text
yt-dlp==2023.09.24
notebook==6.5.6
jupyter_server==1.23.6
traitlets==5.9.0
# ... other dependencies as needed ...
```
Pinning Notebook to version 6.5.6 resolves the import issue (it now correctly imports `jupyter_server.services.contents.manager.ContentsManager`), and downgrading traitlets avoids the `warn() missing stacklevel` error.

---

## Makefile

The provided Makefile simplifies management of the environment. Available targets include:

- **help**: Lists all available commands.
- **build**: Runs `docker-compose build` to build both services.
- **up**: Starts the containers in detached mode (`docker-compose up -d`).
- **down**: Stops and removes the containers (`docker-compose down`).
- **restart**: Restarts the environment (`make down && make up`).
- **cli**: Opens an interactive shell in the CLI container (`docker-compose exec cli /bin/bash`).
- **notebook**: Opens an interactive shell in the Notebook container (`docker-compose exec notebook /bin/bash`).
- **logs**: Follows the logs from both containers (`docker-compose logs -f`).
- **clean**: Removes the containers and built images (`docker-compose down --rmi all`).

---

## Usage Instructions

### Building the Environment

From the project root, run:
```bash
make build
```
This command uses Docker Compose to build the Docker images based on the Dockerfile and installs the pinned Python dependencies.

### Starting the Containers

Once the build is complete, start the environment with:
```bash
make up
```
This command will launch two containers:
- The **CLI container** for command-line operations.
- The **Notebook container** for running the Jupyter Notebook server.

### Using the CLI Environment

To open an interactive Bash shell inside the CLI container, use:
```bash
make cli
```
You can then run Linux commands, execute Python scripts, or use pip (which is installed in the container) as needed.

### Using the Jupyter Notebook Environment

After starting the containers with `make up`, open your web browser and navigate to:
```
http://localhost:8888
```
If your Notebook container starts correctly, you will see the Jupyter Notebook dashboard. You can create new notebooks, open existing ones, and use all the pre-installed tools and packages.

Alternatively, you can use:
```bash
make notebook
```
to open a shell in the Notebook container for debugging or configuration tasks.

---

## Volume Mapping

The directory `./downloads` in your project root is mounted as a volume in both containers at `/home/cliuser/downloads`. This means:
- Any file you save to the `downloads` folder inside the container will be available on your host.
- This shared folder makes it easy to manage persistent data between sessions and across the CLI and Notebook environments.

---

## Troubleshooting

If you encounter the error:
```
ModuleNotFoundError: No module named 'jupyter_server.contents'
```
or
```
TypeError: warn() missing 1 required keyword-only argument: 'stacklevel'
```
then verify that your `requirements.txt` is up to date and that your Notebook and traitlets versions are pinned as follows:
- `notebook==6.5.6`
- `traitlets==5.9.0`

To rebuild the environment after modifying dependencies:
1. Update `requirements.txt` as needed.
2. Run:
   ```bash
   make clean
   make build
   make up
   ```
3. Check container logs with:
   ```bash
   make logs
   ```
   Ensure that the Notebook container starts up without these errors.

If the CLI environment works but the Notebook does not open, check that your host’s port 8888 is not in use and verify the volume mapping if there are missing files.

---

## Additional Information

- **PiscinePython42.code-workspace**: This file is intended for configuring your IDE (e.g. Visual Studio Code) and does not affect the Docker environment.
- **Browser Access**: The Notebook server is configured not to launch a browser automatically. Open your browser manually and go to `http://localhost:8888`.
- **Environment Consistency**: All Python packages are installed inside the Docker image to ensure consistency regardless of the host environment.
- **Best Practices**: This setup isolates development in containers to avoid conflicts with system installations and allows you to update or roll back individual components by simply modifying version pins in `requirements.txt`.

---

## License

This project is released under the [MIT License](LICENSE).

---

Happy coding! If you have any questions or run into issues, feel free to open an issue or reach out via the repository’s discussion forum.
```

---

This README.md explains in detail the architecture, functionality, and how to work with the CLI and Jupyter Notebook services in your environment. Feel free to further customize or adjust it to your specific needs.