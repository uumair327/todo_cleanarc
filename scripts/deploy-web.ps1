# Deploy Flutter Web App Script (PowerShell)
# This script builds and optionally deploys the Flutter web app

param(
    [Parameter(Position=0)]
    [ValidateSet("dev", "github", "prod")]
    [string]$Environment = "dev",
    
    [Parameter(Position=1)]
    [switch]$Serve
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Cyan"

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

Write-Status "🚀 Starting Flutter Web Deployment..."

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version 2>$null
    Write-Status "Flutter version:"
    Write-Host $flutterVersion
} catch {
    Write-Error "Flutter is not installed or not in PATH"
    exit 1
}

# Clean previous builds
Write-Status "Cleaning previous builds..."
flutter clean

# Get dependencies
Write-Status "Getting dependencies..."
flutter pub get

# Run code analysis
Write-Status "Running code analysis..."
try {
    flutter analyze
} catch {
    Write-Warning "Code analysis found issues, but continuing..."
}

# Run tests
Write-Status "Running tests..."
try {
    flutter test
} catch {
    Write-Warning "Some tests failed, but continuing..."
}

# Build for different environments
switch ($Environment) {
    "dev" {
        Write-Status "Building for development..."
        flutter build web --debug --base-href "/"
    }
    "github" {
        Write-Status "Building for GitHub Pages..."
        flutter build web --release --base-href "/todo_cleanarc/" --dart-define=GITHUB_PAGES=true
    }
    "prod" {
        Write-Status "Building for production..."
        flutter build web --release --base-href "/"
    }
}

Write-Success "Build completed successfully!"

# Show build info
$buildSize = (Get-ChildItem -Path "build/web" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Status "Build size: $([math]::Round($buildSize, 2)) MB"
Write-Status "Build location: build/web"

# Serve locally for testing
if ($Serve) {
    Write-Status "Starting local server..."
    Set-Location "build/web"
    Write-Success "Server running at: http://localhost:8000"
    
    # Try different methods to serve
    if (Get-Command python -ErrorAction SilentlyContinue) {
        python -m http.server 8000
    } elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
        python3 -m http.server 8000
    } elseif (Get-Command npx -ErrorAction SilentlyContinue) {
        npx serve -s . -l 8000
    } else {
        Write-Warning "No suitable server found. Please serve the build/web directory manually."
        Write-Status "You can use: python -m http.server 8000"
    }
}

Write-Success "Deployment script completed!"