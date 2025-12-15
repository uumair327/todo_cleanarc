# Final deployment script for GitHub Pages
# Run this from your project root directory

Write-Host "🚀 Deploying Flutter app to GitHub Pages..." -ForegroundColor Green

# Check if build exists
if (-not (Test-Path "build/web/index.html")) {
    Write-Host "❌ Build not found. Run 'flutter build web --release --base-href /todo_cleanarc/' first" -ForegroundColor Red
    exit 1
}

# Create gh-pages branch and deploy
git checkout --orphan gh-pages 2>$null
if ($LASTEXITCODE -ne 0) {
    git checkout gh-pages
}

# Remove all existing files
git rm -rf . 2>$null

# Copy build files
Copy-Item -Path "build/web/*" -Destination "." -Recurse -Force

# Add all files
git add .

# Commit
git commit -m "Deploy Flutter web app - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

# Push to GitHub
git push origin gh-pages --force

Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host "🌐 Your app will be available at: https://uumair327.github.io/todo_cleanarc/" -ForegroundColor Cyan
Write-Host "⏰ Wait 5-10 minutes for GitHub Pages to update" -ForegroundColor Yellow

# Return to main branch
git checkout main