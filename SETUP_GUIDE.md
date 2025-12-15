# Glimfo Todo - Production Setup Guide

## Package Information
- **Package Name**: `com.glimfo.todo`
- **App Name**: Glimfo Todo
- **Version**: 1.0.0+1

## Prerequisites

Before deploying to production, ensure you have:
- Flutter SDK (3.0.0 or higher)
- Supabase account
- Android Studio (for Android builds)
- Xcode (for iOS builds, macOS only)

## Supabase Setup (Required for Production)

### Step 1: Create Supabase Project

1. Go to https://supabase.com and sign up/login
2. Click "New Project"
3. Fill in project details:
   - **Name**: glimfo-todo (or your preferred name)
   - **Database Password**: Create a strong password (save it securely)
   - **Region**: Choose closest to your users
4. Wait for project setup to complete (2-3 minutes)

### Step 2: Configure Database

1. In Supabase dashboard, go to **SQL Editor**
2. Click "New Query"
3. Copy and paste the entire content from `scripts/supabase_setup.sql`
4. Click "Run" to execute the script
5. Verify tables are created:
   - Go to **Table Editor**
   - You should see `users` and `tasks` tables

### Step 3: Get API Credentials

1. In Supabase dashboard, go to **Project Settings** > **API**
2. Copy these values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon public** key (starts with `eyJ...`)

### Step 4: Update App Configuration

1. Open `lib/core/constants/app_constants.dart`
2. Replace the placeholder values:

```dart
class AppConstants {
  // Database
  static const String hiveBoxName = 'todo_box';
  static const String userBoxName = 'user_box';
  
  // Supabase - REPLACE THESE WITH YOUR VALUES
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
}
```

### Step 5: Enable Email Authentication

1. In Supabase dashboard, go to **Authentication** > **Providers**
2. Ensure **Email** provider is enabled
3. Configure email settings:
   - **Enable email confirmations**: Optional (disable for testing)
   - **Secure email change**: Recommended for production
4. For production, configure SMTP settings for custom emails

### Step 6: Test the Setup

Run the app and test:
```bash
flutter run -d chrome
```

Try creating an account - it should now work!

## Building for Production

### Android (Play Store)

1. **Update Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Generate App Signing Key**:
   ```bash
   keytool -genkey -v -keystore ~/glimfo-todo-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias glimfo-todo
   ```

3. **Create `android/key.properties`**:
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=glimfo-todo
   storeFile=<path-to-your-jks-file>
   ```

4. **Update `android/app/build.gradle.kts`** (add signing config):
   ```kotlin
   // Add before android block
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }
   
   // In android block, add:
   signingConfigs {
       release {
           keyAlias keystoreProperties['keyAlias']
           keyPassword keystoreProperties['keyPassword']
           storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
           storePassword keystoreProperties['storePassword']
       }
   }
   
   buildTypes {
       release {
           signingConfig signingConfigs.release
       }
   }
   ```

5. **Build Release APK/AAB**:
   ```bash
   # For APK
   flutter build apk --release
   
   # For App Bundle (recommended for Play Store)
   flutter build appbundle --release
   ```

6. **Upload to Play Console**:
   - Go to https://play.google.com/console
   - Create new app or select existing
   - Upload the AAB file from `build/app/outputs/bundle/release/`

### iOS (App Store)

1. **Open in Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure Signing**:
   - Select Runner in project navigator
   - Go to Signing & Capabilities
   - Select your Team
   - Ensure Bundle Identifier is `com.glimfo.todo`

3. **Build Archive**:
   ```bash
   flutter build ipa --release
   ```

4. **Upload to App Store Connect**:
   - Open Xcode
   - Window > Organizer
   - Select your archive
   - Click "Distribute App"

### Web

1. **Build for Web**:
   ```bash
   flutter build web --release
   ```

2. **Deploy** (choose one):
   - **Firebase Hosting**: `firebase deploy`
   - **Netlify**: Drag `build/web` folder
   - **Vercel**: Connect GitHub repo
   - **Custom Server**: Upload `build/web` contents

### Windows

```bash
flutter build windows --release
```
Output: `build/windows/runner/Release/`

### macOS

```bash
flutter build macos --release
```
Output: `build/macos/Build/Products/Release/`

### Linux

```bash
flutter build linux --release
```
Output: `build/linux/x64/release/bundle/`

## Environment Variables (Optional)

For better security, consider using environment variables:

1. Install `flutter_dotenv`:
   ```yaml
   dependencies:
     flutter_dotenv: ^5.1.0
   ```

2. Create `.env` file:
   ```
   SUPABASE_URL=your-url
   SUPABASE_ANON_KEY=your-key
   ```

3. Add to `.gitignore`:
   ```
   .env
   ```

4. Load in app:
   ```dart
   await dotenv.load(fileName: ".env");
   ```

## Testing Before Production

1. **Run Integration Tests**:
   ```bash
   flutter test integration_test/
   ```

2. **Test on Real Devices**:
   - Android: `flutter run --release`
   - iOS: `flutter run --release`
   - Web: `flutter run -d chrome --release`

3. **Performance Testing**:
   ```bash
   flutter run --profile
   ```

## Post-Deployment Checklist

- [ ] Supabase database configured with RLS policies
- [ ] Email authentication enabled
- [ ] App icons updated for all platforms
- [ ] Privacy policy and terms of service added
- [ ] Analytics configured (optional)
- [ ] Crash reporting setup (optional)
- [ ] App store listings prepared
- [ ] Screenshots and promotional materials ready

## Troubleshooting

### "No internet connection" banner
- Ensure Supabase credentials are correct
- Check network permissions in AndroidManifest.xml
- Verify Supabase project is active

### Build failures
- Run `flutter clean && flutter pub get`
- Check Flutter version: `flutter --version`
- Update dependencies: `flutter pub upgrade`

### Supabase connection issues
- Verify API URL and key
- Check Supabase project status
- Review RLS policies in Supabase dashboard

## Support

For issues or questions:
- Check `README.md` for project documentation
- Review integration tests in `integration_test/`
- Check Supabase logs in dashboard
