# Apache Spark Dev Container - Quick Reference

## Opening the Dev Container

1. Open VS Code
2. Open the Spark repository folder
3. Press `F1` → "Dev Containers: Reopen in Container"
4. Wait for container to build (first time takes ~15-20 minutes)

## Essential Commands

### Building Spark

```bash
# Fast build (no tests)
./build/mvn -DskipTests clean package

# Full build with tests
./build/mvn clean package

# Build specific profile (e.g., with Hive and YARN)
./build/mvn -Phive -Pyarn -DskipTests clean package

# Build using sbt
./build/sbt clean package
```

### Running Spark Shells

```bash
# Scala shell
./bin/spark-shell

# Python shell
./bin/pyspark

# SQL shell
./bin/spark-sql

# R shell
./bin/sparkR

# Spark Connect shell
./bin/spark-connect-shell
```

### Running Examples

```bash
# Run Pi estimation example
./bin/run-example SparkPi

# Run with specific master
MASTER=local[4] ./bin/run-example SparkPi 100
```

### Testing

```bash
# Run all tests (takes hours!)
./dev/run-tests

# Test specific module
./build/mvn test -pl core
./build/mvn test -pl sql/core

# Python tests
cd python
python run-tests

# R tests
cd R
./run-tests.sh

# Run specific Python test file
cd python
python -m pytest pyspark/sql/tests/test_dataframe.py

# Run specific test
cd python
python -m pytest pyspark/sql/tests/test_dataframe.py::DataFrameTests::test_sample
```

### Code Quality

```bash
# Lint Scala code
./dev/lint-scala

# Lint Python code
./dev/lint-python

# Lint R code
./dev/lint-r

# Lint Java code
./dev/lint-java

# Check JavaScript/web code
./dev/lint-js

# Format Python code with Black
black python/pyspark

# Run Ruff linter
ruff check python/pyspark
```

### Documentation

```bash
# Build all documentation
cd docs
make html

# View docs (after building)
cd docs/_build/html
python -m http.server 8000
# Then open http://localhost:8000

# Build Python docs only
cd python/docs
make html

# Build R docs
cd R
./create-docs.sh
```

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/my-feature

# Check status
git status

# Stage changes
git add <files>

# Commit
git commit -m "Description"

# Push to fork
git push origin feature/my-feature
```

## VS Code Tips

### Keyboard Shortcuts

- `F1` or `Ctrl+Shift+P`: Command Palette
- `Ctrl+P`: Quick file open
- `Ctrl+Shift+F`: Search across files
- `Ctrl+T`: Go to symbol
- `F12`: Go to definition
- `Shift+F12`: Find all references
- `Ctrl+K Ctrl+R`: Restart Dev Container

### Useful Commands (F1)

- "Dev Containers: Reopen in Container"
- "Dev Containers: Rebuild Container"
- "Dev Containers: Rebuild Without Cache"
- "Dev Containers: Show Log"
- "Terminal: Create New Terminal"

## Accessing UIs

Once Spark applications are running, access UIs at:

- **Spark Application UI**: http://localhost:4040
- **Spark Master UI**: http://localhost:8080
- **Spark Worker UI**: http://localhost:8081
- **History Server**: http://localhost:18080

## Working with Multiple Languages

### Scala Development

```bash
# Use Metals extension (pre-installed)
# Import build: F1 → "Metals: Import build"

# Run specific Scala test
./build/mvn test -pl core -Dtest=org.apache.spark.SparkContextSuite
```

### Python Development

```bash
# Activate Python extension features
# Pylance provides IntelliSense, type checking

# Install package in development mode
cd python
pip install -e .

# Run doctests
./python/run-tests --python-executables=python3 --modules=pyspark-core
```

### R Development

```bash
# Install SparkR package
cd R
R CMD INSTALL --library=<path> pkg

# Run R checks
./R/install-dev.sh
```

## Environment Variables

Useful environment variables already set:

- `SPARK_HOME=/workspace`
- `JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64`
- `MAVEN_HOME=/usr/share/maven`

Add custom variables in [devcontainer.json](devcontainer.json) under `remoteEnv`.

## Debugging

### Debug Scala/Java

1. Set breakpoints in VS Code
2. Use "Run and Debug" panel
3. Or attach to running Spark process

### Debug Python

```python
# Add to code
import debugpy
debugpy.listen(5678)
debugpy.wait_for_client()

# In VS Code, attach debugger to port 5678
```

### Debug with logs

```bash
# Set log level in conf/log4j2.properties
# or programmatically:
./bin/spark-shell --conf spark.driver.extraJavaOptions="-Dlog4j.configuration=file:conf/log4j2.properties"
```

## Performance Tips

### Speed up builds

```bash
# Skip tests
-DskipTests

# Build in parallel
./build/mvn -T 1C clean package

# Use incremental build (sbt)
./build/sbt compile

# Reuse dependency cache (automatic via mounted volumes)
```

### Manage disk space

```bash
# Clean build artifacts
./build/mvn clean

# Clean target directories
find . -type d -name target -exec rm -rf {} +

# Clean Docker (from host)
docker system prune -a
```

## Common Issues

### "Out of memory" during build

Increase Docker memory:
- Docker Desktop → Settings → Resources → Memory
- Recommended: 8GB+

### "Permission denied"

```bash
# Run with sudo if needed
sudo chown -R spark-dev:spark-dev /workspace
```

### Maven dependencies not downloading

```bash
# Clear cache and retry
rm -rf ~/.m2/repository
./build/mvn clean package
```

### Python module not found

```bash
# Reinstall in development mode
cd python
pip install -e .
```

## Resources

- [Building Spark Guide](https://spark.apache.org/docs/latest/building-spark.html)
- [Developer Tools](https://spark.apache.org/developer-tools.html)
- [Contributing Guide](https://spark.apache.org/contributing.html)
- [Code Style Guide](https://spark.apache.org/contributing.html#code-style-guide)
- [Spark Community](https://spark.apache.org/community.html)

## Getting Help

- **Spark Dev Mailing List**: dev@spark.apache.org
- **Spark User Mailing List**: user@spark.apache.org
- **Stack Overflow**: Tag `apache-spark`
- **GitHub Issues**: https://github.com/apache/spark/issues

---

*This is a quick reference. See [README.md](README.md) for detailed documentation.*
