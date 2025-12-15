#!/bin/bash

# Script to run performance benchmarking tests with profiling
# Usage: ./scripts/run_performance_tests.sh

set -e

echo "=========================================="
echo "Running Performance Benchmarking Tests"
echo "=========================================="

# Get dependencies
echo "Installing dependencies..."
flutter pub get

# Run performance tests with driver for profiling
echo "Running performance tests with profiling..."
flutter drive \
  --driver=integration_test_driver/integration_test.dart \
  --target=integration_test/performance_test.dart \
  --profile

echo "=========================================="
echo "Performance tests completed!"
echo "Check output for benchmark results"
echo "=========================================="
