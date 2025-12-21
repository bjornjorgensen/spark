#!/bin/bash
# Simple Docker development environment for Apache Spark
# Uses the official Spark infra image with all dependencies

set -e

# Choose which image to use
IMAGE_NAME=${SPARK_DEV_IMAGE:-"dev/infra"}
IMAGE_TAG="spark-dev-infra"

# Build the official Spark infra image if it doesn't exist
if ! docker image inspect $IMAGE_TAG >/dev/null 2>&1; then
  echo "Building official Spark development image..."
  echo "This includes: Java 17, Python 3.9/3.10/3.11/3.12/3.13, PyPy, R, and all dependencies"
  echo ""
  docker build -f dev/infra/Dockerfile -t $IMAGE_TAG .
  echo ""
  echo "✅ Image built successfully!"
fi

echo "Starting Spark development container..."
echo ""
docker run -it --rm \
  --name spark-dev \
  -v "$(pwd)":/workspace \
  -v "$HOME/.m2":/root/.m2 \
  -v "$HOME/.ivy2":/root/.ivy2 \
  -v "$HOME/.sbt":/root/.sbt \
  -w /workspace \
  $IMAGE_TAG \
  bash
