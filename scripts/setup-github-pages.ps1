# GitHub Pages Setup Script (PowerShell)
# This script helps configure your repository for GitHub Pages deployment

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

Write-Host "🚀 GitHub Pages Setup for Flutter Todo App" -ForegroundColor $Blue
Write-Host "==========================================" -ForegroundColor $Blue

# Get GitHub username and repository name
$GITHUB_USERNAME = Read-Host "Enter your GitHub username"
$REPO_NAME = Read-Host "Enter your repository name (default: glimfo-todo)"
if ([string]::IsNullOrEmpty($REPO_NAME)) {
    $REPO_NAME = "glimfo-todo"
}

Write-Status "Configuring for:"
Write-Host "  GitHub Username: $GITHUB_USERNAME"
Write-Host "  Repository Name: $REPO_NAME"
Write-Host "  GitHub Pages URL: https://$GITHUB_USERNAME.github.io/$REPO_NAME/"

# Update auth constants
Write-Status "Updating auth constants..."
$AUTH_CONSTANTS_FILE = "lib/core/constants/auth_constants.dart"

if (Test-Path $AUTH_CONSTANTS_FILE) {
    # Create backup
    Copy-Item $AUTH_CONSTANTS_FILE "$AUTH_CONSTANTS_FILE.backup"
    
    # Read and update content
    $content = Get-Content $AUTH_CONSTANTS_FILE -Raw
    $content = $content -replace "YOUR_GITHUB_USERNAME", $GITHUB_USERNAME
    $content = $content -replace "glimfo-todo", $REPO_NAME
    Set-Content $AUTH_CONSTANTS_FILE $content
    
    Write-Success "Updated $AUTH_CONSTANTS_FILE"
} else {
    Write-Error "Auth constants file not found: $AUTH_CONSTANTS_FILE"
    exit 1
}

# Update GitHub workflow
Write-Status "Updating GitHub workflow..."
$WORKFLOW_FILE = ".github/workflows/deploy-web.yml"

if (Test-Path $WORKFLOW_FILE) {
    # Create backup
    Copy-Item $WORKFLOW_FILE "$WORKFLOW_FILE.backup"
    
    # Read and update content
    $content = Get-Content $WORKFLOW_FILE -Raw
    $content = $content -replace "glimfo-todo", $REPO_NAME
    Set-Content $WORKFLOW_FILE $content
    
    Write-Success "Updated $WORKFLOW_FILE"
} else {
    Write-Error "Workflow file not found: $WORKFLOW_FILE"
    exit 1
}

# Show next steps
Write-Success "Configuration completed!"
Write-Host ""
Write-Status "Next steps:"
Write-Host "1. Commit and push your changes:"
Write-Host "   git add ."
Write-Host "   git commit -m 'Configure GitHub Pages deployment'"
Write-Host "   git push origin main"
Write-Host ""
Write-Host "2. Enable GitHub Pages in your repository:"
Write-Host "   - Go to: https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/pages"
Write-Host "   - Set Source to 'GitHub Actions'"
Write-Host ""
Write-Host "3. Update Supabase configuration:"
Write-Host "   - Site URL: https://$GITHUB_USERNAME.github.io"
Write-Host "   - Redirect URL: https://$GITHUB_USERNAME.github.io/$REPO_NAME/auth/callback"
Write-Host ""
Write-Host "4. Your app will be available at:"
Write-Host "   https://$GITHUB_USERNAME.github.io/$REPO_NAME/"
Write-Host ""
Write-Warning "Don't forget to update your Supabase settings!"
Write-Success "Setup complete! 🎉"