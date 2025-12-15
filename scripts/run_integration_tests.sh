#!/bin/bash

# Script to run all integration tests
# Usage: ./scripts/run_integration_tests.sh [platform]

set -e

PLATFORM=${1:-""}

echo "=========================================="
echo "Running Flutter Todo App Integration Tests"
echo "=========================================="

# Get dependencies
echo "Installing dependencies..."
flutter pub get

# Run integration tests
if [ -z "$PLATFORM" ]; then
  echo "Running integration tests on default platform..."
  flutter test integration_test
else
  echo "Running integration tests on $PLATFORM..."
  flutter test integration_test --platform "$PLATFORM"
fi

echo "=========================================="
echo "Integration tests completed!"
echo "=========================================="
