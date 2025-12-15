# Code Analysis Script
# This script runs Flutter analyze and provides a summary

Write-Host "🔍 Running Flutter Code Analysis..." -ForegroundColor Cyan

# Run flutter analyze and capture output
Write-Host "Analyzing code..." -ForegroundColor Yellow
try {
    $output = flutter analyze 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "✅ No issues found!" -ForegroundColor Green
        Write-Host $output -ForegroundColor White
    } else {
        Write-Host "⚠️ Issues found:" -ForegroundColor Yellow
        
        # Parse and categorize issues
        $lines = $output -split "`n"
        $errors = @()
        $warnings = @()
        $infos = @()
        
        foreach ($line in $lines) {
            if ($line -match "^error •") {
                $errors += $line
            } elseif ($line -match "^warning •") {
                $warnings += $line
            } elseif ($line -match "^info •") {
                $infos += $line
            }
        }
        
        # Display summary
        Write-Host "`n📊 Issue Summary:" -ForegroundColor Cyan
        Write-Host "  Errors: $($errors.Count)" -ForegroundColor Red
        Write-Host "  Warnings: $($warnings.Count)" -ForegroundColor Yellow
        Write-Host "  Info: $($infos.Count)" -ForegroundColor Blue
        
        # Show errors first (most critical)
        if ($errors.Count -gt 0) {
            Write-Host "`n❌ ERRORS (must fix):" -ForegroundColor Red
            foreach ($error in $errors) {
                Write-Host "  $error" -ForegroundColor Red
            }
        }
        
        # Show warnings (should fix)
        if ($warnings.Count -gt 0 -and $warnings.Count -le 10) {
            Write-Host "`n⚠️ WARNINGS:" -ForegroundColor Yellow
            foreach ($warning in $warnings) {
                Write-Host "  $warning" -ForegroundColor Yellow
            }
        } elseif ($warnings.Count -gt 10) {
            Write-Host "`n⚠️ WARNINGS ($($warnings.Count) total, showing first 10):" -ForegroundColor Yellow
            for ($i = 0; $i -lt 10; $i++) {
                Write-Host "  $($warnings[$i])" -ForegroundColor Yellow
            }
            Write-Host "  ... and $($warnings.Count - 10) more warnings" -ForegroundColor Yellow
        }
        
        # Show info summary (nice to fix)
        if ($infos.Count -gt 0) {
            Write-Host "`nℹ️ INFO: $($infos.Count) style/optimization suggestions" -ForegroundColor Blue
        }
        
        Write-Host "`n🎯 Priority:" -ForegroundColor Cyan
        Write-Host "  1. Fix all ERRORS first" -ForegroundColor Red
        Write-Host "  2. Address WARNINGS for production" -ForegroundColor Yellow
        Write-Host "  3. Consider INFO suggestions for code quality" -ForegroundColor Blue
    }
} catch {
    Write-Host "❌ Failed to run flutter analyze" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n🚀 Next steps:" -ForegroundColor Green
Write-Host "  flutter test    # Run tests" -ForegroundColor White
Write-Host "  flutter run     # Test the app" -ForegroundColor White
Write-Host "  flutter build web --release  # Build for production" -ForegroundColor White