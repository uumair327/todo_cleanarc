import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../utils/app_colors.dart';

/// A reusable form field widget with a label, following Single Responsibility Principle.
///
/// Provides consistent styling and behavior for form inputs across the app,
/// supporting email, password, and general text input types.
class LabeledFormField extends StatefulWidget {
  /// The label text displayed above the field
  final String label;

  /// Hint text displayed inside the field when empty
  final String? hint;

  /// Error text to display below the field
  final String? errorText;

  /// Optional controller for the text field
  final TextEditingController? controller;

  /// Callback fired when the text changes
  final ValueChanged<String>? onChanged;

  /// Callback fired when the field is submitted
  final ValueChanged<String>? onSubmitted;

  /// Whether to obscure the text (for passwords)
  final bool obscureText;

  /// Whether the password visibility can be toggled
  final bool enableVisibilityToggle;

  /// Icon displayed at the start of the field
  final IconData? prefixIcon;

  /// Custom suffix widget
  final Widget? suffix;

  /// Keyboard type for the field
  final TextInputType keyboardType;

  /// Text input action for the keyboard
  final TextInputAction textInputAction;

  /// Maximum lines for the text field
  final int maxLines;

  /// Validator function for form validation
  final String? Function(String?)? validator;

  /// Whether the field is enabled
  final bool enabled;

  const LabeledFormField({
    super.key,
    required this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enableVisibilityToggle = false,
    this.prefixIcon,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.validator,
    this.enabled = true,
  });

  @override
  State<LabeledFormField> createState() => _LabeledFormFieldState();
}

class _LabeledFormFieldState extends State<LabeledFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      style: AppTypography.bodyMedium.copyWith(
        color: widget.enabled ? AppColors.textPrimary : AppColors.textDisabled,
      ),
      decoration: InputDecoration(
        label: _buildLabel(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: widget.hint,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: _buildSuffixIcon(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: BorderSide(
            color: widget.errorText != null
                ? AppColors.error
                : AppColors.textDisabled,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: BorderSide(
            color: widget.errorText != null
                ? AppColors.error
                : AppColors.textSecondary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }

  Widget _buildLabel() {
    if (widget.label.contains('*')) {
      final parts = widget.label.split('*');
      return RichText(
        text: TextSpan(
          text: parts[0],
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: '*',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            if (parts.length > 1)
              TextSpan(
                text: parts.sublist(1).join('*'),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      );
    }

    return Text(
      widget.label,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffix != null) {
      return widget.suffix;
    }

    if (widget.enableVisibilityToggle && widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return null;
  }
}

/// Specialized form field for email input
class EmailFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const EmailFormField({
    super.key,
    this.controller,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return LabeledFormField(
      label: 'Email',
      hint: 'Enter your email',
      errorText: errorText,
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
    );
  }
}

/// Specialized form field for password input with visibility toggle
class PasswordFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;

  const PasswordFormField({
    super.key,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.controller,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
  });

  @override
  Widget build(BuildContext context) {
    return LabeledFormField(
      label: label,
      hint: hint,
      errorText: errorText,
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      obscureText: true,
      enableVisibilityToggle: true,
      prefixIcon: Icons.lock_outlined,
      textInputAction: textInputAction,
    );
  }
}
