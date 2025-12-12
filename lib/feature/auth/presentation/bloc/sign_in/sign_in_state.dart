import 'package:equatable/equatable.dart';

enum SignInStatus { initial, loading, success, failure }

class SignInState extends Equatable {
  final SignInStatus status;
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final String? errorMessage;
  final bool isFormValid;

  const SignInState({
    this.status = SignInStatus.initial,
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.errorMessage,
    this.isFormValid = false,
  });

  SignInState copyWith({
    SignInStatus? status,
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    String? errorMessage,
    bool? isFormValid,
  }) {
    return SignInState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError,
      passwordError: passwordError,
      errorMessage: errorMessage,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  @override
  List<Object?> get props => [
        status,
        email,
        password,
        emailError,
        passwordError,
        errorMessage,
        isFormValid,
      ];
}