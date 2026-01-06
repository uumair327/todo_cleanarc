#!/bin/bash

# Color validation script wrapper
# This script provides a convenient way to run color validation
# with common configurations for different environments.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
INCLUDE_TESTS=false
JSON_OUTPUT=false
FAIL_ON_VIOLATIONS=true
OUTPUT_FILE=""
ROOT_PATH="."
VERBOSE=false

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to show help
show_help() {
    cat << EOF
Color Validation Script

Usage: $0 [options]

Options:
    -t, --include-tests     Include test files in validation
    -j, --json             Output results in JSON format
    -n, --no-fail          Don't fail on violations (warning mode)
    -o, --output FILE      Write results to file
    -r, --root PATH        Root path to scan (default: current directory)
    -v, --verbose          Verbose output
    -h, --help             Show this help message

Presets:
    --ci                   CI/CD mode (JSON output, fail on violations)
    --dev                  Development mode (text output, no fail)
    --pre-commit           Pre-commit mode (text output, fail on violations)

Examples:
    $0                                    # Basic validation
    $0 --ci --output violations.json     # CI/CD pipeline
    $0 --dev --include-tests             # Development with tests
    $0 --pre-commit                      # Pre-commit hook
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--include-tests)
            INCLUDE_TESTS=true
            shift
            ;;
        -j|--json)
            JSON_OUTPUT=true
            shift
            ;;
        -n|--no-fail)
            FAIL_ON_VIOLATIONS=false
            shift
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -r|--root)
            ROOT_PATH="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --ci)
            JSON_OUTPUT=true
            FAIL_ON_VIOLATIONS=true
            shift
            ;;
        --dev)
            JSON_OUTPUT=false
            FAIL_ON_VIOLATIONS=false
            INCLUDE_TESTS=true
            shift
            ;;
        --pre-commit)
            JSON_OUTPUT=false
            FAIL_ON_VIOLATIONS=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Build dart command arguments
DART_ARGS=()

if [ "$INCLUDE_TESTS" = true ]; then
    DART_ARGS+=(--include-tests)
fi

if [ "$JSON_OUTPUT" = true ]; then
    DART_ARGS+=(--json)
fi

if [ "$FAIL_ON_VIOLATIONS" = false ]; then
    DART_ARGS+=(--no-fail)
fi

if [ -n "$OUTPUT_FILE" ]; then
    DART_ARGS+=(--output "$OUTPUT_FILE")
fi

if [ "$ROOT_PATH" != "." ]; then
    DART_ARGS+=(--root "$ROOT_PATH")
fi

# Check if Dart is available
if ! command -v dart &> /dev/null; then
    print_status $RED "Error: Dart is not installed or not in PATH"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DART_SCRIPT="$SCRIPT_DIR/validate_colors.dart"

# Check if the Dart script exists
if [ ! -f "$DART_SCRIPT" ]; then
    print_status $RED "Error: Dart validation script not found at $DART_SCRIPT"
    exit 1
fi

# Print configuration if verbose
if [ "$VERBOSE" = true ]; then
    print_status $BLUE "Configuration:"
    echo "  Root path: $ROOT_PATH"
    echo "  Include tests: $INCLUDE_TESTS"
    echo "  JSON output: $JSON_OUTPUT"
    echo "  Fail on violations: $FAIL_ON_VIOLATIONS"
    echo "  Output file: ${OUTPUT_FILE:-stdout}"
    echo "  Dart args: ${DART_ARGS[*]}"
    echo
fi

# Run the validation
print_status $BLUE "Running color validation..."

if dart "$DART_SCRIPT" "${DART_ARGS[@]}"; then
    if [ "$JSON_OUTPUT" = false ]; then
        print_status $GREEN "Color validation completed successfully!"
    fi
    exit 0
else
    EXIT_CODE=$?
    if [ "$JSON_OUTPUT" = false ]; then
        if [ $EXIT_CODE -eq 1 ]; then
            print_status $RED "Color validation failed - hardcoded colors found!"
        else
            print_status $RED "Color validation error (exit code: $EXIT_CODE)"
        fi
    fi
    exit $EXIT_CODE
fi