import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

enum SignUpStatus { initial, loading, success, failure }

class SignUpState extends Equatable {
  final SignUpStatus status;
  final String email;
  final String password;
  final String confirmPassword;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? errorMessage;
  final bool isFormValid;
  final UserEntity? user;

  const SignUpState({
    this.status = SignUpStatus.initial,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.errorMessage,
    this.isFormValid = false,
    this.user,
  });

  SignUpState copyWith({
    SignUpStatus? status,
    String? email,
    String? password,
    String? confirmPassword,
    String? Function()? emailError,
    String? Function()? passwordError,
    String? Function()? confirmPasswordError,
    String? Function()? errorMessage,
    bool? isFormValid,
    UserEntity? Function()? user,
  }) {
    return SignUpState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      emailError: emailError != null ? emailError() : this.emailError,
      passwordError:
          passwordError != null ? passwordError() : this.passwordError,
      confirmPasswordError: confirmPasswordError != null
          ? confirmPasswordError()
          : this.confirmPasswordError,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isFormValid: isFormValid ?? this.isFormValid,
      user: user != null ? user() : this.user,
    );
  }

  @override
  List<Object?> get props => [
        status,
        email,
        password,
        confirmPassword,
        emailError,
        passwordError,
        confirmPasswordError,
        errorMessage,
        isFormValid,
        user,
      ];
}
