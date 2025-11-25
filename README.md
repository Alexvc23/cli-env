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

## Quick Start (TL;DR)

For experienced users who want to get started quickly:

```bash
# 1. Clone and navigate to the repository
git clone <repository-url>
cd cli-env

# 2. Create and configure .env file
cat > .env << EOF
POSTGRES_USER=myuser
POSTGRES_PASSWORD=mypassword
POSTGRES_DB=piscineds
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=admin
LOCAL_VOLUME_PATH=$HOME/docker-volumes/cli-env
EOF

# 3. Create and configure volume directory
mkdir -p ~/docker-volumes/cli-env
chmod -R a+rwX ~/docker-volumes/cli-env

# 4. Build and start
make build
make up

# 5. Access services
# - Jupyter Notebook: http://localhost:8888
# - pgAdmin: http://localhost:5050
# - CLI: make cli
```

For detailed setup instructions, see [First-Time Setup](#first-time-setup) below.

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

Both services mount a local directory (configured via `LOCAL_VOLUME_PATH` environment variable) into `/home/cliuser/downloads` within the container. If `LOCAL_VOLUME_PATH` is not set in `.env`, it defaults to `~/Downloads`.

### .env File

The `.env` file contains environment variables used by Docker Compose:
- **PostgreSQL Configuration**: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
- **pgAdmin Configuration**: `PGADMIN_DEFAULT_EMAIL`, `PGADMIN_DEFAULT_PASSWORD`
- **Volume Configuration**: `LOCAL_VOLUME_PATH` - the local directory to mount in containers (defaults to `~/Downloads`)

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

### First-Time Setup

When setting up this environment on a new computer for the first time, follow these steps:

#### 1. Prerequisites

Ensure you have the following installed:
- **Docker**: Install Docker Desktop (for Mac/Windows) or Docker Engine (for Linux)
- **Docker Compose**: Usually included with Docker Desktop, or install separately on Linux
- **Make**: Should be pre-installed on Mac/Linux; for Windows, use WSL or install via chocolatey

Verify installations:
```bash
docker --version
docker compose version
make --version
```

#### 2. Clone the Repository

```bash
git clone <repository-url>
cd cli-env
```

#### 3. Configure Environment Variables

Create or edit the `.env` file in the project root:

```bash
# Copy the example or create a new .env file
cp .env.example .env  # if an example exists
# OR
nano .env  # or use your preferred editor
```

Configure the following variables:

```properties
# PostgreSQL configuration
POSTGRES_USER=your_username
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=piscineds

# pgAdmin configuration
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=admin

# Volume configuration
# Set this to your desired local directory for persistent storage
LOCAL_VOLUME_PATH=/path/to/your/local/directory
```

**Important**: Replace `/path/to/your/local/directory` with an actual path on your system, for example:
- macOS: `/Users/yourusername/docker-volumes/cli-env`
- Linux: `/home/yourusername/docker-volumes/cli-env`
- Windows (WSL): `/mnt/c/Users/yourusername/docker-volumes/cli-env`

#### 4. Create and Configure the Volume Directory

Create the directory specified in `LOCAL_VOLUME_PATH`:

```bash
# Create the directory
mkdir -p /path/to/your/local/directory

# Set permissions to allow Docker containers to write to it
# This is crucial to avoid permission errors when working with VS Code or creating files
chmod -R a+rwX /path/to/your/local/directory
```

**Why is this needed?** The Docker containers run as a non-root user (`cliuser`) with a specific UID/GID. Making the directory world-writable ensures that the container can create, edit, and delete files without permission issues, especially when using VS Code's Remote Containers extension.

**Alternative approach** (more secure, but may require additional configuration):
```bash
# Find your user's UID and GID
id -u  # e.g., 1000
id -g  # e.g., 1000

# Change ownership to match your user
sudo chown -R $(id -u):$(id -g) /path/to/your/local/directory
```

#### 5. Validate Your Setup

Before building, validate that the volume path exists:

```bash
make validate-path
```

This will check if the directory specified in `LOCAL_VOLUME_PATH` exists and is accessible.

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

A local directory on your host machine is mounted as a volume in both the CLI and Notebook containers at `/home/cliuser/downloads`. This configuration is controlled by the `LOCAL_VOLUME_PATH` environment variable in your `.env` file.

### Configuration

- **Environment Variable**: `LOCAL_VOLUME_PATH` in `.env` file
- **Default Value**: `~/Downloads` (your user's Downloads folder)
- **Container Mount Point**: `/home/cliuser/downloads`

### How It Works

- Any file you save to the `downloads` folder inside the container will be available on your host at the path specified by `LOCAL_VOLUME_PATH`.
- This shared folder makes it easy to manage persistent data between sessions and across the CLI and Notebook environments.
- You can customize the local directory by editing `LOCAL_VOLUME_PATH` in the `.env` file.

### Customizing the Volume Path

To use a different local directory:

1. Edit the `.env` file
2. Change `LOCAL_VOLUME_PATH` to your desired path (e.g., `LOCAL_VOLUME_PATH=/Users/yourusername/projects/data`)
3. Ensure the directory exists before starting containers, or the Makefile will prompt you to create it
4. Run `make up` or `make up-cli`/`make up-notebook`

The path validation runs automatically when you start containers using the Makefile targets.

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Permission Denied Errors

**Error Message:**
```
Error: EACCES: permission denied, open '/home/cliuser/downloads/filename.txt'
```
or
```
Unable to write file ... (NoPermissions (FileSystemError))
```

**Cause:** The Docker container cannot write to the mounted volume directory due to permission restrictions.

**Solutions:**

**Option A: Make directory world-writable (easiest)**
```bash
chmod -R a+rwX /path/to/your/LOCAL_VOLUME_PATH
```

**Option B: Match ownership to your user**
```bash
sudo chown -R $(id -u):$(id -g) /path/to/your/LOCAL_VOLUME_PATH
```

**Option C: Create a new directory with proper permissions**
```bash
# Create a new directory
mkdir -p ~/docker-volumes/cli-env
chmod -R a+rwX ~/docker-volumes/cli-env

# Update .env file to use the new path
nano .env  # Edit LOCAL_VOLUME_PATH

# Restart containers
make down
make up
```

#### 2. High UID/GID Issues

**Error Message:**
```
unable to setup user: cannot setuid to unmapped uid XXXXX in user namespace
```

**Cause:** Your system uses a high user ID (UID > 65536) that Docker cannot map into the container's user namespace.

**Solution:** Do not use the `user:` directive in `docker-compose.yml`. Instead, rely on making the host directory writable (see Permission Denied solutions above). The containers will run as the `cliuser` created in the Dockerfile, and the world-writable permissions allow file operations to work correctly.

#### 3. Module Not Found Errors

**Error Message:**
```
ModuleNotFoundError: No module named 'jupyter_server.contents'
```
or
```
TypeError: warn() missing 1 required keyword-only argument: 'stacklevel'
```

**Cause:** Incompatible or missing Python packages in the environment.

**Solution:** Ensure your `requirements.txt` is up to date and that your Notebook and traitlets versions are pinned as follows:
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

#### 4. Port Already in Use

**Error Message:**
```
Error starting userland proxy: listen tcp4 0.0.0.0:8888: bind: address already in use
```

**Cause:** Another service is already using port 8888 on your host machine.

**Solution:** Either:
- Stop the conflicting service
- Change the port in `docker-compose.yml`:
  ```yaml
  ports:
    - "8889:8888"  # Use host port 8889 instead
  ```
  Then access Jupyter at `http://localhost:8889`

#### 5. Volume Path Not Found

**Error Message:**
```
Error: Volume path '/path/to/directory' does not exist.
```

**Cause:** The directory specified in `LOCAL_VOLUME_PATH` doesn't exist.

**Solution:**
```bash
# Create the directory
mkdir -p /path/to/directory

# Set permissions
chmod -R a+rwX /path/to/directory

# Restart
make up
```

#### 6. Docker Not Running

**Error Message:**
```
Cannot connect to the Docker daemon
```

**Cause:** Docker service is not running on your system.

**Solution:**
- **Mac/Windows**: Open Docker Desktop application
- **Linux**: Start Docker service:
  ```bash
  sudo systemctl start docker
  sudo systemctl enable docker  # to start on boot
  ```

#### 7. Jupyter Notebook Token Required

**Issue:** Jupyter asks for a token when you access `http://localhost:8888`.

**Solution:** Find the token in the container logs:

```bash
make logs
```

Look for a line like:
```
http://127.0.0.1:8888/?token=abc123def456...
```

Copy the token and paste it into the browser, or use the full URL with the token.

To disable token authentication (not recommended for production):
```bash
# Edit docker-compose.yml, change the notebook command to:
command: jupyter notebook --ip=0.0.0.0 --no-browser --NotebookApp.token='' --NotebookApp.password=''
```

### Getting Help

If you encounter other issues not covered here:
1. Check container logs: `make logs`
2. Check container status: `docker compose ps`
3. Verify environment variables: `cat .env`
4. Ensure Docker has enough resources (CPU/Memory) in Docker Desktop settings
5. Try a clean rebuild: `make clean && make build && make up`
6. Check Docker disk space: `docker system df`
7. Review the [Docker documentation](https://docs.docker.com/) for platform-specific issues

If the CLI environment works but the Notebook does not open, check that your host's port 8888 is not in use and verify the volume mapping if there are missing files.

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
