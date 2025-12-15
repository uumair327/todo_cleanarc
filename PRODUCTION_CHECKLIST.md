# Glimfo Todo - Production Deployment Checklist

## Package Details
- **Package Name**: `com.glimfo.todo`
- **App Name**: Glimfo Todo
- **Bundle ID (iOS)**: `com.glimfo.todo`
- **Application ID (Android)**: `com.glimfo.todo`

## Pre-Deployment Checklist

### 1. Supabase Configuration ✓
- [ ] Supabase project created
- [ ] Database tables created (run `scripts/supabase_setup.sql`)
- [ ] Row Level Security (RLS) policies enabled
- [ ] API credentials updated in `lib/core/constants/app_constants.dart`
- [ ] Email authentication enabled
- [ ] SMTP configured for production emails (optional)
- [ ] Supabase project moved to production tier (if needed)

### 2. App Configuration ✓
- [ ] Package name updated to `com.glimfo.todo`
- [ ] App name updated to "Glimfo Todo"
- [ ] Version number set (currently 1.0.0+1)
- [ ] App icons created for all platforms
- [ ] Splash screens configured
- [ ] Deep linking configured (if needed)

### 3. Security
- [ ] API keys not hardcoded (consider environment variables)
- [ ] `.env` file added to `.gitignore`
- [ ] Supabase RLS policies tested
- [ ] Authentication flows tested
- [ ] Data encryption verified
- [ ] HTTPS enforced for all API calls

### 4. Testing
- [ ] Unit tests passing
- [ ] Integration tests passing (`flutter test integration_test/`)
- [ ] Tested on real Android device
- [ ] Tested on real iOS device
- [ ] Tested on web browsers (Chrome, Safari, Firefox)
- [ ] Tested offline functionality
- [ ] Tested sync after reconnection
- [ ] Performance profiling completed
- [ ] Memory leaks checked

### 5. Platform-Specific

#### Android
- [ ] Package name: `com.glimfo.todo` ✓
- [ ] Min SDK: 21 ✓
- [ ] Target SDK: Latest ✓
- [ ] Internet permission added ✓
- [ ] Network state permission added ✓
- [ ] App signing key generated
- [ ] `key.properties` configured
- [ ] ProGuard rules configured (if needed)
- [ ] App bundle built (`flutter build appbundle --release`)
- [ ] Tested on multiple Android versions
- [ ] Play Store listing prepared

#### iOS
- [ ] Bundle ID: `com.glimfo.todo` ✓
- [ ] Team and signing configured in Xcode
- [ ] App icons added to Assets.xcassets
- [ ] Launch screen configured
- [ ] Privacy descriptions added to Info.plist
- [ ] Archive built (`flutter build ipa --release`)
- [ ] Tested on multiple iOS versions
- [ ] App Store listing prepared

#### Web
- [ ] App name updated in `web/index.html` ✓
- [ ] Manifest updated in `web/manifest.json` ✓
- [ ] Meta tags optimized for SEO
- [ ] PWA icons configured
- [ ] Service worker configured (if needed)
- [ ] Built for production (`flutter build web --release`)
- [ ] Hosting platform selected
- [ ] Domain configured (if custom domain)

#### Windows
- [ ] Binary name: `glimfo_todo` ✓
- [ ] App icon configured
- [ ] Built for release (`flutter build windows --release`)
- [ ] Installer created (optional)

#### macOS
- [ ] Bundle ID: `com.glimfo.todo` ✓
- [ ] App icon configured
- [ ] Signing configured
- [ ] Built for release (`flutter build macos --release`)

#### Linux
- [ ] Application ID: `com.glimfo.todo` ✓
- [ ] Desktop file configured
- [ ] App icon configured
- [ ] Built for release (`flutter build linux --release`)

### 6. Legal & Compliance
- [ ] Privacy Policy created
- [ ] Terms of Service created
- [ ] GDPR compliance verified (if applicable)
- [ ] Data retention policy defined
- [ ] User data deletion flow implemented
- [ ] Cookie policy (for web)
- [ ] Age restrictions defined

### 7. App Store Listings

