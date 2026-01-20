#!/bin/bash

# Setup script for Git hooks
# This script installs the pre-commit hook for color validation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

print_status $BLUE "Setting up Git hooks for color validation..."

# Check if we're in a Git repository
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    print_status $RED "Error: Not in a Git repository"
    exit 1
fi

# Create hooks directory if it doesn't exist
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"
mkdir -p "$HOOKS_DIR"

# Copy pre-commit hook
PRE_COMMIT_SOURCE="$SCRIPT_DIR/pre-commit-hook"
PRE_COMMIT_TARGET="$HOOKS_DIR/pre-commit"

if [ -f "$PRE_COMMIT_TARGET" ]; then
    print_status $YELLOW "Warning: pre-commit hook already exists"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status $YELLOW "Skipping pre-commit hook installation"
        exit 0
    fi
fi

cp "$PRE_COMMIT_SOURCE" "$PRE_COMMIT_TARGET"
chmod +x "$PRE_COMMIT_TARGET"

print_status $GREEN "✅ Pre-commit hook installed successfully"

# Make validation scripts executable
chmod +x "$SCRIPT_DIR/validate_colors.sh"
chmod +x "$SCRIPT_DIR/validate_colors.dart"

print_status $GREEN "✅ Validation scripts made executable"

# Test the hook
print_status $BLUE "Testing the pre-commit hook..."
if "$PRE_COMMIT_TARGET"; then
    print_status $GREEN "✅ Pre-commit hook test passed"
else
    print_status $YELLOW "⚠️  Pre-commit hook test failed (this may be expected if there are violations)"
fi

print_status $BLUE "Setup complete!"
print_status $YELLOW "The pre-commit hook will now run color validation before each commit."
print_status $YELLOW "To bypass the hook temporarily, use: git commit --no-verify"