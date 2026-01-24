import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../utils/validation_utils.dart';

/// Widget that displays password strength with visual feedback
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showText;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = PasswordStrengthChecker.checkStrength(password);
    final strengthValue = PasswordStrengthChecker.getStrengthValue(strength);
    final strengthText = PasswordStrengthChecker.getStrengthText(strength);
    final color = _getStrengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strengthValue,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ),
            if (showText) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                strengthText,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        if (strength == PasswordStrength.weak ||
            strength == PasswordStrength.fair) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _getStrengthHint(strength),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.fair:
        return Colors.orange;
      case PasswordStrength.good:
        return Colors.yellow.shade700;
      case PasswordStrength.strong:
        return Colors.lightGreen;
      case PasswordStrength.veryStrong:
        return Colors.green;
    }
  }

  String _getStrengthHint(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Add uppercase, numbers, and special characters';
      case PasswordStrength.fair:
        return 'Add more characters and variety';
      default:
        return '';
    }
  }
}

/// Widget showing password requirements checklist
class PasswordRequirementsChecklist extends StatelessWidget {
  final String password;

  const PasswordRequirementsChecklist({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Password requirements:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildRequirement(
            'At least 8 characters',
            password.length >= 8,
          ),
          _buildRequirement(
            'Contains uppercase letter',
            RegExp(r'[A-Z]').hasMatch(password),
          ),
          _buildRequirement(
            'Contains lowercase letter',
            RegExp(r'[a-z]').hasMatch(password),
          ),
          _buildRequirement(
            'Contains number',
            RegExp(r'[0-9]').hasMatch(password),
          ),
          _buildRequirement(
            'Contains special character',
            RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: met ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: met ? Colors.green.shade700 : Colors.grey.shade600,
              decoration: met ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}
