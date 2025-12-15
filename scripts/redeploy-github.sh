#!/bin/bash

# Quick redeploy script for GitHub Pages
echo "🚀 Rebuilding and redeploying for GitHub Pages..."

# Clean and rebuild
flutter clean
flutter pub get

# Build with correct base href for GitHub Pages
echo "Building with base href /todo_cleanarc/..."
flutter build web --release --base-href "/todo_cleanarc/"

echo "✅ Build complete! The build/web folder is ready for deployment."
echo "📁 Build location: build/web"
echo "🌐 Will be available at: https://uumair327.github.io/todo_cleanarc/"

# Show build size
BUILD_SIZE=$(du -sh build/web | cut -f1)
echo "📦 Build size: $BUILD_SIZE"

echo ""
echo "Next steps:"
echo "1. Copy the contents of build/web to your gh-pages branch"
echo "2. Or use GitHub Actions to automatically deploy"
echo "3. Make sure GitHub Pages is configured to serve from gh-pages branch"