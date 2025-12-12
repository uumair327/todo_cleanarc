import 'package:flutter/material.dart';

class AppColors {
  // Category colors as specified in requirements (8.3)
  static const Color ongoing = Color(0xFF2196F3); // Blue
  static const Color inProcess = Color(0xFFFFC107); // Yellow
  static const Color completed = Color(0xFF4CAF50); // Green
  static const Color canceled = Color(0xFFF44336); // Red
  
  // Category light variants for backgrounds
  static const Color ongoingLight = Color(0xFFE3F2FD);
  static const Color inProcessLight = Color(0xFFFFF8E1);
  static const Color completedLight = Color(0xFFE8F5E8);
  static const Color canceledLight = Color(0xFFFFEBEE);
  
  // Primary theme colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryDark = Color(0xFF018786);
  
  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFAFAFA);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Border and divider colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  
  // Shadow colors
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0A000000);
  
  /// Get category color based on category name
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ongoing':
        return ongoing;
      case 'in_process':
      case 'inprocess':
        return inProcess;
      case 'completed':
        return completed;
      case 'canceled':
        return canceled;
      default:
        return ongoing;
    }
  }
  
  /// Get category light color for backgrounds
  static Color getCategoryLightColor(String category) {
    switch (category.toLowerCase()) {
      case 'ongoing':
        return ongoingLight;
      case 'in_process':
      case 'inprocess':
        return inProcessLight;
      case 'completed':
        return completedLight;
      case 'canceled':
        return canceledLight;
      default:
        return ongoingLight;
    }
  }
}