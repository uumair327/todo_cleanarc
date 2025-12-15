#!/bin/bash

# Code Analysis Script
# This script runs Flutter analyze and provides a summary

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔍 Running Flutter Code Analysis...${NC}"

# Run flutter analyze and capture output
echo -e "${YELLOW}Analyzing code...${NC}"
if output=$(flutter analyze 2>&1); then
    echo -e "${GREEN}✅ No issues found!${NC}"
    echo -e "${WHITE}$output${NC}"
else
    echo -e "${YELLOW}⚠️ Issues found:${NC}"
    
    # Parse and categorize issues
    errors=$(echo "$output" | grep "^error •" | wc -l)
    warnings=$(echo "$output" | grep "^warning •" | wc -l)
    infos=$(echo "$output" | grep "^info •" | wc -l)
    
    # Display summary
    echo -e "${CYAN}📊 Issue Summary:${NC}"
    echo -e "  ${RED}Errors: $errors${NC}"
    echo -e "  ${YELLOW}Warnings: $warnings${NC}"
    echo -e "  ${BLUE}Info: $infos${NC}"
    
    # Show errors first (most critical)
    if [ $errors -gt 0 ]; then
        echo -e "${RED}❌ ERRORS (must fix):${NC}"
        echo "$output" | grep "^error •" | head -10 | while read -r line; do
            echo -e "  ${RED}$line${NC}"
        done
    fi
    
    # Show warnings (should fix)
    if [ $warnings -gt 0 ] && [ $warnings -le 10 ]; then
        echo -e "${YELLOW}⚠️ WARNINGS:${NC}"
        echo "$output" | grep "^warning •" | while read -r line; do
            echo -e "  ${YELLOW}$line${NC}"
        done
    elif [ $warnings -gt 10 ]; then
        echo -e "${YELLOW}⚠️ WARNINGS ($warnings total, showing first 10):${NC}"
        echo "$output" | grep "^warning •" | head -10 | while read -r line; do
            echo -e "  ${YELLOW}$line${NC}"
        done
        echo -e "  ${YELLOW}... and $((warnings - 10)) more warnings${NC}"
    fi
    
    # Show info summary (nice to fix)
    if [ $infos -gt 0 ]; then
        echo -e "${BLUE}ℹ️ INFO: $infos style/optimization suggestions${NC}"
    fi
    
    echo -e "${CYAN}🎯 Priority:${NC}"
    echo -e "  ${RED}1. Fix all ERRORS first${NC}"
    echo -e "  ${YELLOW}2. Address WARNINGS for production${NC}"
    echo -e "  ${BLUE}3. Consider INFO suggestions for code quality${NC}"
fi

echo -e "${GREEN}🚀 Next steps:${NC}"
echo -e "${WHITE}  flutter test    # Run tests${NC}"
echo -e "${WHITE}  flutter run     # Test the app${NC}"
echo -e "${WHITE}  flutter build web --release  # Build for production${NC}"