import 'package:flutter/material.dart';

class AppColors {
  // Category colors as specified in requirements
  static const Color ongoing = Colors.blue;
  static const Color inProcess = Colors.yellow;
  static const Color completed = Colors.green;
  static const Color canceled = Colors.red;
  
  // Common colors
  static const Color primary = Colors.blue;
  static const Color secondary = Colors.blueAccent;
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Colors.red;
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
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
}