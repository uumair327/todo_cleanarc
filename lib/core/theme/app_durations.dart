class AppDurations {
  // Animations
  static const Duration animShort = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 300);
  static const Duration animLong = Duration(milliseconds: 500);

  // Inputs & Interaction
  static const Duration debounce = Duration(milliseconds: 500);
  static const Duration snackBar = Duration(seconds: 4);
  static const Duration snackBarShort = Duration(seconds: 2);

  // Network & Async
  static const Duration retryBase = Duration(seconds: 2);
  static const Duration retryMax = Duration(seconds: 30);
  static const Duration simulatedNetworkDelay = Duration(seconds: 1);

  // Cache & Storage
  static const Duration cacheQuick = Duration(minutes: 1);
  static const Duration cacheShort = Duration(minutes: 2);
  static const Duration cacheMedium = Duration(minutes: 5);
  static const Duration cacheLong = Duration(minutes: 30);
  static const Duration cacheCleanup = Duration(minutes: 5);

  // Date Logic
  static const Duration oneDay = Duration(days: 1);
  static const Duration recentPeriod = Duration(days: 30);

  // Extended Timeouts & Intervals
  static const Duration monitorInterval = Duration(seconds: 1);
  static const Duration retryQuick = Duration(seconds: 1);
  static const Duration timeoutLong = Duration(seconds: 30);
  static const Duration timeoutMedium = Duration(minutes: 15);
}
