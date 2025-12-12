import 'package:equatable/equatable.dart';

class Email extends Equatable {
  final String value;

  const Email._(this.value);

  factory Email.fromString(String email) {
    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format: $email');
    }
    return Email._(email.toLowerCase().trim());
  }

  static bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  @override
  List<Object> get props => [value];

  @override
  String toString() => value;
}