#### Google Play Store
- [ ] App title: "Glimfo Todo"
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] Screenshots (phone, tablet, TV if applicable)
- [ ] Feature graphic (1024x500)
- [ ] App icon (512x512)
- [ ] Category selected
- [ ] Content rating completed
- [ ] Pricing set (Free/Paid)
- [ ] Countries/regions selected
- [ ] Privacy policy URL added

#### Apple App Store
- [ ] App name: "Glimfo Todo"
- [ ] Subtitle (30 chars)
- [ ] Description (4000 chars)
- [ ] Keywords (100 chars)
- [ ] Screenshots (all required sizes)
- [ ] App preview video (optional)
- [ ] App icon (1024x1024)
- [ ] Category selected
- [ ] Age rating completed
- [ ] Pricing set
- [ ] Privacy policy URL added
- [ ] Support URL added

### 8. Analytics & Monitoring (Optional)
- [ ] Firebase Analytics integrated
- [ ] Crashlytics configured
- [ ] Performance monitoring enabled
- [ ] User feedback mechanism added
- [ ] Error tracking configured (Sentry, etc.)

### 9. Marketing Materials
- [ ] App icon designed
- [ ] Screenshots captured
- [ ] Promotional graphics created
- [ ] App preview video created (optional)
- [ ] Website/landing page created
- [ ] Social media accounts created
- [ ] Press kit prepared

### 10. Post-Launch
- [ ] Monitor crash reports
- [ ] Monitor user reviews
- [ ] Track analytics
- [ ] Prepare for updates
- [ ] Customer support channel established
- [ ] Backup strategy implemented
- [ ] Monitoring alerts configured

## Build Commands Reference

### Development
```bash
# Run in debug mode
flutter run

# Run on specific device
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

### Testing
```bash
# Run all tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

### Production Builds
```bash
# Android
flutter build apk --release                    # APK
flutter build appbundle --release              # App Bundle (Play Store)

# iOS
flutter build ipa --release                    # iOS Archive

# Web
flutter build web --release                    # Web build

# Desktop
flutter build windows --release                # Windows
flutter build macos --release                  # macOS
flutter build linux --release                  # Linux
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter build [platform] --release
```

## Environment Setup

### Required Tools
- Flutter SDK 3.0.0+
- Dart SDK (included with Flutter)
- Android Studio (for Android)
- Xcode (for iOS/macOS, macOS only)
- Visual Studio (for Windows, Windows only)
- Chrome (for web development)

### Recommended VS Code Extensions
- Flutter
- Dart
- Flutter Widget Snippets
- Error Lens
- GitLens

## Supabase Production Configuration

### Database Optimization
- [ ] Indexes created on frequently queried columns
- [ ] Database backups enabled
- [ ] Connection pooling configured
- [ ] Query performance optimized

### Security
- [ ] RLS policies tested thoroughly
- [ ] API rate limiting configured
- [ ] CORS configured for web
- [ ] JWT expiration configured
- [ ] Password policies enforced

### Monitoring
- [ ] Database metrics monitored
- [ ] API usage tracked
- [ ] Error logs reviewed
- [ ] Performance metrics tracked

## Version Management

Current Version: **1.0.0+1**

Version Format: `MAJOR.MINOR.PATCH+BUILD`
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes
- BUILD: Build number (increment for each release)

### Updating Version
Update in `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

## Support & Documentation

- **Setup Guide**: `SETUP_GUIDE.md`
- **README**: `README.md`
- **Integration Tests**: `integration_test/README.md`
- **Supabase Schema**: `scripts/supabase_setup.sql`

## Emergency Contacts

- **Supabase Support**: https://supabase.com/support
- **Flutter Issues**: https://github.com/flutter/flutter/issues
- **Play Console**: https://play.google.com/console
- **App Store Connect**: https://appstoreconnect.apple.com

## Notes

- Always test on real devices before production release
- Keep Supabase credentials secure and never commit to version control
- Monitor app performance and user feedback after launch
- Plan for regular updates and maintenance
- Keep dependencies up to date for security patches

---

**Last Updated**: December 14, 2025
**Package**: com.glimfo.todo
**Version**: 1.0.0+1
