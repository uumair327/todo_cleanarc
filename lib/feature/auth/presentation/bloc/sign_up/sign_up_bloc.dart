import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/domain/value_objects/email.dart';
import '../../../../../core/domain/value_objects/password.dart';
import '../../../../../core/constants/app_strings.dart';
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
      emailError = AppStrings.emailRequired;
    } else if (!_isValidEmail(email)) {
      emailError = AppStrings.emailInvalid;
    }

    final newState = state.copyWith(
      email: email,
      emailError: () => emailError,
    );

    emit(newState.copyWith(isFormValid: _isFormValid(newState)));
  }

  void _onPasswordChanged(
    SignUpPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    final password = event.password;
    String? passwordError;

    // Validate password (Supabase minimum is 6 characters)
    if (password.isEmpty) {
      passwordError = AppStrings.passwordRequired;
    } else if (password.length < 6) {
      passwordError = AppStrings.passwordTooShort;
    }

    // Re-validate confirm password with the new password
    String? confirmPasswordError;
    if (state.confirmPassword.isNotEmpty && state.confirmPassword != password) {
      confirmPasswordError = AppStrings.passwordsDoNotMatch;
    }

    emit(state.copyWith(
      password: password,
      passwordError: () => passwordError,
      confirmPasswordError: () => confirmPasswordError,
      isFormValid: _isFormValid(SignUpState(
        email: state.email,
        password: password,
        confirmPassword: state.confirmPassword,
        emailError: state.emailError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
      )),
    ));
  }

  void _onConfirmPasswordChanged(
    SignUpConfirmPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    final confirmPassword = event.confirmPassword;
    String? confirmPasswordError;

    // Validate confirm password
    if (confirmPassword.isEmpty) {
      confirmPasswordError = AppStrings.confirmPasswordHint;
    } else if (confirmPassword != state.password) {
      confirmPasswordError = AppStrings.passwordsDoNotMatch;
<<<<<<< HEAD
      // Debug: Print to see what's happening
      print(
          'Password mismatch: password="${state.password}" (${state.password.length}), confirm="$confirmPassword" (${confirmPassword.length})');
    } else {
      print(
          'Passwords match: password="${state.password}", confirm="$confirmPassword"');
=======
>>>>>>> 35c26355e54afe6023cde3a873a421d55c0cd6c3
    }

    emit(state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: () => confirmPasswordError,
      isFormValid: _isFormValid(SignUpState(
        email: state.email,
        password: state.password,
        confirmPassword: confirmPassword,
        emailError: state.emailError,
        passwordError: state.passwordError,
        confirmPasswordError: confirmPasswordError,
      )),
    ));
  }

  Future<void> _onSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    if (!state.isFormValid) return;

    emit(state.copyWith(status: SignUpStatus.loading));

    try {
<<<<<<< HEAD
      print(
          'SignUp: email="${state.email}", password="${state.password}" (${state.password.length} chars)');

      final email = Email.fromString(state.email);
      final password = Password.fromString(state.password);

      print(
          'SignUp: Calling use case with email=${email.value}, password length=${password.value.length}');

=======
      final email = Email.fromString(state.email);
      final password = Password.fromString(state.password);

>>>>>>> 35c26355e54afe6023cde3a873a421d55c0cd6c3
      final result = await _signUpUseCase(
        email: email,
        password: password,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            status: SignUpStatus.failure,
            errorMessage: () => _getFailureMessage(failure),
          ));
        },
        (user) {
<<<<<<< HEAD
          print('SignUp success!');
          emit(state.copyWith(
            status: SignUpStatus.success,
            user: () => user,
          ));
=======
          emit(state.copyWith(status: SignUpStatus.success));
>>>>>>> 35c26355e54afe6023cde3a873a421d55c0cd6c3
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: () => e.toString(),
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
    } else if (failure.runtimeType
        .toString()
        .contains('AuthenticationFailure')) {
      return (failure as dynamic).message;
    } else if (failure.runtimeType.toString().contains('NetworkFailure')) {
      return (failure as dynamic).message;
    } else if (failure.runtimeType.toString().contains('CacheFailure')) {
      return (failure as dynamic).message;
    }
    return AppStrings.unexpectedError;
  }
}
