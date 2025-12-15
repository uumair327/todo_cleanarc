#!/bin/bash

# GitHub Pages Setup Script
# This script helps configure your repository for GitHub Pages deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "🚀 GitHub Pages Setup for Flutter Todo App"
echo "=========================================="

# Get GitHub username and repository name
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter your repository name (default: glimfo-todo): " REPO_NAME
REPO_NAME=${REPO_NAME:-glimfo-todo}

print_status "Configuring for:"
echo "  GitHub Username: $GITHUB_USERNAME"
echo "  Repository Name: $REPO_NAME"
echo "  GitHub Pages URL: https://$GITHUB_USERNAME.github.io/$REPO_NAME/"

# Update auth constants
print_status "Updating auth constants..."
AUTH_CONSTANTS_FILE="lib/core/constants/auth_constants.dart"

if [ -f "$AUTH_CONSTANTS_FILE" ]; then
    # Create backup
    cp "$AUTH_CONSTANTS_FILE" "$AUTH_CONSTANTS_FILE.backup"
    
    # Update the GitHub Pages URL
    sed -i.tmp "s/YOUR_GITHUB_USERNAME/$GITHUB_USERNAME/g" "$AUTH_CONSTANTS_FILE"
    sed -i.tmp "s/glimfo-todo/$REPO_NAME/g" "$AUTH_CONSTANTS_FILE"
    rm "$AUTH_CONSTANTS_FILE.tmp"
    
    print_success "Updated $AUTH_CONSTANTS_FILE"
else
    print_error "Auth constants file not found: $AUTH_CONSTANTS_FILE"
    exit 1
fi

# Update GitHub workflow
print_status "Updating GitHub workflow..."
WORKFLOW_FILE=".github/workflows/deploy-web.yml"

if [ -f "$WORKFLOW_FILE" ]; then
    # Create backup
    cp "$WORKFLOW_FILE" "$WORKFLOW_FILE.backup"
    
    # Update the base href
    sed -i.tmp "s/glimfo-todo/$REPO_NAME/g" "$WORKFLOW_FILE"
    rm "$WORKFLOW_FILE.tmp"
    
    print_success "Updated $WORKFLOW_FILE"
else
    print_error "Workflow file not found: $WORKFLOW_FILE"
    exit 1
fi

# Show next steps
print_success "Configuration completed!"
echo ""
print_status "Next steps:"
echo "1. Commit and push your changes:"
echo "   git add ."
echo "   git commit -m 'Configure GitHub Pages deployment'"
echo "   git push origin main"
echo ""
echo "2. Enable GitHub Pages in your repository:"
echo "   - Go to: https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/pages"
echo "   - Set Source to 'GitHub Actions'"
echo ""
echo "3. Update Supabase configuration:"
echo "   - Site URL: https://$GITHUB_USERNAME.github.io"
echo "   - Redirect URL: https://$GITHUB_USERNAME.github.io/$REPO_NAME/auth/callback"
echo ""
echo "4. Your app will be available at:"
echo "   https://$GITHUB_USERNAME.github.io/$REPO_NAME/"
echo ""
print_warning "Don't forget to update your Supabase settings!"
print_success "Setup complete! 🎉"