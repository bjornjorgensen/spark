#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Post-create setup script for Apache Spark Dev Container
# This script runs after the container is created

set -e

echo "=========================================="
echo "Apache Spark Dev Container Setup"
echo "=========================================="

# Configure git safe directory
echo "Configuring git..."
git config --global --add safe.directory /workspace

# Set up better git defaults
git config --global pull.rebase false
git config --global init.defaultBranch main
git config --global core.autocrlf input
git config --global fetch.prune true

# Set up git user if not already configured
if [ -z "$(git config --global user.name)" ]; then
    echo "Git user.name not configured. You may want to set it:"
    echo "  git config --global user.name 'Your Name'"
fi

if [ -z "$(git config --global user.email)" ]; then
    echo "Git user.email not configured. You may want to set it:"
    echo "  git config --global user.email 'your.email@example.com'"
fi

# Create common directories if they don't exist
echo "Creating workspace directories..."
mkdir -p /workspace/work
mkdir -p /workspace/logs

# Install Python dependencies from requirements.txt if it exists
if [ -f "/workspace/dev/requirements.txt" ]; then
    echo "Installing Python dependencies..."
    python3 -m pip install --user -r /workspace/dev/requirements.txt || echo "Warning: Some Python dependencies failed to install"
fi

# Set up helpful aliases
echo "Setting up development aliases..."
cat >> ~/.zshrc << 'EOF'

# Spark Development Aliases
alias spark-build="./build/mvn -DskipTests clean package"
alias spark-build-fast="./build/mvn -T 1C -DskipTests clean package"
alias spark-test="./dev/run-tests"
alias spark-clean="./build/mvn clean"
alias spark-scala="./bin/spark-shell"
alias spark-python="./bin/pyspark"
alias spark-sql="./bin/spark-sql"
alias spark-example="./bin/run-example"

# Code quality aliases
alias lint-all="./dev/lint-scala && ./dev/lint-python && ./dev/lint-r && ./dev/lint-java"
alias lint-s="./dev/lint-scala"
alias lint-py="./dev/lint-python"
alias lint-r="./dev/lint-r"
alias lint-j="./dev/lint-java"

# Git aliases
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline --graph --decorate -20"
alias gp="git pull"

# Navigation aliases
alias core="cd /workspace/core"
alias sql="cd /workspace/sql"
alias mllib="cd /workspace/mllib"
alias streaming="cd /workspace/streaming"
alias python="cd /workspace/python"

# Utility functions
spark-module-test() {
    if [ -z "$1" ]; then
        echo "Usage: spark-module-test <module-name>"
        echo "Example: spark-module-test core"
        return 1
    fi
    ./build/mvn test -pl "$1"
}

spark-class-test() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: spark-class-test <module> <test-class>"
        echo "Example: spark-class-test core org.apache.spark.SparkContextSuite"
        return 1
    fi
    ./build/mvn test -pl "$1" -Dtest="$2"
}

EOF

# Also add to bashrc for bash users
if [ -f ~/.bashrc ]; then
    grep -q "Spark Development Aliases" ~/.bashrc || cat >> ~/.bashrc << 'EOF'

# Spark Development Aliases
alias spark-build="./build/mvn -DskipTests clean package"
alias spark-build-fast="./build/mvn -T 1C -DskipTests clean package"
alias spark-test="./dev/run-tests"
alias spark-clean="./build/mvn clean"
alias spark-scala="./bin/spark-shell"
alias spark-python="./bin/pyspark"
alias spark-sql="./bin/spark-sql"
alias spark-example="./bin/run-example"

EOF
fi

# Set up shell completion for spark commands (optional)
if [ -f "/workspace/bin/spark-shell" ]; then
    echo "Spark binaries found in /workspace/bin"
fi

# Display useful information
echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Apache Spark Development Container is ready!"
echo ""
echo "Quick Start:"
echo "  1. Build Spark:          ./build/mvn -DskipTests clean package"
echo "  2. Run Spark Shell:      ./bin/spark-shell"
echo "  3. Run PySpark:          ./bin/pyspark"
echo "  4. Run tests:            ./dev/run-tests"
echo ""
echo "Useful ports (forwarded to host):"
echo "  - 4040:  Spark UI"
echo "  - 8080:  Spark Master UI"
echo "  - 8081:  Spark Worker UI"
echo "  - 18080: Spark History Server"
echo ""
echo "Environment:"
echo "  SPARK_HOME:  /workspace"
echo "  JAVA_HOME:   $JAVA_HOME"
echo "  MAVEN_HOME:  $MAVEN_HOME"
echo ""
echo "For more information, see:"
echo "  - README.md"
echo "  - https://spark.apache.org/docs/latest/building-spark.html"
echo "  - https://spark.apache.org/developer-tools.html"
echo ""
echo "=========================================="
