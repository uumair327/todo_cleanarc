# Quick redeploy script for GitHub Pages (PowerShell)
Write-Host "🚀 Rebuilding and redeploying for GitHub Pages..." -ForegroundColor Cyan

# Clean and rebuild
flutter clean
flutter pub get

# Build with correct base href for GitHub Pages
Write-Host "Building with base href /todo_cleanarc/..." -ForegroundColor Yellow
flutter build web --release --base-href "/todo_cleanarc/"

Write-Host "✅ Build complete! The build/web folder is ready for deployment." -ForegroundColor Green
Write-Host "📁 Build location: build/web" -ForegroundColor Blue
Write-Host "🌐 Will be available at: https://uumair327.github.io/todo_cleanarc/" -ForegroundColor Blue

# Show build size
$buildSize = (Get-ChildItem -Path "build/web" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "📦 Build size: $([math]::Round($buildSize, 2)) MB" -ForegroundColor Blue

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Copy the contents of build/web to your gh-pages branch"
Write-Host "2. Or use GitHub Actions to automatically deploy"
Write-Host "3. Make sure GitHub Pages is configured to serve from gh-pages branch"