# Fix Dependencies Script
# This script resolves Flutter dependency conflicts

Write-Host "🔧 Fixing Flutter Dependencies..." -ForegroundColor Cyan

# Clean the project
Write-Host "Cleaning Flutter project..." -ForegroundColor Yellow
try {
    flutter clean
    Write-Host "✅ Project cleaned successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Flutter clean failed, continuing..." -ForegroundColor Yellow
}

# Remove pubspec.lock if it exists
if (Test-Path "pubspec.lock") {
    Remove-Item "pubspec.lock" -Force
    Write-Host "✅ Removed pubspec.lock" -ForegroundColor Green
}

# Get dependencies
Write-Host "Getting Flutter dependencies..." -ForegroundColor Yellow
try {
    flutter pub get
    Write-Host "✅ Dependencies resolved successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to resolve dependencies" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    
    Write-Host "`n🔍 Troubleshooting suggestions:" -ForegroundColor Cyan
    Write-Host "1. Check Flutter version: flutter --version" -ForegroundColor White
    Write-Host "2. Update Flutter: flutter upgrade" -ForegroundColor White
    Write-Host "3. Check Dart SDK version compatibility" -ForegroundColor White
    Write-Host "4. Try: flutter pub deps" -ForegroundColor White
    
    exit 1
}

# Verify the fix
Write-Host "`n🧪 Verifying dependencies..." -ForegroundColor Yellow
try {
    flutter pub deps
    Write-Host "✅ All dependencies verified!" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Dependency verification had issues, but pub get succeeded" -ForegroundColor Yellow
}

Write-Host "`n🎉 Dependency resolution complete!" -ForegroundColor Green
Write-Host "You can now run:" -ForegroundColor White
Write-Host "  flutter run" -ForegroundColor Cyan
Write-Host "  flutter test" -ForegroundColor Cyan
Write-Host "  flutter build web" -ForegroundColor Cyan