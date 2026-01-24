class AppSpacing {
  // Base spacing unit
  static const double base = 8.0;

  // Spacing values
  static const double xxs = base * 0.25; // 2.0
  static const double xs = base * 0.5; // 4.0
  static const double sm = base; // 8.0
  static const double mdSm = base * 1.5; // 12.0 - between sm and md
  static const double md = base * 2; // 16.0
  static const double mdLg = base * 2.5; // 20.0 - between md and lg
  static const double lg = base * 3; // 24.0
  static const double xl = base * 4; // 32.0
  static const double xxl = base * 6; // 48.0
  static const double xxxl = base * 8; // 64.0

  // Specific spacing for common use cases
  static const double cardPadding = md; // 16.0
  static const double screenPadding = md; // 16.0
  static const double sectionSpacing = lg; // 24.0
  static const double itemSpacing = sm; // 8.0
  static const double buttonSpacing = md; // 16.0
  static const double dialogPadding = mdSm; // 12.0
  static const double formFieldSpacing = mdLg; // 20.0
}

class AppDimensions {
  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusRound = 50.0;

  // Common dimensions
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double inputHeight = 48.0;
  static const double cardElevation = 2.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 60.0;
  static const double fabSize = 56.0;
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeXSmall = 12.0;
  static const double iconSizeLarge = 32.0;

  // Task card specific dimensions
  static const double taskCardHeight = 120.0;
  static const double taskCardMinHeight = 80.0;
  static const double progressBarHeight = 4.0;
  static const double categoryChipHeight = 28.0;

  // Avatar & Icon Container sizes
  static const double avatarSizeSmall = 40.0;
  static const double avatarSizeMedium = 60.0;
  static const double avatarSizeLarge = 80.0;
}
