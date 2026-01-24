# Scripts Directory

This directory contains automation scripts and database migrations for the Flutter Todo App.

## Contents

### Setup Scripts

- **`setup_supabase.dart`** - Dart-based Supabase setup script
- **`setup_supabase.ps1`** - PowerShell script for Windows
- **`setup_supabase.sh`** - Bash script for Unix/Linux/Mac

### Migrations

The `migrations/` directory contains numbered SQL migration files:

- **`001_initial_schema.sql`** - Base database schema
- **`002_user_profile_trigger.sql`** - User profile auto-creation
- **`003_realtime_setup.sql`** - Real-time features setup

### Other Scripts

- **`validate_colors.dart`** - Color system validation
- **`validate_colors.ps1`** - PowerShell color validation
- **`validate_colors.sh`** - Bash color validation
- **`supabase_setup.sql`** - Legacy setup script (use migrations instead)
- **`supabase_verify_and_fix.sql`** - Database verification script

## Usage

### Automated Supabase Setup

#### Option 1: Supabase CLI (Recommended)

```bash
supabase login
supabase link --project-ref <your-project-ref>
supabase db push
```

#### Option 2: PowerShell (Windows)

```powershell
.\scripts\setup_supabase.ps1 -Url "https://your-project.supabase.co" -ServiceKey "your-service-key"
```

Or with environment variables:

```powershell
$env:SUPABASE_URL = "https://your-project.supabase.co"
$env:SUPABASE_SERVICE_KEY = "your-service-key"
.\scripts\setup_supabase.ps1
```

#### Option 3: Bash (Unix/Linux/Mac)

```bash
chmod +x scripts/setup_supabase.sh
./scripts/setup_supabase.sh --url "https://your-project.supabase.co" --key "your-service-key"
```

Or with environment variables:

```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_SERVICE_KEY="your-service-key"
./scripts/setup_supabase.sh
```

### Color Validation

To validate the color system:

```bash
# Dart
dart scripts/validate_colors.dart

# PowerShell
.\scripts\validate_colors.ps1

# Bash
chmod +x scripts/validate_colors.sh
./scripts/validate_colors.sh
```

## Migration System

### Creating New Migrations

1. Create a new file in `migrations/` with the next number:
   ```
   scripts/migrations/004_your_migration_name.sql
   ```

2. Write your SQL changes:
   ```sql
   -- Migration 004: Description
   
   -- Your SQL statements here
   ALTER TABLE tasks ADD COLUMN new_field TEXT;
   ```

3. Run migrations using one of the setup methods above

### Migration Best Practices

- **Idempotent**: Use `IF NOT EXISTS` and `IF EXISTS` clauses
- **Reversible**: Consider creating rollback scripts
- **Tested**: Test on development database first
- **Documented**: Add comments explaining changes
- **Atomic**: Keep migrations focused on single changes

## Documentation

For detailed setup instructions, see:

- [Supabase Setup Guide](../docs/supabase-setup-guide.md)
- [Real-time Features](../docs/realtime-features.md)
- [Backend Integration Summary](../docs/backend-integration-summary.md)

## Troubleshooting

### Scripts Not Executing

**Windows PowerShell**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Unix/Linux/Mac**:
```bash
chmod +x scripts/*.sh
```

### Migration Errors

If migrations fail:

1. Check Supabase project status
2. Verify service role key permissions
3. Review error messages in output
4. Try running migrations manually in Supabase SQL Editor

## Support

For issues or questions:

1. Check the documentation in `docs/`
2. Review Supabase logs in dashboard
3. Check project GitHub issues
4. Contact the development team

---

**Last Updated**: January 2026
