#!/bin/bash
# Final deployment script for GitHub Pages
# Run this from your project root directory

echo "🚀 Deploying Flutter app to GitHub Pages..."

# Check if build exists
if [ ! -f "build/web/index.html" ]; then
    echo "❌ Build not found. Run 'flutter build web --release --base-href /todo_cleanarc/' first"
    exit 1
fi

# Create gh-pages branch and deploy
git checkout --orphan gh-pages 2>/dev/null || git checkout gh-pages

# Remove all existing files
git rm -rf . 2>/dev/null || true

# Copy build files
cp -r build/web/* .
cp build/web/.nojekyll . 2>/dev/null || true

# Add all files
git add .

# Commit
git commit -m "Deploy Flutter web app - $(date '+%Y-%m-%d %H:%M')"

# Push to GitHub
git push origin gh-pages --force

echo "✅ Deployment complete!"
echo "🌐 Your app will be available at: https://uumair327.github.io/todo_cleanarc/"
echo "⏰ Wait 5-10 minutes for GitHub Pages to update"

# Return to main branch
git checkout main