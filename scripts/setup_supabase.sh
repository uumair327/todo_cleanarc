#!/bin/bash
# Supabase Setup Script for Unix/Linux/Mac
# This script automates the Supabase database setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 Supabase Automated Setup${NC}"
echo -e "${CYAN}==================================================${NC}"
echo ""

# Parse arguments
URL=""
SERVICE_KEY=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --url)
            URL="$2"
            shift 2
            ;;
        --key)
            SERVICE_KEY="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Fall back to environment variables
if [ -z "$URL" ]; then
    URL="$SUPABASE_URL"
fi

if [ -z "$SERVICE_KEY" ]; then
    SERVICE_KEY="$SUPABASE_SERVICE_KEY"
fi

# Check if required parameters are provided
if [ -z "$URL" ] || [ -z "$SERVICE_KEY" ]; then
    echo -e "${RED}❌ Error: Missing required configuration${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  ./scripts/setup_supabase.sh --url <SUPABASE_URL> --key <SERVICE_ROLE_KEY>"
    echo ""
    echo -e "${YELLOW}Or set environment variables:${NC}"
    echo "  export SUPABASE_URL='<url>'"
    echo "  export SUPABASE_SERVICE_KEY='<key>'"
    echo "  ./scripts/setup_supabase.sh"
    exit 1
fi

echo -e "${GREEN}📍 Supabase URL: $URL${NC}"
echo ""

# Check if migrations directory exists
MIGRATIONS_DIR="scripts/migrations"
if [ ! -d "$MIGRATIONS_DIR" ]; then
    echo -e "${YELLOW}⚠️  No migrations directory found${NC}"
    exit 0
fi

# Get all migration files
MIGRATIONS=($(ls -1 "$MIGRATIONS_DIR"/*.sql 2>/dev/null | sort))

if [ ${#MIGRATIONS[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No migration files found${NC}"
    exit 0
fi

echo -e "${GREEN}📦 Found ${#MIGRATIONS[@]} migration(s)${NC}"
echo ""

# Execute each migration
SUCCESS_COUNT=0
FAIL_COUNT=0
INDEX=1

for migration in "${MIGRATIONS[@]}"; do
    MIGRATION_NAME=$(basename "$migration")
    echo -e "${CYAN}[$INDEX/${#MIGRATIONS[@]}] Running: $MIGRATION_NAME${NC}"
    
    # Read SQL file
    SQL=$(cat "$migration")
    
    # Note: Supabase doesn't have a direct SQL execution endpoint via REST API
    # This is a placeholder - in production, use Supabase CLI or Management API
    # For now, we'll just validate the files exist
    if [ -f "$migration" ]; then
        echo -e "  ${GREEN}✅ Migration file validated${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "  ${RED}❌ Failed to read migration file${NC}"
        ((FAIL_COUNT++))
    fi
    
    echo ""
    ((INDEX++))
done

# Summary
echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}📊 Summary:${NC}"
echo -e "  ${GREEN}✅ Successful: $SUCCESS_COUNT${NC}"
echo -e "  ${RED}❌ Failed: $FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}🎉 Migration files validated!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  ${NC}1. Run migrations using Supabase CLI:${NC}"
    echo -e "     ${CYAN}supabase db push${NC}"
    echo -e "  ${NC}2. Or manually execute each SQL file in Supabase SQL Editor${NC}"
    echo -e "  ${NC}3. Enable email authentication in Supabase dashboard${NC}"
    echo -e "  ${NC}4. Update app_constants.dart with your credentials${NC}"
    echo -e "  ${NC}5. Run the app: flutter run${NC}"
else
    echo -e "${YELLOW}⚠️  Some validations failed. Please check the errors above.${NC}"
    exit 1
fi
