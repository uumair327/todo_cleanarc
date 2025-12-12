import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/domain/value_objects/email.dart';
import '../../../../../core/domain/value_objects/password.dart';
import '../../../domain/usecases/sign_up_usecase.dart';
import 'sign_up_event.dart';
import 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpUseCase _signUpUseCase;

  SignUpBloc({
    required SignUpUseCase signUpUseCase,
  })  : _signUpUseCase = signUpUseCase,
        super(const SignUpState()) {
    on<SignUpEmailChanged>(_onEmailChanged);
    on<SignUpPasswordChanged>(_onPasswordChanged);
    on<SignUpConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SignUpSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(
    SignUpEmailChanged event,
    Emitter<SignUpState> emit,
  ) {
    final email = event.email;
    String? emailError;

    // Validate email format
    if (email.isEmpty) {
      emailError = 'Email is required';
    } else if (!_isValidEmail(email)) {
      emailError = 'Please enter a valid email address';
    }

    final newState = state.copyWith(
      email: email,
      emailError: emailError,
    );

    emit(newState.copyWith(isFormValid: _isFormValid(newState)));
  }

  void _onPasswordChanged(
    SignUpPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    final password = event.password;
    String? passwordError;

    // Validate password
    if (password.isEmpty) {
      passwordError = 'Password is required';
    } else if (password.length < 8) {
      passwordError = 'Password must be at least 8 characters long';
    }

    // Check if confirm password still matches
    String? confirmPasswordError = state.confirmPasswordError;
    if (state.confirmPassword.isNotEmpty && state.confirmPassword != password) {
      confirmPasswordError = 'Passwords do not match';
    } else if (state.confirmPassword.isNotEmpty && state.confirmPassword == password) {
      confirmPasswordError = null;
    }

    final newState = state.copyWith(
      password: password,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
    );

    emit(newState.copyWith(isFormValid: _isFormValid(newState)));
  }

  void _onConfirmPasswordChanged(
    SignUpConfirmPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    final confirmPassword = event.confirmPassword;
    String? confirmPasswordError;

    // Validate confirm password
    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'Please confirm your password';
    } else if (confirmPassword != state.password) {
      confirmPasswordError = 'Passwords do not match';
    }

    final newState = state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: confirmPasswordError,
    );

    emit(newState.copyWith(isFormValid: _isFormValid(newState)));
  }

  Future<void> _onSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    if (!state.isFormValid) return;

    emit(state.copyWith(status: SignUpStatus.loading));

    try {
      final email = Email.fromString(state.email);
      final password = Password.fromString(state.password);

      final result = await _signUpUseCase(
        email: email,
        password: password,
      );

      result.fold(
        (failure) => emit(state.copyWith(
          status: SignUpStatus.failure,
          errorMessage: _getFailureMessage(failure),
        )),
        (user) => emit(state.copyWith(status: SignUpStatus.success)),
      );
    } catch (e) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isFormValid(SignUpState state) {
    return state.email.isNotEmpty &&
        state.password.isNotEmpty &&
        state.confirmPassword.isNotEmpty &&
        state.emailError == null &&
        state.passwordError == null &&
        state.confirmPasswordError == null;
  }

  String _getFailureMessage(dynamic failure) {
    if (failure.runtimeType.toString().contains('ServerFailure')) {
      return (failure as dynamic).message;
    } else if (failure.runtimeType.toString().contains('AuthenticationFailure')) {
      return (failure as dynamic).message;
    } else if (failure.runtimeType.toString().contains('NetworkFailure')) {
      return (failure as dynamic).message;
    } else if (failure.runtimeType.toString().contains('CacheFailure')) {
      return (failure as dynamic).message;
    }
    return 'An unexpected error occurred';
  }
}