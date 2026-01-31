import '../theme/app_durations.dart';

class AuthConstants {
  // Email redirect URLs for different environments
  static const String devRedirectUrl = 'http://localhost:8080/auth/callback';
  static const String githubPagesUrl =
      'https://YOUR_GITHUB_USERNAME.github.io/glimfo-todo/auth/callback';
  static const String prodRedirectUrl =
      'https://your-app-domain.com/auth/callback';

  // Get the appropriate redirect URL based on environment
  static String get redirectUrl {
    // Check if running on GitHub Pages
    const String githubPages = String.fromEnvironment('GITHUB_PAGES');
    if (githubPages == 'true') {
      return githubPagesUrl;
    }

    // Check for production build.
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? prodRedirectUrl : devRedirectUrl;
  }

  // Email verification settings
  static const Duration emailVerificationTimeout = AppDurations.timeoutMedium;
  static const int maxResendAttempts = 3;

  // Password requirements
  static const int minPasswordLength = 8;
  static const bool requireUppercase = true;
  static const bool requireNumbers = true;
  static const bool requireSpecialChars = true;
}
