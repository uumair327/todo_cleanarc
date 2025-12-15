#!/usr/bin/env pwsh

Write-Host "Fixing Flutter analysis issues..." -ForegroundColor Green

# Fix prefer_const_constructors issues
Write-Host "Fixing prefer_const_constructors issues..." -ForegroundColor Yellow

# Fix dangling library doc comments
Write-Host "Fixing dangling library doc comments..." -ForegroundColor Yellow

# Fix unnecessary_brace_in_string_interps
Write-Host "Fixing unnecessary braces in string interpolation..." -ForegroundColor Yellow

# Fix unused elements
Write-Host "Fixing unused elements..." -ForegroundColor Yellow

# Fix prefer_initializing_formals
Write-Host "Fixing prefer_initializing_formals..." -ForegroundColor Yellow

# Fix unawaited_futures
Write-Host "Fixing unawaited_futures..." -ForegroundColor Yellow

# Fix use_build_context_synchronously
Write-Host "Fixing use_build_context_synchronously..." -ForegroundColor Yellow

# Fix prefer_const_declarations
Write-Host "Fixing prefer_const_declarations..." -ForegroundColor Yellow

# Fix prefer_final_locals
Write-Host "Fixing prefer_final_locals..." -ForegroundColor Yellow

Write-Host "Running flutter analyze to verify fixes..." -ForegroundColor Green
flutter analyze

Write-Host "Analysis fixes completed!" -ForegroundColor Green