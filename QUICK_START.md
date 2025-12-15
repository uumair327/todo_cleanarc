# Glimfo Todo - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Setup Supabase (Required)

1. **Create Project**: Go to https://supabase.com → New Project
2. **Run SQL**: Copy `scripts/supabase_setup.sql` → Supabase SQL Editor → Run
3. **Get Credentials**: Project Settings → API → Copy URL and anon key
4. **Update App**: Edit `lib/core/constants/app_constants.dart`:

```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key-here';
```

### Step 3: Run the App
```bash
# Web (recommended for testing)
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## ✅ Verification

After running, you should see:
- ✅ App launches without errors
- ✅ "No internet connection" banner disappears
- ✅ Can create an account
- ✅ Can sign in
- ✅ Can create tasks

## 📱 Build for Production

### Android (Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (App Store)
```bash
flutter build ipa --release
```
Then upload via Xcode Organizer

### Web
```bash
flutter build web --release
```
Deploy `build/web/` folder to your hosting

## 📚 Documentation

- **Full Setup**: [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Production Checklist**: [PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md)
- **Package Changes**: [PACKAGE_UPDATE_SUMMARY.md](PACKAGE_UPDATE_SUMMARY.md)

## 🆘 Troubleshooting

### "No internet connection" persists
- Verify Supabase credentials are correct
- Check Supabase project is active
- Ensure you saved `app_constants.dart`

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

### Supabase connection fails
- Verify SQL script ran successfully
- Check RLS policies are enabled
- Ensure email auth is enabled in Supabase

## 📦 Package Info

- **Package**: `com.glimfo.todo`
- **Version**: 1.0.0+1
- **Platforms**: Android, iOS, Web, Windows, macOS, Linux

## 🎯 Next Steps

1. ✅ Setup Supabase
2. ✅ Test account creation
3. ✅ Test task management
4. ✅ Test offline mode
5. 📱 Build for your platform
6. 🚀 Deploy to stores

---

**Need Help?** Check the detailed guides in the documentation folder.
