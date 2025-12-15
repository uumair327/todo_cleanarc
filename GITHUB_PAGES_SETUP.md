# 🚀 GitHub Pages Deployment Guide

This guide will help you deploy your Flutter Todo app to GitHub Pages with automated CI/CD.

## 📋 **Prerequisites**

- GitHub repository for your project
- Flutter web app (already configured ✅)
- Supabase project (already configured ✅)

## 🔧 **Step 1: Repository Setup**

### **1.1 Enable GitHub Pages**

1. Go to your GitHub repository
2. Click **Settings** → **Pages**
3. Under **Source**, select **GitHub Actions**
4. Save the settings

### **1.2 Update Repository Name**

If your repository isn't named `glimfo-todo`, update the workflow:

1. Open `.github/workflows/deploy-web.yml`
2. Replace `/glimfo-todo/` with `/YOUR_REPO_NAME/`
3. Update `lib/core/constants/auth_constants.dart`:
   ```dart
   static const String githubPagesUrl = 'https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/auth/callback';
   ```

## 🔧 **Step 2: Configure Supabase for GitHub Pages**

### **2.1 Update Supabase URLs**

1. Go to [Supabase Dashboard](https://supabase.com/dashboard/project/szazwyplviajizapiwyc/auth/url-configuration)

2. **Add GitHub Pages URLs:**
   ```
   Site URL: https://YOUR_USERNAME.github.io
   
   Redirect URLs:
   https://YOUR_USERNAME.github.io/glimfo-todo/auth/callback
   https://YOUR_USERNAME.github.io/glimfo-todo/#/auth/callback
   http://localhost:8080/auth/callback (keep for development)
   ```

3. **Replace placeholders:**
   - `YOUR_USERNAME` = Your GitHub username
   - `glimfo-todo` = Your repository name (if different)

### **2.2 Enable Email Confirmations**

1. Go to **Authentication** → **Settings**
2. Enable **"Enable email confirmations"**
3. Set **"Confirm email"** to `true`

## 🔧 **Step 3: Deploy Your App**

### **3.1 Automatic Deployment**

The workflow will automatically deploy when you:

1. **Push to main branch:**
   ```bash
   git add .
   git commit -m "Deploy to GitHub Pages"
   git push origin main
   ```

2. **Check deployment status:**
   - Go to **Actions** tab in your repository
   - Watch the "Deploy Flutter Web to GitHub Pages" workflow
   - Deployment takes ~3-5 minutes

### **3.2 Manual Deployment**

You can also trigger deployment manually:

1. Go to **Actions** tab
2. Click **"Deploy Flutter Web to GitHub Pages"**
3. Click **"Run workflow"**
4. Select branch and click **"Run workflow"**

## 🔧 **Step 4: Local Testing**

### **4.1 Test GitHub Pages Build Locally**

**Windows (PowerShell):**
```powershell
.\scripts\deploy-web.ps1 github -Serve
```

**Linux/Mac:**
```bash
./scripts/deploy-web.sh github --serve
```

### **4.2 Test Different Environments**

```bash
# Development build
./scripts/deploy-web.sh dev --serve

# GitHub Pages build
./scripts/deploy-web.sh github --serve

# Production build
./scripts/deploy-web.sh prod --serve
```

## 🔧 **Step 5: Verify Deployment**

### **5.1 Check Your Live App**

Your app will be available at:
```
https://YOUR_USERNAME.github.io/glimfo-todo/
```

### **5.2 Test Authentication Flow**

1. **Sign Up:**
   - Create a new account
   - Should redirect to email verification screen
   - Check email for verification link

2. **Email Verification:**
   - Click verification link in email
   - Should redirect to your GitHub Pages app
   - Should show "Email verified successfully!"
   - Should automatically sign you in

3. **Sign In:**
   - Test with verified account
   - Should work normally

## 🐛 **Troubleshooting**

### **Build Fails**

```bash
# Check Flutter version
flutter --version

# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

### **404 Error on GitHub Pages**

1. Check if GitHub Pages is enabled
2. Verify the base href in the build command
3. Ensure the workflow completed successfully

### **Authentication Issues**

1. **Email verification redirects to 404:**
   - Check Supabase redirect URLs
   - Ensure GitHub Pages URL is correct
   - Verify base href matches repository name

2. **CORS errors:**
   - Check Supabase CORS settings
   - Ensure your GitHub Pages domain is allowed

### **Routing Issues**

1. **Direct URL access fails:**
   - This is normal for SPAs on GitHub Pages
   - Users should access via the main URL
   - Consider adding a 404.html redirect

## 🔧 **Step 6: Custom Domain (Optional)**

### **6.1 Add Custom Domain**

1. **In GitHub:**
   - Go to **Settings** → **Pages**
   - Add your custom domain
   - Enable **"Enforce HTTPS"**

2. **Update Supabase:**
   ```
   Site URL: https://your-domain.com
   Redirect URLs: https://your-domain.com/auth/callback
   ```

3. **Update Auth Constants:**
   ```dart
   static const String prodRedirectUrl = 'https://your-domain.com/auth/callback';
   ```

## 📊 **Monitoring & Analytics**

### **6.1 GitHub Actions Monitoring**

- Check **Actions** tab for deployment status
- Set up notifications for failed deployments
- Monitor build times and success rates

### **6.2 App Performance**

- Use browser dev tools to check loading times
- Monitor Supabase usage in dashboard
- Check for console errors

## 🚀 **Production Checklist**

Before going live:

- [ ] GitHub Pages enabled and working
- [ ] Supabase URLs updated for production
- [ ] Email verification tested end-to-end
- [ ] All authentication flows working
- [ ] App loads correctly on different devices
- [ ] HTTPS enforced
- [ ] Custom domain configured (if applicable)
- [ ] Error monitoring set up
- [ ] Performance optimized

## 📱 **Quick Commands**

```bash
# Build and test locally for GitHub Pages
./scripts/deploy-web.sh github --serve

# Deploy to GitHub Pages
git add .
git commit -m "Deploy to production"
git push origin main

# Check deployment status
# Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/actions
```

## 🎉 **Success!**

Once everything is set up, your Flutter Todo app will be:

- ✅ Automatically deployed to GitHub Pages
- ✅ Accessible at `https://YOUR_USERNAME.github.io/glimfo-todo/`
- ✅ Email verification working properly
- ✅ Fully functional with Supabase backend
- ✅ Updated automatically on every push to main

Your app is now live and ready for users! 🚀