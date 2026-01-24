import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import '../utils/app_colors.dart';
import 'custom_button.dart';

/// Auth navigation link row widget.
///
/// Used for "Already have an account? Sign In" and similar patterns.
class AuthLinkRow extends StatelessWidget {
  /// Message text displayed before the link
  final String message;

  /// Link text that is clickable
  final String linkText;

  /// Callback when the link is tapped
  final VoidCallback onTap;

  const AuthLinkRow({
    super.key,
    required this.message,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          TextCustomButton(
            text: linkText,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
