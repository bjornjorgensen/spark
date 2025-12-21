# Using Apache Spark's Official Docker Images

## Overview

**Good news!** Spark includes official Docker images for development and testing. You don't need to create custom Dockerfiles - use what the Spark team provides!

## Available Images

### 1. **Full Development Image** (Recommended)
**Location:** `dev/infra/Dockerfile`

**Includes:**
- Java 17 (OpenJDK)
- Python 3.9, 3.10, 3.11, 3.12, 3.13
- PyPy 3.10
- R with SparkR packages
- Maven
- npm (for web UI)
- All PySpark dependencies: numpy, pandas, pyarrow, torch, scikit-learn, mlflow, etc.
- All R packages: devtools, testthat, arrow, ggplot2, etc.

**Use this for:** General development, testing multiple Python versions, full Spark testing

### 2. **Python-Specific Images**
**Location:** `dev/spark-test-image/python-{version}/Dockerfile`

**Available versions:**
- `python-310/` - Python 3.10 only
- `python-311/` - Python 3.11 only
- `python-312/` - Python 3.12 only
- `python-313/` - Python 3.13 only
- `python-314/` - Python 3.14 only (experimental)

**Use this for:** Testing specific Python version compatibility

### 3. **PyPy Images**
**Location:** `dev/spark-test-image/pypy-{version}/Dockerfile`

**Available:**
- `pypy-310/` - PyPy 3.10
- `pypy-311/` - PyPy 3.11

**Use this for:** Performance testing, PyPy compatibility

### 4. **Specialized Images**
- `lint/` - Just linting tools (smaller, faster)
- `docs/` - Documentation building
- `sparkr/` - R development only

## Quick Start

The `docker-dev.sh` script automatically uses the full infra image:

```bash
./docker-dev.sh
```

First run builds the image (5-10 minutes), then you're in!

## Using Different Images

### Option 1: Edit docker-dev.sh

Change the image to use a specific Python version:

```bash
# Instead of dev/infra/Dockerfile
docker build -f dev/spark-test-image/python-312/Dockerfile -t spark-py312 .
```

### Option 2: Build Manually

```bash
# Build Python 3.12 image
docker build -f dev/spark-test-image/python-312/Dockerfile -t spark-py312 .

# Run it
docker run -it --rm \
  -v "$(pwd)":/workspace \
  -v "$HOME/.m2":/root/.m2 \
  -w /workspace \
  spark-py312 bash
```

### Option 3: Use docker-compose

The `docker-compose.yml` is already configured to use the full infra image.

## Why Use Official Images?

✅ **Same as CI/CD** - Exact environment used by GitHub Actions  
✅ **Well-maintained** - Updated by Spark committers  
✅ **Complete** - All dependencies pre-installed  
✅ **Tested** - Used by thousands of builds daily  
✅ **No surprises** - Works locally = works in CI  

## Testing Multiple Python Versions

The infra image includes all Python versions:

```bash
# Start container
./docker-dev.sh

# Build Spark once
./build/mvn -DskipTests clean package

# Test with Python 3.10
cd python
python3.10 run-tests --modules pyspark-sql

# Test with Python 3.11
python3.11 run-tests --modules pyspark-sql

# Test with Python 3.12
python3.12 run-tests --modules pyspark-sql

# Test with PyPy
pypy3 run-tests --modules pyspark-core
```

## Image Sizes

Approximate sizes after building:

- **dev/infra** - ~4.5 GB (full dev environment)
- **python-310** - ~2 GB (minimal Python 3.10)
- **pypy-310** - ~2 GB (PyPy only)
- **lint** - ~1 GB (linting tools only)

## Updating Images

Spark's official images are updated regularly. To get the latest:

```bash
# Remove old image
docker rmi spark-dev-infra

# Rebuild
./docker-dev.sh  # Rebuilds automatically
```

## Source Files

All Dockerfiles are in the Spark repository:
- Full image: [dev/infra/Dockerfile](https://github.com/apache/spark/blob/master/dev/infra/Dockerfile)
- Python images: [dev/spark-test-image/](https://github.com/apache/spark/tree/master/dev/spark-test-image)

## Comparison: Custom vs Official

| Feature | Custom Dockerfile | Official Spark Images |
|---------|------------------|----------------------|
| Maintenance | You maintain it | Spark team maintains |
| CI parity | Maybe different | Exact same |
| Python versions | Choose one | All versions included |
| Dependencies | Manual install | Pre-tested versions |
| Updates | Manual | Automatic with Spark |
| Size | Smaller (1-2GB) | Larger (4-5GB) |
| Best for | Simple projects | Spark development |

## Recommendation

**Use the official infra image** (`dev/infra/Dockerfile`) for Spark development:
- It's what the Spark team uses
- Includes everything you need
- Tested and maintained
- Saves time configuring dependencies

The `docker-dev.sh` and `docker-compose.yml` scripts already use it!
