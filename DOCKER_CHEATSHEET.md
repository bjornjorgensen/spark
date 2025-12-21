# Docker Development Cheat Sheet

## Quick Reference

### Starting & Connecting

```bash
# Start quick container
./docker-dev.sh

# OR start persistent container
docker-compose up -d
docker exec -it spark-development bash

# Check if container is running
docker ps

# See all containers (including stopped)
docker ps -a
```

### Inside the Container

```bash
# Fast build (no tests)
./build/mvn -DskipTests clean package

# Build specific module
./build/mvn -pl core -DskipTests package

# Run Spark shells
./bin/spark-shell          # Scala
./bin/pyspark              # Python
./bin/spark-sql            # SQL

# Run examples
./bin/run-example SparkPi 10

# Run Java/Scala tests
./build/mvn test -pl core

# Run Python tests
cd python
python run-tests                                    # All tests
python run-tests --modules pyspark-sql              # Specific module
python -m pytest pyspark/sql/tests/test_dataframe.py  # Specific file
python -m pytest -v -k "test_sample"                # Specific test

# Run Python tests with coverage
cd python
python run-tests --coverage

# Python linting
cd python
python -m flake8 pyspark
python -m mypy pyspark
ruff check pyspark

# Check Python imports work
python -c "import pyspark; print(pyspark.__version__)"
python -c "import numpy, pandas, pyarrow; print('All imports OK')"
```

### Container Management

```bash
# Exit container (but keep it running if using docker-compose)
exit

# Reconnect to running container
docker exec -it spark-development bash

# Stop container
docker stop spark-development

# Start stopped container
docker start spark-development

# Remove container
docker rm spark-development

# View container logs
docker logs spark-development

# View running processes in container
docker top spark-development
```

### Troubleshooting

```bash
# Container won't start?
docker ps -a                    # Check status
docker logs spark-development   # Check logs
docker system prune            # Clean up old containers

# Need more memory?
# Edit docker-compose.yml and add:
#   deploy:
#     resources:
#       limits:
#         memory: 8G

# Can't connect to ports?
docker port spark-development   # Check port mappings

# Files not syncing?
# Make sure you're in /workspace inside container
pwd  # Should show /workspace
```

## Common Workflows

### Daily Development

```bash
# Morning: Start container
docker-compose up -d
docker exec -it spark-development bash

# Work on code (edit on host with VS Code)
# Build inside container
./build/mvn -DskipTests package

# Test your changes
./build/mvn test -pl core

# Evening: Stop container
exit
docker-compose down
```

### Quick Test

```bash
# One-off container for testing
./docker-dev.sh
./build/mvn clean package
./bin/spark-shell
# Test something
exit  # Container auto-deleted
```

### Multiple Terminals

```bash
# Terminal 1
docker exec -it spark-development bash
./build/mvn -DskipTests package

# Terminal 2 (while building)
docker exec -it spark-development bash
./bin/spark-shell

# Terminal 3 (monitoring)
docker stats spark-development
```

## File Locations

Inside the container:
- Your code: `/workspace`
- Maven cache: `/root/.m2`
- Build output: `/workspace/target`

On your host:
- Your code: `/home/bjorn/github/spark`
- Maven cache: `~/.m2` (synced!)
- Changes in container appear instantly on host!

## Tips

✅ **DO:**
- Edit files on your host machine (VS Code, vim, etc.)
- Run builds inside the container
- Keep container running during work sessions
- Use docker-compose for multi-day projects

❌ **DON'T:**
- Install things on host if you're using Docker
- Edit files inside container (use host instead)
- Forget to stop containers when done (wastes resources)

## Need Help?

```bash
# Docker help
docker --help
docker run --help

# Container shell
docker exec -it spark-development bash

# Check what's using disk space
docker system df

# Clean everything
docker system prune -a
```
