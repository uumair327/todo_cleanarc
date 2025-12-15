#!/bin/bash

# Deploy Flutter Web App Script
# This script builds and optionally deploys the Flutter web app

set -e

echo "🚀 Starting Flutter Web Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_status "Flutter version:"
flutter --version

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Run code analysis
print_status "Running code analysis..."
if ! flutter analyze; then
    print_warning "Code analysis found issues, but continuing..."
fi

# Run tests
print_status "Running tests..."
if ! flutter test; then
    print_warning "Some tests failed, but continuing..."
fi

# Build for different environments
case "${1:-dev}" in
    "dev")
        print_status "Building for development..."
        flutter build web --debug --web-renderer html --base-href "/"
        ;;
    "github")
        print_status "Building for GitHub Pages..."
        flutter build web --release --web-renderer html --base-href "/glimfo-todo/" --dart-define=GITHUB_PAGES=true
        ;;
    "prod")
        print_status "Building for production..."
        flutter build web --release --web-renderer html --base-href "/"
        ;;
    *)
        print_error "Invalid environment. Use: dev, github, or prod"
        exit 1
        ;;
esac

print_success "Build completed successfully!"

# Show build info
BUILD_SIZE=$(du -sh build/web | cut -f1)
print_status "Build size: $BUILD_SIZE"
print_status "Build location: build/web"

# Serve locally for testing
if [[ "${2}" == "--serve" ]]; then
    print_status "Starting local server..."
    if command -v python3 &> /dev/null; then
        cd build/web
        print_success "Server running at: http://localhost:8000"
        python3 -m http.server 8000
    elif command -v python &> /dev/null; then
        cd build/web
        print_success "Server running at: http://localhost:8000"
        python -m SimpleHTTPServer 8000
    else
        print_warning "Python not found. Please serve the build/web directory manually."
    fi
fi

print_success "Deployment script completed!"