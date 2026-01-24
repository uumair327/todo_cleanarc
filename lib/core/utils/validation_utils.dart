/// Validation utilities for form inputs
/// Provides comprehensive validation with user-friendly error messages
class ValidationUtils {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    final trimmedValue = value.trim();

    // Check for basic email format
    if (!trimmedValue.contains('@')) {
      return 'Email must contain @ symbol';
    }

    // Check for valid email pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address';
    }

    // Check for common typos
    if (trimmedValue.endsWith('.con') || trimmedValue.endsWith('.cmo')) {
      return 'Did you mean .com?';
    }

    if (trimmedValue.contains('..')) {
      return 'Email cannot contain consecutive dots';
    }

    if (trimmedValue.startsWith('.') || trimmedValue.endsWith('.')) {
      return 'Email cannot start or end with a dot';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (value.length > 128) {
      return 'Password is too long (max 128 characters)';
    }

    // Check for whitespace
    if (value.contains(' ')) {
      return 'Password cannot contain spaces';
    }

    // Check for at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  // Password confirmation validation
  static String? validatePasswordConfirmation(
    String? value,
    String? password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  // Text length validation
  static String? validateLength(
    String? value, {
    int? minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Use validateRequired for required fields
    }

    final trimmedValue = value.trim();
    final field = fieldName ?? 'This field';

    if (minLength != null && trimmedValue.length < minLength) {
      return '$field must be at least $minLength characters';
    }

    if (maxLength != null && trimmedValue.length > maxLength) {
      return '$field must not exceed $maxLength characters';
    }

    return null;
  }

  // Task title validation
  static String? validateTaskTitle(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Task title');
    if (requiredError != null) return requiredError;

    final lengthError = validateLength(
      value,
      minLength: 3,
      maxLength: 100,
      fieldName: 'Task title',
    );
    if (lengthError != null) return lengthError;

    // Check for only whitespace
    if (value!.trim().isEmpty) {
      return 'Task title cannot be only whitespace';
    }

    // Check for special characters at start
    if (RegExp(r'^[^a-zA-Z0-9]').hasMatch(value.trim())) {
      return 'Task title should start with a letter or number';
    }

    return null;
  }

  // Task description validation
  static String? validateTaskDescription(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Description');
    if (requiredError != null) return requiredError;

    final lengthError = validateLength(
      value,
      minLength: 10,
      maxLength: 500,
      fieldName: 'Description',
    );
    if (lengthError != null) return lengthError;

    // Check for only whitespace
    if (value!.trim().isEmpty) {
      return 'Description cannot be only whitespace';
    }

    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value, {String? fieldName}) {
    if (value == null) {
      return '${fieldName ?? 'Date'} is required';
    }

    // Check if date is too far in the past
    final now = DateTime.now();
    final minDate = DateTime(now.year - 1);
    if (value.isBefore(minDate)) {
      return '${fieldName ?? 'Date'} cannot be more than 1 year in the past';
    }

    // Check if date is too far in the future
    final maxDate = DateTime(now.year + 10);
    if (value.isAfter(maxDate)) {
      return '${fieldName ?? 'Date'} cannot be more than 10 years in the future';
    }

    return null;
  }

  // Due date validation (should not be in the past)
  static String? validateDueDate(DateTime? value) {
    if (value == null) {
      return 'Due date is required';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(value.year, value.month, value.day);

    if (dueDate.isBefore(today)) {
      return 'Due date cannot be in the past';
    }

    // Check if date is too far in the future
    final maxDate = DateTime(now.year + 5);
    if (value.isAfter(maxDate)) {
      return 'Due date cannot be more than 5 years in the future';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove common formatting characters
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it contains only digits and optional + at start
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Number validation
  static String? validateNumber(
    String? value, {
    num? min,
    num? max,
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    final number = num.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (min != null && number < min) {
      return '${fieldName ?? 'Value'} must be at least $min';
    }

    if (max != null && number > max) {
      return '${fieldName ?? 'Value'} must not exceed $max';
    }

    return null;
  }

  // Percentage validation
  static String? validatePercentage(String? value) {
    return validateNumber(
      value,
      min: 0,
      max: 100,
      fieldName: 'Percentage',
    );
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (trimmedValue.length > 20) {
      return 'Username must not exceed 20 characters';
    }

    // Check for valid characters (alphanumeric, underscore, hyphen)
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(trimmedValue)) {
      return 'Username can only contain letters, numbers, _ and -';
    }

    // Check if starts with letter
    if (!RegExp(r'^[a-zA-Z]').hasMatch(trimmedValue)) {
      return 'Username must start with a letter';
    }

    return null;
  }

  // Combine multiple validators
  static String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

/// Password strength indicator
enum PasswordStrength {
  weak,
  fair,
  good,
  strong,
  veryStrong,
}

class PasswordStrengthChecker {
  static PasswordStrength checkStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;

    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    // Return strength based on score
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.fair;
    if (score <= 5) return PasswordStrength.good;
    if (score <= 6) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  static String getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  static double getStrengthValue(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 0.2;
      case PasswordStrength.fair:
        return 0.4;
      case PasswordStrength.good:
        return 0.6;
      case PasswordStrength.strong:
        return 0.8;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }
}
