# Apache Spark Dev Container Troubleshooting Guide

## Table of Contents

1. [Container Issues](#container-issues)
2. [Build Issues](#build-issues)
3. [IDE Issues](#ide-issues)
4. [Runtime Issues](#runtime-issues)
5. [Python Issues](#python-issues)
6. [Git Issues](#git-issues)
7. [Network Issues](#network-issues)

## Container Issues

### Container fails to build

**Symptoms**: Error during container creation

**Solutions**:

1. Check Docker is running:
   ```bash
   docker ps
   ```

2. Check Docker resources (Settings → Resources):
   - Memory: 8GB minimum
   - Disk space: 50GB+ available

3. View build logs:
   ```bash
   F1 → "Dev Containers: Show Log"
   ```

4. Try rebuilding without cache:
   ```bash
   F1 → "Dev Containers: Rebuild Without Cache"
   ```

5. Check for network issues preventing package downloads

### Container starts but is very slow

**Solutions**:

1. Increase Docker memory allocation (8GB+)
2. Check if host system has sufficient resources
3. Disable unnecessary VS Code extensions
4. Check `.devcontainer/PERFORMANCE.md` for optimization tips

### Cannot connect to container

**Solutions**:

1. Restart Docker Desktop
2. Remove and rebuild container:
   ```bash
   docker rm <container-id>
   F1 → "Dev Containers: Rebuild Container"
   ```

3. Check Docker logs for errors

## Build Issues

### Maven "Out of Memory" errors

**Symptoms**: Build fails with `OutOfMemoryError`

**Solutions**:

1. Increase Maven memory:
   ```bash
   export MAVEN_OPTS="-Xmx4g -XX:ReservedCodeCacheSize=1g"
   ```

2. Add to `~/.mavenrc`:
   ```bash
   echo 'export MAVEN_OPTS="-Xmx4g -XX:ReservedCodeCacheSize=1g"' >> ~/.mavenrc
   ```

3. Increase Docker container memory to 8GB+

### Dependencies fail to download

**Symptoms**: Maven cannot download artifacts

**Solutions**:

1. Check internet connection
2. Clear Maven cache and retry:
   ```bash
   rm -rf ~/.m2/repository
   ./build/mvn clean package
   ```

3. Try a different Maven mirror in `~/.m2/settings.xml`

4. Check if behind corporate proxy/firewall

### Build is extremely slow

**Solutions**:

1. Use fast build:
   ```bash
   spark-build-fast  # Parallel build
   ```

2. Skip tests during development:
   ```bash
   spark-build  # Already includes -DskipTests
   ```

3. Build specific module:
   ```bash
   ./build/mvn -pl core -am -DskipTests package
   ```

4. Use incremental compilation:
   ```bash
   ./build/sbt
   ~compile  # Watch mode
   ```

### Compilation errors after git pull

**Solutions**:

1. Clean and rebuild:
   ```bash
   spark-clean
   spark-build
   ```

2. Update Maven wrapper:
   ```bash
   ./build/mvn --version
   ```

3. Check Java version:
   ```bash
   java -version  # Should be Java 17
   ```

## IDE Issues

### Metals (Scala) not working

**Symptoms**: No code completion, errors not showing

**Solutions**:

1. Import build:
   ```bash
   F1 → "Metals: Import build"
   ```

2. Clean Metals cache:
   ```bash
   rm -rf .metals .bloop
   F1 → "Metals: Import build"
   ```

3. Check Metals status:
   ```bash
   F1 → "Metals: Doctor"
   ```

4. Restart Metals:
   ```bash
   F1 → "Metals: Restart server"
   ```

### Java Language Server issues

**Symptoms**: Java code completion not working

**Solutions**:

1. Clean Java workspace:
   ```bash
   F1 → "Java: Clean Java Language Server Workspace"
   ```

2. Reload window:
   ```bash
   F1 → "Developer: Reload Window"
   ```

3. Check JAVA_HOME:
   ```bash
   echo $JAVA_HOME  # Should be /usr/lib/jvm/java-17-openjdk-amd64
   ```

### Python IntelliSense not working

**Symptoms**: No Python code completion

**Solutions**:

1. Select Python interpreter:
   ```bash
   F1 → "Python: Select Interpreter"
   # Choose /usr/bin/python3
   ```

2. Install PySpark in development mode:
   ```bash
   cd python
   pip install -e .
   ```

3. Restart Pylance:
   ```bash
   F1 → "Pylance: Restart Server"
   ```

### Extensions not loading

**Solutions**:

1. Check extension is installed:
   ```bash
   F1 → "Extensions: Show Installed Extensions"
   ```

2. Reload window:
   ```bash
   F1 → "Developer: Reload Window"
   ```

3. Reinstall extension:
   - Uninstall extension
   - Reload window
   - Install extension again

## Runtime Issues

### Spark shell fails to start

**Symptoms**: `./bin/spark-shell` errors

**Solutions**:

1. Build Spark first:
   ```bash
   spark-build
   ```

2. Check SPARK_HOME:
   ```bash
   echo $SPARK_HOME  # Should be /workspace
   ```

3. Check Java:
   ```bash
   java -version
   ```

4. Try with explicit master:
   ```bash
   ./bin/spark-shell --master local[2]
   ```

### PySpark import errors

**Symptoms**: `ImportError: No module named pyspark`

**Solutions**:

1. Install PySpark in development mode:
   ```bash
   cd /workspace/python
   pip install -e .
   ```

2. Check PYTHONPATH:
   ```bash
   echo $PYTHONPATH
   # Should include /workspace/python
   ```

3. Set environment variables:
   ```bash
   export SPARK_HOME=/workspace
   export PYTHONPATH="$SPARK_HOME/python:$PYTHONPATH"
   ```

### Tests fail with ClassNotFoundException

**Solutions**:

1. Rebuild the module:
   ```bash
   ./build/mvn -pl <module> clean package
   ```

2. Check classpath:
   ```bash
   ./build/mvn dependency:tree -pl <module>
   ```

3. Clean and rebuild:
   ```bash
   spark-clean
   spark-build
   ```

## Python Issues

### pip install fails

**Solutions**:

1. Upgrade pip:
   ```bash
   python3 -m pip install --upgrade pip
   ```

2. Use --user flag:
   ```bash
   pip install --user <package>
   ```

3. Check Python version:
   ```bash
   python3 --version  # Should be 3.10+
   ```

### Python tests fail

**Solutions**:

1. Install test dependencies:
   ```bash
   pip install -r dev/requirements.txt
   ```

2. Run specific test:
   ```bash
   cd python
   python -m pytest pyspark/sql/tests/test_dataframe.py -v
   ```

3. Clean Python cache:
   ```bash
   find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null
   ```

## Git Issues

### "dubious ownership" error

**Symptoms**: Git commands fail with ownership warnings

**Solutions**:

Already configured in post-create.sh, but if needed:
```bash
git config --global --add safe.directory /workspace
```

### Git is slow

**Solutions**:

1. Disable Oh My Zsh git status:
   ```bash
   git config oh-my-zsh.hide-status 1
   ```

2. Use shallow clone:
   ```bash
   git fetch --depth 1
   ```

### Cannot push to repository

**Solutions**:

1. Configure Git credentials:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

2. Set up SSH keys or use HTTPS with token

## Network Issues

### Cannot download dependencies

**Solutions**:

1. Check internet connection:
   ```bash
   ping google.com
   ```

2. Check DNS:
   ```bash
   cat /etc/resolv.conf
   ```

3. Configure proxy if needed in `~/.m2/settings.xml`:
   ```xml
   <proxies>
     <proxy>
       <host>proxy.example.com</host>
       <port>8080</port>
     </proxy>
   </proxies>
   ```

### Ports already in use

**Symptoms**: "Address already in use" errors

**Solutions**:

1. Check what's using the port:
   ```bash
   lsof -i :4040
   ```

2. Kill the process:
   ```bash
   kill -9 <PID>
   ```

3. Use different port:
   ```bash
   ./bin/spark-shell --conf spark.ui.port=4041
   ```

## Disk Space Issues

### Container out of disk space

**Solutions**:

1. Clean build artifacts:
   ```bash
   spark-clean
   find . -name target -type d -exec rm -rf {} + 2>/dev/null
   ```

2. Clean Docker (from host):
   ```bash
   docker system prune -a
   ```

3. Clean Maven cache:
   ```bash
   rm -rf ~/.m2/repository
   ```

4. Check disk usage:
   ```bash
   df -h
   du -sh target/
   ```

## Permission Issues

### Permission denied errors

**Solutions**:

1. Check file ownership:
   ```bash
   ls -la
   ```

2. Fix ownership:
   ```bash
   sudo chown -R spark-dev:spark-dev /workspace
   ```

3. Check if file is executable:
   ```bash
   chmod +x script.sh
   ```

## Getting Help

If issues persist:

1. **Check logs**:
   ```bash
   F1 → "Dev Containers: Show Log"
   ```

2. **Search Spark documentation**:
   - [Building Spark](https://spark.apache.org/docs/latest/building-spark.html)
   - [Developer Tools](https://spark.apache.org/developer-tools.html)

3. **Ask the community**:
   - [Spark Mailing Lists](https://spark.apache.org/community.html)
   - [Stack Overflow](https://stackoverflow.com/questions/tagged/apache-spark)

4. **File an issue**:
   - [Apache Spark JIRA](https://issues.apache.org/jira/projects/SPARK)
   - [GitHub Issues](https://github.com/apache/spark/issues)

## Debug Commands

Useful commands for debugging:

```bash
# System information
uname -a
cat /etc/os-release

# Resource usage
htop
df -h
free -h

# Java information
java -version
echo $JAVA_HOME
jps -lvm

# Python information
python3 --version
pip list
which python3

# Maven information
mvn --version
echo $MAVEN_OPTS

# Git information
git --version
git status

# Docker information (from host)
docker ps
docker stats
docker logs <container-id>

# Network information
ip addr
netstat -tulpn
```
