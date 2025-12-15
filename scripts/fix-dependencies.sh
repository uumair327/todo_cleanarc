#!/bin/bash

# Fix Dependencies Script
# This script resolves Flutter dependency conflicts

set -e

echo "🔧 Fixing Flutter Dependencies..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Clean the project
echo -e "${YELLOW}Cleaning Flutter project...${NC}"
if flutter clean; then
    echo -e "${GREEN}✅ Project cleaned successfully${NC}"
else
    echo -e "${YELLOW}⚠️ Flutter clean failed, continuing...${NC}"
fi

# Remove pubspec.lock if it exists
if [ -f "pubspec.lock" ]; then
    rm -f pubspec.lock
    echo -e "${GREEN}✅ Removed pubspec.lock${NC}"
fi

# Get dependencies
echo -e "${YELLOW}Getting Flutter dependencies...${NC}"
if flutter pub get; then
    echo -e "${GREEN}✅ Dependencies resolved successfully!${NC}"
else
    echo -e "${RED}❌ Failed to resolve dependencies${NC}"
    echo -e "${CYAN}🔍 Troubleshooting suggestions:${NC}"
    echo -e "${WHITE}1. Check Flutter version: flutter --version${NC}"
    echo -e "${WHITE}2. Update Flutter: flutter upgrade${NC}"
    echo -e "${WHITE}3. Check Dart SDK version compatibility${NC}"
    echo -e "${WHITE}4. Try: flutter pub deps${NC}"
    exit 1
fi

# Verify the fix
echo -e "${YELLOW}🧪 Verifying dependencies...${NC}"
if flutter pub deps; then
    echo -e "${GREEN}✅ All dependencies verified!${NC}"
else
    echo -e "${YELLOW}⚠️ Dependency verification had issues, but pub get succeeded${NC}"
fi

echo -e "${GREEN}🎉 Dependency resolution complete!${NC}"
echo -e "${WHITE}You can now run:${NC}"
echo -e "${CYAN}  flutter run${NC}"
echo -e "${CYAN}  flutter test${NC}"
echo -e "${CYAN}  flutter build web${NC}"