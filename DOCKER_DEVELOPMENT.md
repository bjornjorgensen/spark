# Simple Docker Development for Apache Spark

## Overview

Spark includes **official Docker images** for development and testing in `dev/infra/` and `dev/spark-test-image/`. These are the same images used by Spark's CI/CD pipeline.

This guide shows how to use them for local development.

## Quick Start (30 seconds)

**Step 1: Start the container (first time builds the official Spark infra image)**
```bash
./docker-dev.sh
```
*First run takes 5-10 minutes to build the official Spark infra image.*

**What you get:**
- ✅ Java 17 (OpenJDK)
- ✅ **Python 3.9, 3.10, 3.11, 3.12, 3.13** (all versions!)
- ✅ **PyPy 3.10** for testing
- ✅ **R** with all SparkR packages
- ✅ All PySpark dependencies (numpy, pandas, pyarrow, torch, etc.)
- ✅ Maven with build caches
- ✅ npm for web UI development

**Step 2: Test the environment**
```bash
./test-docker-env.sh
```

**Step 3: Build Spark**
```bash
./build/mvn -DskipTests clean package
```

**Step 4: Test different Python versions**
```bash
# Python 3.10 (default Ubuntu version)
python3.10 --version
./bin/pyspark

# Python 3.11
PYSPARK_PYTHON=python3.11 ./bin/pyspark

# Python 3.12
PYSPARK_PYTHON=python3.12 ./bin/pyspark

# Python 3.13
PYSPARK_PYTHON=python3.13 ./bin/pyspark

# PyPy (for performance testing)
PYSPARK_PYTHON=pypy3 ./bin/pyspark
```

That's it! This is the **exact same environment** Spark's CI uses.

---

## Detailed Guide

### Option 1: Quick Docker Container (Recommended)

**Start the container:**
```bash
cd /home/bjorn/github/spark
./docker-dev.sh
```

You'll see a bash prompt like: `root@abc123:/workspace#`

**What just happened:**
- Built the **official Spark infra Docker image** from `dev/infra/Dockerfile`
- This is the **same image** used by Apache Spark's GitHub Actions CI
- Includes Java 17, Maven, Python 3.9-3.13, PyPy, R, and all dependencies
- Your Spark code is mounted at `/workspace`
- Build caches mounted (`.m2`, `.ivy2`, `.sbt`)
- Ports forwarded: 4040, 8080, 8081, 18080

**Build Spark:**
```bash
./build/mvn -DskipTests clean package
```

**Test with different Python versions:**
```bash
# Test with Python 3.10 (default)
cd python && python3.10 run-tests --modules pyspark-sql

# Test with Python 3.11
cd python && python3.11 run-tests --modules pyspark-sql

# Test with Python 3.12
cd python && python3.12 run-tests --modules pyspark-sql

# Test with PyPy (faster execution)
cd python && pypy3 run-tests --modules pyspark-core
```

**Run shells:**
```bash
# Scala shell
./bin/spark-shell

# PySpark with default Python
./bin/pyspark

# PySpark with specific Python version
PYSPARK_PYTHON=python3.12 ./bin/pyspark

# SparkR
R
library(SparkR)
```

**Exit the container:**
```bash
exit
```

**Reconnect later:**
The script uses `--rm` so the container is deleted when you exit. Just run `./docker-dev.sh` again.
Your build artifacts and dependencies are preserved in the mounted volumes!

---

### Option 2: Persistent Container with Docker Compose

For longer development sessions where you don't want to exit/restart:

**Step 1: Start the container (detached mode)**
```bash
docker-compose up -d
```

**Step 2: Enter the container**
```bash
docker exec -it spark-development bash
```

**Step 3: Build and develop**
```bash
./build/mvn -DskipTests clean package
./bin/spark-shell
```

**Step 4: Exit without stopping the container**
```bash
exit  # Just exits your session, container keeps running
```

**Step 5: Re-enter anytime**
```bash
docker exec -it spark-development bash
```

**Step 6: Stop when done for the day**
```bash
docker-compose down
```

**Benefits:**
- Container stays running between sessions
- Faster to reconnect
- Can run background processes
- Better for multi-day development

---

### Option 3: Open Multiple Terminal Sessions

You can connect multiple terminals to the same running container:

**Terminal 1 (build):**
```bash
docker exec -it spark-development bash
./build/mvn -DskipTests package
```

**Terminal 2 (run tests):**
```bash
docker exec -it spark-development bash
./build/mvn test -pl core
```

**Terminal 3 (run shell):**
```bash
docker exec -it spark-development bash
./bin/spark-shell
```

---

### Connecting from VS Code

You can use VS Code to connect to your running container:

1. Install the "Docker" extension in VS Code
2. In the Docker panel, right-click your running container
3. Select "Attach Visual Studio Code"
4. A new VS Code window opens inside the container!

Or use the Remote Explorer:
1. Open Command Palette (F1)
2. "Remote-Containers: Attach to Running Container"
3. Select `spark-development`

---

### Accessing Spark UIs

While developing in the container, access UIs from your browser:

- **Spark Application UI**: http://localhost:4040
- **Spark Master UI**: http://localhost:8080  
- **Spark Worker UI**: http://localhost:8081
- **History Server**: http://localhost:18080

The ports are automatically forwarded!

## Option 2: Docker Compose (Better for long sessions)

```bash
# Start the container
docker-compose up -d

# Enter the container
docker exec -it spark-development bash

# When done
docker-compose down
```

## Option 3: Native Development (No Docker)

On your SSH remote machine, install directly:

```bash
# Install Java 17
sudo apt-get update
sudo apt-get install openjdk-17-jdk maven

# Build Spark
./build/mvn -DskipTests clean package
```

## Why These Are Better for SSH

1. **No VS Code complexity**: Works with any editor
2. **No file sync issues**: Everything stays on the remote machine
3. **Faster**: No container rebuilding needed
4. **Simpler debugging**: Standard Docker commands

## Quick Build Commands

```bash
# Fast build (no tests)
./build/mvn -DskipTests clean package

# Build specific module
./build/mvn -pl core -DskipTests package

# Run Spark shell
./bin/spark-shell

# Run PySpark
./bin/pyspark
```

## Cleaning Up

The `.devcontainer` folder is now ignored by git, so you can:

1. Keep it for potential future use
2. Delete it: `rm -rf .devcontainer`

Your choice! The native build tools work great without containers.
