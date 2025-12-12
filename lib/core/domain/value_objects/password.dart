import 'package:equatable/equatable.dart';

class Password extends Equatable {
  final String value;

  const Password._(this.value);

  factory Password.fromString(String password) {
    if (!_isValidPassword(password)) {
      throw ArgumentError('Password must be at least 8 characters long');
    }
    return Password._(password);
  }

  static bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  @override
  List<Object> get props => [value];

  @override
  String toString() => '***'; // Never expose password in toString
}