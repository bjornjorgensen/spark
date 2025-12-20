# Apache Spark Dev Container - Performance Optimization Guide

## Container Performance Tips

### 1. Docker Resource Allocation

Ensure Docker has sufficient resources:

**Docker Desktop Settings → Resources:**
- **Memory**: 8GB minimum, 16GB recommended for full builds
- **CPUs**: 4+ cores recommended
- **Disk**: 50GB+ available space
- **Swap**: 2GB minimum

### 2. Build Performance Optimization

#### Fast Development Builds

```bash
# Skip tests (fastest)
spark-build

# Parallel build with all CPU cores
spark-build-fast

# Build specific module only
./build/mvn -pl core -am -DskipTests package

# Incremental build (after initial build)
./build/mvn compile -DskipTests
```

#### Maven Performance Settings

Create `~/.mavenrc` with:
```bash
export MAVEN_OPTS="-Xmx4g -XX:ReservedCodeCacheSize=1g -XX:+UseG1GC"
```

### 3. IDE Performance

#### VS Code Settings

Exclude directories from file watching (already configured):
- `**/target/**`
- `**/.metals/**`
- `**/.m2/**`
- `**/work/**`

#### Metals (Scala) Performance

If Metals is slow:
```bash
# Clean Metals cache
rm -rf .metals .bloop

# Reimport build
F1 → "Metals: Import build"
```

### 4. Disk Space Management

```bash
# Clean build artifacts
spark-clean

# Clean all target directories
find . -name target -type d -exec rm -rf {} + 2>/dev/null

# Clean Docker (from host)
docker system prune -a

# Clean Maven cache (last resort)
rm -rf ~/.m2/repository
```

### 5. Network Performance

#### Maven Mirror (Optional)

For faster dependency downloads, configure a Maven mirror in `~/.m2/settings.xml`:

```xml
<settings>
  <mirrors>
    <mirror>
      <id>central-mirror</id>
      <url>https://repo1.maven.org/maven2</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```

### 6. Container Startup Performance

Volume mounts are configured to persist:
- Maven cache (`~/.m2`)
- sbt cache (`~/.sbt`)
- Ivy cache (`~/.ivy2`)

This means subsequent builds are much faster as dependencies don't need to be re-downloaded.

### 7. Python Performance

```bash
# Use PyPy for faster Python execution
pypy3 your_script.py

# Profile Python code
python3 -m cProfile -o profile.stats your_script.py
python3 -m pstats profile.stats
```

### 8. Memory Optimization

#### Spark Application Memory

Set memory limits for Spark applications:

```bash
# In spark-shell or pyspark
--driver-memory 4g --executor-memory 4g

# For local mode
--master local[4] --driver-memory 4g
```

#### JVM Memory

For development builds:
```bash
export MAVEN_OPTS="-Xmx4g -XX:+UseG1GC"
export _JAVA_OPTIONS="-Xmx2g"
```

### 9. Parallel Testing

```bash
# Run tests in parallel
./build/mvn test -Dtest.parallel=1

# Run specific test suite
./build/mvn test -pl core -Dtest=SparkContextSuite
```

### 10. Development Workflow Tips

#### Fastest Edit-Compile-Test Cycle

1. **Make small, focused changes**
2. **Compile only changed module**:
   ```bash
   ./build/mvn compile -pl core
   ```
3. **Run specific test**:
   ```bash
   ./build/mvn test -pl core -Dtest=YourTestClass
   ```
4. **Use IDE test runners** for faster feedback

#### Hot Reload (Scala)

For Scala development, use sbt for faster incremental compilation:

```bash
./build/sbt
~compile  # Watch mode - recompiles on file save
```

### 11. Profiling and Debugging

#### CPU Profiling

```bash
# Java Flight Recorder
java -XX:+FlightRecorder -XX:StartFlightRecording=duration=60s,filename=recording.jfr

# Async Profiler
./profiler.sh -d 30 -f flamegraph.html <pid>
```

#### Memory Profiling

```bash
# Heap dump
jmap -dump:format=b,file=heap.bin <pid>

# Analyze with Eclipse MAT or VisualVM
```

### 12. Container Optimization

#### Rebuild Container with Cache

```bash
# From host machine
F1 → "Dev Containers: Rebuild Container"
```

#### Rebuild Without Cache (slower, but clean)

```bash
F1 → "Dev Containers: Rebuild Without Cache"
```

### 13. Git Performance

```bash
# Shallow clone (faster)
git clone --depth 1 https://github.com/apache/spark.git

# Disable git status in large repos
git config oh-my-zsh.hide-status 1
```

### 14. Benchmarking

```bash
# Benchmark Spark operations
./bin/spark-submit --class org.apache.spark.examples.SparkPi \
  --master local[*] \
  examples/target/spark-examples_*.jar 1000

# Time builds
time ./build/mvn -DskipTests clean package
```

## Common Performance Issues

### Issue: Container is slow to start
**Solution**: 
- Check Docker resource allocation
- Ensure no other heavy processes running
- Use volume mounts (already configured)

### Issue: Builds are very slow
**Solution**:
- Use `spark-build-fast` for parallel builds
- Increase Maven memory: `export MAVEN_OPTS="-Xmx4g"`
- Build only changed modules
- Skip tests during development

### Issue: IDE is sluggish
**Solution**:
- Exclude large directories from indexing
- Increase VS Code memory limit
- Disable unnecessary extensions
- Close unused editors

### Issue: Out of disk space
**Solution**:
- Run `docker system prune -a`
- Clean build artifacts: `spark-clean`
- Remove unused Docker images/containers

## Monitoring

### Check Resource Usage

```bash
# Container resources
docker stats

# System resources inside container
htop

# Disk usage
df -h
du -sh target/

# Java heap usage
jps -lvm
jstat -gc <pid>
```

## Additional Resources

- [Maven Performance Tips](https://maven.apache.org/configure.html)
- [Docker Performance Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Spark Building Guide](https://spark.apache.org/docs/latest/building-spark.html)
