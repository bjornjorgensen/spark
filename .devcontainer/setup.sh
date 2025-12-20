#!/bin/bash
# Setup script for Apache Spark Dev Container
# This script creates necessary directories for bind mounts before starting the container

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Setting up Apache Spark Dev Container..."

# Create cache directories for Maven, SBT, and Ivy2
echo "Creating build tool cache directories..."
mkdir -p "$WORKSPACE_ROOT/.m2"
mkdir -p "$WORKSPACE_ROOT/.sbt"
mkdir -p "$WORKSPACE_ROOT/.ivy2"

echo "✓ Cache directories created:"
echo "  - .m2  (Maven)"
echo "  - .sbt (SBT)"
echo "  - .ivy2 (Ivy)"
echo ""
echo "Setup complete! You can now open this workspace in the dev container."
