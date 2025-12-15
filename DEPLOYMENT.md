# 🚀 Deployment Guide

This document covers all deployment options for the Glimfo Todo app.

## 📱 **Available Platforms**

- ✅ **Web (GitHub Pages)** - Live demo and production
- ✅ **Android** - APK and Play Store
- ✅ **iOS** - App Store
- ✅ **Windows** - Microsoft Store
- ✅ **macOS** - Mac App Store
- ✅ **Linux** - Snap Store

## 🌐 **Web Deployment (GitHub Pages)**

### **Quick Start**
```bash
# 1. Push to main branch
git add .
git commit -m "Deploy to GitHub Pages"
git push origin main

# 2. Your app will be live at:
# https://YOUR_USERNAME.github.io/glimfo-todo/
```

### **Local Testing**
```bash
# Test GitHub Pages build locally
./scripts/deploy-web.sh github --serve
# or
.\scripts\deploy-web.ps1 github -Serve
```

**Detailed Guide:** See [GITHUB_PAGES_SETUP.md](GITHUB_PAGES_SETUP.md)

## 📱 **Mobile Deployment**

### **Android**

**Debug APK:**
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

**Release APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**App Bundle (Play Store):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### **iOS**

**Debug Build:**
```bash
flutter build ios --debug
```

**Release Build:**
```bash
flutter build ios --release
flutter build ipa --release
# Output: build/ios/ipa/glimfo_todo.ipa
```

## 🖥️ **Desktop Deployment**

### **Windows**

**Debug:**
```bash
flutter build windows --debug
```

**Release:**
```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

### **macOS**

**Debug:**
```bash
flutter build macos --debug
```

**Release:**
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

### **Linux**

**Debug:**
```bash
flutter build linux --debug
```

**Release:**
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

## ⚙️ **Environment Configuration**

### **Development**
```bash
# Local development
flutter run -d chrome --web-port 8080
```

### **Staging (GitHub Pages)**
```bash
# Build for GitHub Pages
flutter build web --release --base-href "/glimfo-todo/" --dart-define=GITHUB_PAGES=true
```

### **Production**
```bash
# Build for custom domain
flutter build web --release --base-href "/" --dart-define=PRODUCTION=true
```

## 🔐 **Supabase Configuration by Environment**

### **Development**
- Site URL: `http://localhost:8080`
- Redirect URL: `http://localhost:8080/auth/callback`

### **GitHub Pages**
- Site URL: `https://YOUR_USERNAME.github.io`
- Redirect URL: `https://YOUR_USERNAME.github.io/glimfo-todo/auth/callback`

### **Production**
- Site URL: `https://your-domain.com`
- Redirect URL: `https://your-domain.com/auth/callback`

## 🚀 **CI/CD Workflows**

### **GitHub Actions (Web)**
- **File:** `.github/workflows/deploy-web.yml`
- **Trigger:** Push to main branch
- **Output:** GitHub Pages deployment

### **Future Workflows**
- Android Play Store deployment
- iOS App Store deployment
- Desktop app releases

## 📊 **Build Optimization**

### **Web Optimization**
```bash
# Optimized web build
flutter build web --release \
  --web-renderer html \
  --tree-shake-icons \
  --dart-define=dart.vm.product=true
```

### **Mobile Optimization**
```bash
# Optimized Android build
flutter build apk --release \
  --tree-shake-icons \
  --split-debug-info=build/debug-info \
  --obfuscate

# Optimized iOS build
flutter build ios --release \
  --tree-shake-icons \
  --split-debug-info=build/debug-info \
  --obfuscate
```

## 🔍 **Testing Builds**

### **Web Testing**
```bash
# Test locally
python -m http.server 8000 -d build/web
# Visit: http://localhost:8000
```

### **Mobile Testing**
```bash
# Install debug APK
adb install build/app/outputs/flutter-apk/app-debug.apk

# iOS Simulator
flutter run -d ios
```

## 📋 **Pre-Deployment Checklist**

### **Web Deployment**
- [ ] Supabase URLs updated
- [ ] Email verification tested
- [ ] All routes working
- [ ] Responsive design verified
- [ ] Performance optimized
- [ ] Error handling tested

### **Mobile Deployment**
- [ ] App icons configured
- [ ] Splash screen working
- [ ] Deep links configured
- [ ] Permissions properly set
- [ ] Store metadata ready
- [ ] Screenshots prepared

### **Desktop Deployment**
- [ ] App icons configured
- [ ] Window sizing appropriate
- [ ] File associations set
- [ ] Installer created
- [ ] Code signing completed

## 🛠️ **Troubleshooting**

### **Common Issues**

**Build Fails:**
```bash
flutter clean
flutter pub get
flutter doctor
```

**Web Routing Issues:**
- Check base href configuration
- Verify 404.html is included
- Test direct URL access

**Authentication Issues:**
- Verify Supabase URLs
- Check redirect configurations
- Test email verification flow

**Performance Issues:**
- Enable tree shaking
- Optimize images
- Use web renderers appropriately

## 📞 **Support**

For deployment issues:
1. Check the troubleshooting section
2. Review GitHub Actions logs
3. Verify Supabase configuration
4. Test locally first

## 🎯 **Quick Commands Reference**

```bash
# Web
./scripts/deploy-web.sh github --serve

# Android
flutter build apk --release

# iOS
flutter build ipa --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```