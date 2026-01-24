# Supabase Setup Guide

This guide provides comprehensive instructions for setting up Supabase for the Flutter Todo App, including automated and manual setup options.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start (Automated)](#quick-start-automated)
3. [Manual Setup](#manual-setup)
4. [Database Migrations](#database-migrations)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have:

- A Supabase account (sign up at https://supabase.com)
- A Supabase project created
- Your Supabase project URL and keys
- Flutter SDK installed (3.0.0 or higher)
- Dart SDK installed

## Quick Start (Automated)

### Option 1: Using Supabase CLI (Recommended)

1. **Install Supabase CLI**:
   ```bash
   # macOS/Linux
   brew install supabase/tap/supabase
   
   # Windows
   scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
   scoop install supabase
   ```

2. **Login to Supabase**:
   ```bash
   supabase login
   ```

3. **Link your project**:
   ```bash
   supabase link --project-ref <your-project-ref>
   ```

4. **Run migrations**:
   ```bash
   # From the project root
   supabase db push
   ```

### Option 2: Using Setup Scripts

#### Windows (PowerShell)

```powershell
# Set environment variables
$env:SUPABASE_URL = "https://your-project.supabase.co"
$env:SUPABASE_SERVICE_KEY = "your-service-role-key"

# Run setup script
.\scripts\setup_supabase.ps1
```

Or with parameters:

```powershell
.\scripts\setup_supabase.ps1 -Url "https://your-project.supabase.co" -ServiceKey "your-service-role-key"
```

#### Unix/Linux/Mac (Bash)

```bash
# Make script executable
chmod +x scripts/setup_supabase.sh

# Set environment variables
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_SERVICE_KEY="your-service-role-key"

# Run setup script
./scripts/setup_supabase.sh
```

Or with parameters:

```bash
./scripts/setup_supabase.sh --url "https://your-project.supabase.co" --key "your-service-role-key"
```

## Manual Setup

If you prefer to set up manually or the automated scripts don't work:

### Step 1: Access Supabase SQL Editor

1. Go to https://supabase.com/dashboard
2. Select your project
3. Click on **SQL Editor** in the left sidebar
4. Click **New Query**

### Step 2: Run Migrations in Order

Execute each migration file in the `scripts/migrations/` directory in numerical order:

#### Migration 001: Initial Schema

Copy and paste the contents of `scripts/migrations/001_initial_schema.sql` into the SQL Editor and click **Run**.

This migration creates:
- `users` table with profile information
- `tasks` table with all task fields
- Indexes for query optimization
- Row Level Security (RLS) policies
- Triggers for automatic timestamp updates

#### Migration 002: User Profile Trigger

Copy and paste the contents of `scripts/migrations/002_user_profile_trigger.sql` and click **Run**.

This migration creates:
- Automatic user profile creation when a new auth user signs up
- Trigger on `auth.users` table

#### Migration 003: Real-time Setup

Copy and paste the contents of `scripts/migrations/003_realtime_setup.sql` and click **Run**.

This migration enables:
- Real-time subscriptions for the tasks table
- Notification system for task changes

#### Migration 004: Categories Table

Copy and paste the contents of `scripts/migrations/004_categories_table.sql` and click **Run**.

This migration creates:
- `categories` table for custom task categories
- RLS policies for category management
- Indexes for performance

#### Migration 005: Attachments Table

Copy and paste the contents of `scripts/migrations/005_attachments_table.sql` and click **Run**.

This migration creates:
- `attachments` table for file metadata
- `task-attachments` storage bucket
- RLS policies for attachment security
- Storage policies for file access
- Triggers for automatic attachment tracking

### Step 3: Enable Email Authentication

1. Go to **Authentication** → **Providers**
2. Ensure **Email** is enabled
3. (Optional) For testing, disable email confirmation:
   - Go to **Authentication** → **Settings**
   - Uncheck "Enable email confirmations"

### Step 4: Configure App Constants

Update `lib/core/constants/app_constants.dart` with your Supabase credentials:

```dart
class AppConstants {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';
  // ... other constants
}
```

## Database Migrations

### Migration System

The project uses a numbered migration system:

- `001_initial_schema.sql` - Base tables and policies
- `002_user_profile_trigger.sql` - Auto-create user profiles
- `003_realtime_setup.sql` - Enable real-time features

### Creating New Migrations

To create a new migration:

1. Create a new file in `scripts/migrations/` with the next number:
   ```
   scripts/migrations/004_your_migration_name.sql
   ```

2. Write your SQL changes:
   ```sql
   -- Migration 004: Description of changes
   
   -- Your SQL statements here
   ALTER TABLE tasks ADD COLUMN new_field TEXT;
   ```

3. Run the migration using one of the setup methods above

### Migration Best Practices

- **Idempotent**: Use `IF NOT EXISTS` and `IF EXISTS` clauses
- **Reversible**: Consider creating a rollback script
- **Tested**: Test migrations on a development database first
- **Documented**: Add comments explaining what the migration does
- **Atomic**: Keep migrations focused on a single change

## Verification

### Verify Tables

1. Go to **Table Editor** in Supabase dashboard
2. Confirm these tables exist:
   - ✅ `users`
   - ✅ `tasks`

### Verify Policies

1. Go to **Authentication** → **Policies**
2. Confirm RLS is enabled for both tables
3. Verify policies exist for SELECT, INSERT, UPDATE, DELETE

### Verify Triggers

1. Go to **Database** → **Triggers**
2. Confirm these triggers exist:
   - `update_users_updated_at`
   - `update_tasks_updated_at`
   - `on_auth_user_created`
   - `task_change_trigger`

### Test the Setup

Run the app and test:

1. **Create Account**:
   ```
   Email: test@example.com
   Password: password123
   ```

2. **Sign In** with the same credentials

3. **Create Tasks** and verify they appear

4. **Test Offline Mode**:
   - Create tasks while offline
   - Reconnect and verify sync

## Troubleshooting

### "Failed to create user account"

**Cause**: RLS policies or triggers not properly set up

**Solution**:
1. Verify all migrations ran successfully
2. Check Supabase logs: Dashboard → Logs
3. Ensure RLS policies are created
4. Verify the `on_auth_user_created` trigger exists

### "No internet connection" banner persists

**Cause**: Incorrect Supabase credentials or network issues

**Solution**:
1. Verify credentials in `app_constants.dart`
2. Check Supabase project is active
3. Test connection: `curl https://your-project.supabase.co`
4. Check browser console for errors (F12)

### Tables not appearing

**Cause**: SQL execution failed

**Solution**:
1. Check for error messages in SQL Editor
2. Run migrations one at a time
3. Verify you have proper permissions
4. Check Supabase project status

### Real-time not working

**Cause**: Real-time not enabled or publication not configured

**Solution**:
1. Verify migration 003 ran successfully
2. Check Database → Publications
3. Ensure `tasks` table is in `supabase_realtime` publication
4. Restart the app

### Migration conflicts

**Cause**: Running migrations multiple times or out of order

**Solution**:
1. Migrations are designed to be idempotent
2. Drop and recreate policies if needed
3. Check for duplicate triggers/functions
4. Use `DROP ... IF EXISTS` before creating

## Advanced Configuration

### Custom Domain

If using a custom domain:

1. Update `app_constants.dart` with your custom domain
2. Update CORS settings in Supabase dashboard
3. Configure SSL certificates

### Performance Optimization

For large datasets:

1. Add additional indexes based on query patterns
2. Use materialized views for complex queries
3. Enable connection pooling
4. Configure statement timeout

### Security Hardening

For production:

1. Enable email confirmation
2. Configure rate limiting
3. Set up custom SMTP for emails
4. Review and tighten RLS policies
5. Enable audit logging

## Next Steps

After successful setup:

1. ✅ Test all authentication flows
2. ✅ Test task CRUD operations
3. ✅ Test offline sync
4. ✅ Run integration tests
5. ✅ Deploy to production

## Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase CLI Reference](https://supabase.com/docs/reference/cli)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Real-time Guide](https://supabase.com/docs/guides/realtime)

## Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review Supabase logs in the dashboard
3. Check the project's GitHub issues
4. Contact Supabase support

---

**Last Updated**: January 2026
**Version**: 1.0.0
