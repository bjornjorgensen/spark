# Apache Spark Development Container

This directory contains the configuration for the Apache Spark Development Container. Development Containers (Dev Containers) provide a complete, isolated, and reproducible development environment using Docker.

## What is a Dev Container?

A Development Container (or Dev Container) is a Docker container specifically configured to provide a full-featured development environment. It includes:

- All necessary tools and dependencies
- Proper IDE/editor configurations
- Consistent environment across different machines
- Isolation from the host system

## Prerequisites

To use this Dev Container, you need:

1. **Docker Desktop** (or Docker Engine)
   - [Install Docker Desktop](https://www.docker.com/products/docker-desktop/)
   - Make sure Docker is running before opening the container

2. **Visual Studio Code**
   - [Download VS Code](https://code.visualstudio.com/)

3. **Dev Containers Extension**
   - Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) in VS Code

## Getting Started

### Initial Setup (First Time Only)

Before opening the dev container for the first time, run the setup script to create required directories:

```bash
# From the repository root
.devcontainer/setup.sh
```

Or manually create the directories:

```bash
mkdir -p .m2 .sbt .ivy2
```

These directories are needed for build tool caches (Maven, SBT, Ivy) and must exist before the container starts.

### Option 1: Open in Container (Recommended)

1. Open VS Code
2. Open the Spark repository folder
3. Press `F1` (or `Ctrl+Shift+P` / `Cmd+Shift+P`)
4. Type "Dev Containers: Reopen in Container"
5. Wait for the container to build (first time will take several minutes)

### Option 2: Clone and Open

1. Press `F1` in VS Code
2. Type "Dev Containers: Clone Repository in Container Volume"
3. Enter the Spark repository URL
4. Wait for the container to build and clone

## What's Included

The Dev Container includes all necessary tools for Spark development:

### Languages & Runtimes
- **Java 17** (OpenJDK)
- **Scala** (via sbt)
- **Python 3.10** with full PySpark dependencies
- **PyPy 3.10** for testing
- **R** with SparkR packages
- **Node.js & npm** for web UI development

### Build Tools
- **Apache Maven 3.9.11**
- **sbt** (Scala Build Tool)

### Python Packages
All dependencies from `dev/requirements.txt` including:
- Core: py4j, numpy, pandas, pyarrow, scipy
- ML: scikit-learn, mlflow, matplotlib
- Spark Connect: grpcio, protobuf, googleapis-common-protos
- Testing: pytest, coverage, unittest-xml-reporting
- Linting: ruff, mypy, flake8, black
- Documentation: sphinx, mkdocs, nbsphinx
- Development: jupyter, ipython, debugpy

### R Packages
- Core: devtools, knitr, testthat, arrow
- SparkR: e1071, survival, ggplot2
- Code quality: roxygen2, lintr, pkgdown

### VS Code Extensions
Pre-installed extensions for optimal development:
- Java Extension Pack
- Maven support
- Scala Metals
- Python & Pylance
- Jupyter notebooks
- Docker support
- GitLens
- YAML & XML support

## Using the Dev Container

### Building Spark

```bash
# Clean build (skip tests for faster build)
./build/mvn -DskipTests clean package

# Build with specific profile
./build/mvn -Phive -Pyarn -DskipTests clean package

# Build with tests
./build/mvn clean package
```

### Running Spark

```bash
# Start Spark Shell (Scala)
./bin/spark-shell

# Start PySpark (Python)
./bin/pyspark

# Run example
./bin/run-example SparkPi
```

### Running Tests

```bash
# Run all tests
./dev/run-tests

# Run specific module tests
./build/mvn test -pl core

# Run Python tests
./python/run-tests

# Run R tests
./R/run-tests.sh
```

### Development Commands

```bash
# Check code style (Scala)
./dev/lint-scala

# Check Python code
./dev/lint-python

# Check R code
./dev/lint-r

# Build documentation
cd docs
make html
```

## Ports

The following ports are automatically forwarded to your host machine:

- **4040**: Spark Application UI (appears when running Spark applications)
- **8080**: Spark Master UI (for standalone cluster mode)
- **8081**: Spark Worker UI (for standalone cluster mode)
- **18080**: Spark History Server

Access these UIs at `http://localhost:<port>` in your browser.

## Customization

### Modify Container Configuration

Edit [devcontainer.json](devcontainer.json) to:
- Add more VS Code extensions
- Change port forwarding
- Modify environment variables
- Add more VS Code settings

### Modify Container Image

Edit [Dockerfile](Dockerfile) to:
- Add more system packages
- Install additional tools
- Change base image
- Modify user configuration

### Post-Creation Setup

Edit [post-create.sh](post-create.sh) to:
- Run additional setup commands
- Configure git
- Set up aliases
- Initialize databases or services

## Persistent Data

The following directories are mounted from your local machine to persist data:

- `.m2` - Maven repository cache
- `.sbt` - sbt cache
- `.ivy2` - Ivy cache

This means build artifacts and dependencies will persist between container rebuilds, making subsequent builds much faster.

## Troubleshooting

### Container fails to build

1. Check Docker is running: `docker ps`
2. Check Docker has enough resources (memory, disk space)
3. Try rebuilding: `F1` → "Dev Containers: Rebuild Container"

### Build is slow

1. First build is always slow (downloads dependencies)
2. Subsequent builds use cached layers
3. Use `-DskipTests` to skip tests during development builds

### Permission issues

The container runs as user `spark-dev` (UID 1000) by default. If you need different permissions:
1. Edit the `USER_UID` arg in the Dockerfile
2. Rebuild the container

### Out of disk space

Docker containers and images can consume significant disk space:

```bash
# Clean up Docker
docker system prune -a

# Check Docker disk usage
docker system df
```

## Additional Documentation

This Dev Container includes several helpful guides:

- **[QUICKSTART.md](QUICKSTART.md)** - Quick reference for common commands
- **[PERFORMANCE.md](PERFORMANCE.md)** - Performance optimization tips
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Solutions to common issues

## Resources

- [Apache Spark Documentation](https://spark.apache.org/docs/latest/)
- [Building Spark](https://spark.apache.org/docs/latest/building-spark.html)
- [Developer Tools](https://spark.apache.org/developer-tools.html)
- [Contributing to Spark](https://spark.apache.org/contributing.html)
- [Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)

## Support

For issues with:
- **Spark development**: See [Apache Spark Contributing Guide](https://spark.apache.org/contributing.html)
- **Dev Container setup**: Open an issue in the Spark repository or check [VS Code Dev Containers docs](https://code.visualstudio.com/docs/devcontainers/containers)

## License

This Dev Container configuration is part of Apache Spark and is licensed under the Apache License 2.0. See the LICENSE file in the repository root.
