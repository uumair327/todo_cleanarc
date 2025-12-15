# 📧 Email Verification Setup Guide

## 🚨 **Issue**: Email verification links redirect to localhost

This happens because Supabase is configured to use `localhost` as the site URL. Here's how to fix it:

## 🔧 **Step 1: Configure Supabase URLs**

### **For Development (Flutter Web)**

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard/project/szazwyplviajizapiwyc/auth/url-configuration

2. **Update Site URL:**
   ```
   Current: http://localhost:3000
   Change to: http://localhost:8080
   ```

3. **Add Redirect URLs:**
   ```
   http://localhost:8080/auth/callback
   http://localhost:8080/#/auth/callback
   ```

### **For Production**

1. **Update Site URL to your domain:**
   ```
   https://your-app-domain.com
   ```

2. **Add Production Redirect URLs:**
   ```
   https://your-app-domain.com/auth/callback
   https://your-app-domain.com/#/auth/callback
   ```

## 🔧 **Step 2: Enable Email Confirmation**

1. **Go to Authentication Settings:**
   - Visit: https://supabase.com/dashboard/project/szazwyplviajizapiwyc/auth/settings

2. **Enable Email Confirmations:**
   - Check ✅ "Enable email confirmations"
   - Set "Confirm email" to `true`

3. **Configure Email Templates (Optional):**
   - Customize the verification email template
   - Add your app branding

## 🔧 **Step 3: Test the Flow**

### **Development Testing:**

1. **Start Flutter Web:**
   ```bash
   flutter run -d chrome --web-port 8080
   ```

2. **Test Sign Up:**
   - Go to http://localhost:8080
   - Create a new account
   - Check your email for verification link
   - Click the link - it should redirect to your app

### **Expected Flow:**
1. User signs up → Email verification screen shown
2. User receives email with verification link
3. User clicks link → Redirected to `/auth/callback`
4. App verifies the session → User logged in

## 🔧 **Step 4: Handle Deep Links (Mobile)**

For mobile apps, you'll need to configure deep links:

### **Android (android/app/src/main/AndroidManifest.xml):**
```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme">
    
    <!-- Existing intent filters -->
    
    <!-- Add this for email verification -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https"
              android:host="your-app-domain.com" />
    </intent-filter>
</activity>
```

### **iOS (ios/Runner/Info.plist):**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>your-app-domain.com</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>https</string>
        </array>
    </dict>
</array>
```

## 🔧 **Step 5: Update Environment Configuration**

Update `lib/core/constants/auth_constants.dart` for your domain:

```dart
class AuthConstants {
  // Update these URLs for your app
  static const String devRedirectUrl = 'http://localhost:8080/auth/callback';
  static const String prodRedirectUrl = 'https://your-app-domain.com/auth/callback';
  
  // Add your actual domain here
  static String get redirectUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? prodRedirectUrl : devRedirectUrl;
  }
}
```

## 🧪 **Testing Checklist**

- [ ] Supabase Site URL updated
- [ ] Redirect URLs configured
- [ ] Email confirmations enabled
- [ ] Flutter web running on port 8080
- [ ] Sign up creates account
- [ ] Verification email received
- [ ] Email link redirects to app
- [ ] User gets logged in after verification
- [ ] Resend email functionality works

## 🐛 **Troubleshooting**

### **Still redirecting to localhost?**
- Clear browser cache and cookies
- Check Supabase URL configuration again
- Verify the redirect URL in the email source

### **Email not received?**
- Check spam folder
- Verify email address is correct
- Check Supabase logs for delivery issues

### **Verification link doesn't work?**
- Ensure the callback route is properly configured
- Check browser console for JavaScript errors
- Verify Supabase session handling

### **Mobile deep links not working?**
- Test deep link configuration with `adb shell am start`
- Verify URL schemes in manifest files
- Check if app is set as default handler

## 🚀 **Production Deployment**

Before going live:

1. **Update all URLs to production domain**
2. **Test email verification on staging**
3. **Configure custom SMTP (optional)**
4. **Set up monitoring for auth failures**
5. **Test mobile deep links thoroughly**

## 📱 **Quick Fix for Current Issue**

**Immediate solution for development:**

1. Change Supabase Site URL to: `http://localhost:8080`
2. Add redirect URL: `http://localhost:8080/auth/callback`
3. Run Flutter web: `flutter run -d chrome --web-port 8080`
4. Test sign up flow

This should fix the localhost redirect issue immediately!