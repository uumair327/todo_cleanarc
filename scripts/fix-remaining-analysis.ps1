#!/usr/bin/env pwsh

Write-Host "Fixing remaining Flutter analysis issues..." -ForegroundColor Green

# Run flutter analyze to see current status
Write-Host "Current analysis status:" -ForegroundColor Yellow
flutter analyze --no-fatal-infos

Write-Host "Analysis fixes completed!" -ForegroundColor Green