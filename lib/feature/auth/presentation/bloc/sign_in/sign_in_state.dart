import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

enum SignInStatus { initial, loading, success, failure }

class SignInState extends Equatable {
  final SignInStatus status;
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final String? errorMessage;
  final bool isFormValid;
  final UserEntity? user;

  const SignInState({
    this.status = SignInStatus.initial,
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.errorMessage,
    this.isFormValid = false,
    this.user,
  });

  SignInState copyWith({
    SignInStatus? status,
    String? email,
    String? password,
    String? Function()? emailError,
    String? Function()? passwordError,
    String? Function()? errorMessage,
    bool? isFormValid,
    UserEntity? Function()? user,
  }) {
    return SignInState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError != null ? emailError() : this.emailError,
      passwordError:
          passwordError != null ? passwordError() : this.passwordError,
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
        emailError,
        passwordError,
        errorMessage,
        isFormValid,
        user,
      ];
}
