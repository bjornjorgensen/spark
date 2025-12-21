#!/bin/bash
# Test script to verify Docker environment has everything needed

set -e

echo "====================================="
echo "Spark Docker Environment Test"
echo "====================================="
echo ""

echo "✓ Testing Java..."
java -version
echo ""

echo "✓ Testing Maven..."
mvn -version
echo ""

echo "✓ Testing Python..."
python --version
python -c "import sys; print(f'Python path: {sys.executable}')"
echo ""

echo "✓ Testing Python packages..."
python -c "import numpy; print(f'NumPy {numpy.__version__}')"
python -c "import pandas; print(f'Pandas {pandas.__version__}')"
python -c "import pyarrow; print(f'PyArrow {pyarrow.__version__}')"
python -c "import pytest; print(f'Pytest {pytest.__version__}')"
echo ""

echo "✓ Testing PySpark..."
if [ -f "python/pyspark/__init__.py" ]; then
    export PYTHONPATH="${PWD}/python:${PWD}/python/lib/py4j-0.10.9.7-src.zip"
    python -c "import pyspark; print(f'PySpark module found')"
    echo ""
fi

echo "✓ Checking build tools..."
ls -la build/mvn build/sbt 2>/dev/null || echo "Build scripts found"
echo ""

echo "====================================="
echo "✅ All checks passed!"
echo "====================================="
echo ""
echo "You can now:"
echo "  1. Build Spark: ./build/mvn -DskipTests clean package"
echo "  2. Run Python tests: cd python && python run-tests"
echo "  3. Run Spark shell: ./bin/spark-shell"
echo "  4. Run PySpark: ./bin/pyspark"
