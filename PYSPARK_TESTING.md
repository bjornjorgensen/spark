# PySpark Testing in Docker

This guide shows how to test PySpark in the Docker development environment.

## Quick Start

```bash
# Start container
./docker-dev.sh

# Build Spark first
./build/mvn -DskipTests clean package

# Run PySpark tests
cd python
python run-tests
```

## Running Different Types of Tests

### All PySpark Tests
```bash
cd python
python run-tests
```

### Specific Module
```bash
cd python
python run-tests --modules pyspark-sql
python run-tests --modules pyspark-ml
python run-tests --modules pyspark-core
```

### Specific Test File
```bash
cd python
python -m pytest pyspark/sql/tests/test_dataframe.py
python -m pytest pyspark/ml/tests/test_pipeline.py
```

### Specific Test Function
```bash
cd python
python -m pytest pyspark/sql/tests/test_dataframe.py::DataFrameTests::test_sample
python -m pytest -v -k "test_join"  # Run all tests with "join" in name
```

### With Coverage
```bash
cd python
python run-tests --coverage
# Coverage report will be in python/test_coverage/htmlcov/index.html
```

### Verbose Output
```bash
cd python
python -m pytest -v pyspark/sql/tests/test_dataframe.py
python -m pytest -vv  # Even more verbose
```

## Running PySpark Shell

```bash
# Start PySpark shell
./bin/pyspark

# Or with specific configuration
./bin/pyspark --master local[4] --driver-memory 4g
```

Inside PySpark:
```python
# Test basic functionality
df = spark.range(10)
df.show()

# Test imports
import numpy as np
import pandas as pd
import pyarrow as pa

# Create DataFrame from pandas
pdf = pd.DataFrame({'a': [1, 2, 3], 'b': [4, 5, 6]})
df = spark.createDataFrame(pdf)
df.show()
```

## Testing Your Changes

### 1. Make Code Changes
Edit files on your host machine (outside Docker).

### 2. Rebuild if Needed
If you changed Java/Scala code:
```bash
./build/mvn -DskipTests package
```

If you only changed Python code, no rebuild needed!

### 3. Run Tests
```bash
cd python
python -m pytest pyspark/sql/tests/test_dataframe.py -v
```

## Debugging Tests

### Run with Python debugger
```bash
cd python
python -m pytest --pdb pyspark/sql/tests/test_dataframe.py
```

### Print test output
```bash
cd python
python -m pytest -s pyspark/sql/tests/test_dataframe.py  # Show print statements
```

### Run single test to debug
```bash
cd python
python -m pytest pyspark/sql/tests/test_dataframe.py::DataFrameTests::test_sample -v
```

## Common Issues

### ImportError: No module named pyspark
Make sure you're in the container and PYTHONPATH is set:
```bash
export PYTHONPATH=/workspace/python:/workspace/python/lib/py4j-0.10.9.7-src.zip
```

### Tests fail with Java errors
Build Spark first:
```bash
./build/mvn -DskipTests clean package
```

### Missing Python dependencies
The Docker image includes all dependencies from `dev/requirements.txt`:
```bash
# Check what's installed
pip list | grep -E "numpy|pandas|pyarrow|pytest"
```

## Python Code Quality

### Linting
```bash
cd python
python -m flake8 pyspark
python -m ruff check pyspark
```

### Type Checking
```bash
cd python
python -m mypy pyspark
```

### Format Code
```bash
cd python
python -m black pyspark
```

## Performance Testing

### Time a test
```bash
cd python
time python -m pytest pyspark/sql/tests/test_dataframe.py
```

### Profile tests
```bash
cd python
python -m pytest --profile pyspark/sql/tests/test_dataframe.py
```

## Useful Environment Variables

```bash
# Run with more memory
export SPARK_DRIVER_MEMORY=4g
./bin/pyspark

# Enable verbose logging
export PYSPARK_PYTHON=python3
export SPARK_HOME=/workspace
export PYTHONPATH=/workspace/python:/workspace/python/lib/py4j-0.10.9.7-src.zip

# Set Python executable
export PYSPARK_PYTHON=python3
export PYSPARK_DRIVER_PYTHON=python3
```

## Quick Reference

```bash
# Test workflow
./docker-dev.sh                                    # Start container
./build/mvn -DskipTests clean package             # Build Spark (once)
cd python                                          # Go to Python directory
python run-tests --modules pyspark-sql            # Run tests
python -m pytest pyspark/sql/tests/test_*.py -v  # Run specific tests
exit                                               # Exit container

# Check environment
./test-docker-env.sh                              # Test all tools work
python -c "import pyspark; print('OK')"          # Test PySpark import
pip list                                          # Show installed packages
```

## More Examples

### Test DataFrame operations
```python
./bin/pyspark

# In PySpark shell:
df = spark.createDataFrame([(1, "a"), (2, "b")], ["id", "val"])
df.show()
df.filter(df.id > 1).show()
df.groupBy("val").count().show()
```

### Test with pandas
```python
./bin/pyspark

# In PySpark shell:
import pandas as pd
pdf = pd.DataFrame({'x': range(10), 'y': range(10, 20)})
sdf = spark.createDataFrame(pdf)
sdf.show()
result_pdf = sdf.toPandas()
print(result_pdf)
```

### Test MLlib
```python
./bin/pyspark

# In PySpark shell:
from pyspark.ml.linalg import Vectors
from pyspark.ml.classification import LogisticRegression

training = spark.createDataFrame([
    (1.0, Vectors.dense([0.0, 1.1, 0.1])),
    (0.0, Vectors.dense([2.0, 1.0, -1.0]))
], ["label", "features"])

lr = LogisticRegression(maxIter=10)
model = lr.fit(training)
print(f"Coefficients: {model.coefficients}")
```
