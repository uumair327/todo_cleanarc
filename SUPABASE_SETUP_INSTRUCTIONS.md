# Supabase Database Setup - Final Step

## ✅ Credentials Configured

Your Supabase credentials have been successfully added to the app:
- **URL**: `https://szazwyplviajizapiwyc.supabase.co`
- **Anon Key**: Configured ✓

## 🔧 Database Setup Required

You need to create the database tables in your Supabase project. 

### 🚀 Quick Setup (Recommended)

**Option 1: Automated Setup with Supabase CLI**

```bash
# Install Supabase CLI (if not already installed)
# macOS/Linux: brew install supabase/tap/supabase
# Windows: scoop install supabase

# Login and link your project
supabase login
supabase link --project-ref szazwyplviajizapiwyc

# Run migrations
supabase db push
```

**Option 2: Run Setup Script**

Windows (PowerShell):
```powershell
.\scripts\setup_supabase.ps1
```

Unix/Linux/Mac:
```bash
chmod +x scripts/setup_supabase.sh
./scripts/setup_supabase.sh
```

For detailed setup instructions, see [docs/supabase-setup-guide.md](docs/supabase-setup-guide.md)

### 📝 Manual Setup

If you prefer manual setup, follow these steps:

### Step 1: Open Supabase SQL Editor

1. Go to https://supabase.com/dashboard
2. Select your project: `szazwyplviajizapiwyc`
3. Click on **SQL Editor** in the left sidebar
4. Click **New Query**

### Step 2: Run the Setup Script

Copy the entire content from `scripts/supabase_setup.sql` and paste it into the SQL Editor, then click **Run**.

**Or manually copy this:**

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'pending',
    priority TEXT NOT NULL DEFAULT 'medium',
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT TRUE,
    CONSTRAINT tasks_status_check CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    CONSTRAINT tasks_priority_check CHECK (priority IN ('low', 'medium', 'high', 'urgent'))
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
CREATE POLICY "Users can view their own profile"
    ON users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON users FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
    ON users FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can delete their own profile"
    ON users FOR DELETE
    USING (auth.uid() = id);

-- Create policies for tasks table
CREATE POLICY "Users can view their own tasks"
    ON tasks FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own tasks"
    ON tasks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own tasks"
    ON tasks FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own tasks"
    ON tasks FOR DELETE
    USING (auth.uid() = user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON users TO authenticated;
GRANT ALL ON tasks TO authenticated;
```

### Step 3: Verify Tables Created

1. Go to **Table Editor** in Supabase dashboard
2. You should see two tables:
   - ✅ `users`
   - ✅ `tasks`

### Step 4: Enable Email Authentication

1. Go to **Authentication** → **Providers**
2. Ensure **Email** is enabled
3. For testing, you can disable email confirmation:
   - Go to **Authentication** → **Settings**
   - Uncheck "Enable email confirmations" (optional, for easier testing)

### Step 5: Test Your App

Your app should now be running in Chrome. Try:

1. **Create Account**:
   - Email: `test@example.com`
   - Password: `password123` (min 8 characters)

2. **Sign In** with the same credentials

3. **Create Tasks** and test offline functionality

## ✅ Verification Checklist

- [ ] SQL script executed successfully
- [ ] `users` table visible in Table Editor
- [ ] `tasks` table visible in Table Editor
- [ ] Email authentication enabled
- [ ] App running in Chrome
- [ ] "No internet connection" banner gone
- [ ] Can create account
- [ ] Can sign in
- [ ] Can create tasks

## 🐛 Troubleshooting

### "Failed to create user account"
- Check if SQL script ran without errors
- Verify RLS policies are created
- Check Supabase logs in Dashboard → Logs

### "No internet connection" still showing
- Hard refresh the browser (Ctrl+Shift+R or Cmd+Shift+R)
- Check browser console for errors (F12)
- Verify credentials in `lib/core/constants/app_constants.dart`

### Tables not appearing
- Make sure you clicked "Run" in SQL Editor
- Check for error messages in SQL Editor
- Try running each CREATE TABLE statement separately

## 📱 Next Steps

Once everything works:

1. **Test Offline Mode**:
   - Create some tasks
   - Disconnect internet
   - Create more tasks
   - Reconnect internet
   - Verify sync works

2. **Build for Production**:
   ```bash
   # Android
   flutter build appbundle --release
   
   # iOS
   flutter build ipa --release
   
   # Web
   flutter build web --release
   ```

3. **Deploy**: Follow `PRODUCTION_CHECKLIST.md`

## 🎉 Success!

Once you can create an account and tasks, your Glimfo Todo app is fully functional and ready for production deployment!

---

**Project**: Glimfo Todo
**Package**: com.glimfo.todo
**Supabase Project**: szazwyplviajizapiwyc
**Status**: Credentials configured ✓ | Database setup required
