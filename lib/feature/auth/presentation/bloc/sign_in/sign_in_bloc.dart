import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/domain/value_objects/email.dart';
import '../../../../../core/domain/value_objects/password.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../domain/usecases/sign_in_usecase.dart';
import 'sign_in_event.dart';
import 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final SignInUseCase _signInUseCase;

  SignInBloc({
    required SignInUseCase signInUseCase,
  })  : _signInUseCase = signInUseCase,
        super(const SignInState()) {
    on<SignInEmailChanged>(_onEmailChanged);
    on<SignInPasswordChanged>(_onPasswordChanged);
    on<SignInSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(
    SignInEmailChanged event,
    Emitter<SignInState> emit,
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
    SignInPasswordChanged event,
    Emitter<SignInState> emit,
  ) {
    final password = event.password;
    String? passwordError;

    // Validate password
    if (password.isEmpty) {
      passwordError = AppStrings.passwordRequired;
    }

    final newState = state.copyWith(
      password: password,
      passwordError: () => passwordError,
    );

    emit(newState.copyWith(isFormValid: _isFormValid(newState)));
  }

  Future<void> _onSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    if (!state.isFormValid) {
<<<<<<< HEAD
      // Debug: show why form is invalid
      print(
          'SignIn: Form not valid - email: "${state.email}", password length: ${state.password.length}');
      print(
          'SignIn: emailError: ${state.emailError}, passwordError: ${state.passwordError}');
=======
>>>>>>> 35c26355e54afe6023cde3a873a421d55c0cd6c3
      return;
    }

    emit(state.copyWith(status: SignInStatus.loading));

    try {
      final email = Email.fromString(state.email);
      final password = Password.fromString(state.password);

      final result = await _signInUseCase(
        email: email,
        password: password,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            status: SignInStatus.failure,
            errorMessage: () => _getFailureMessage(failure),
          ));
        },
        (user) {
<<<<<<< HEAD
          print('SignIn: Success!');
          emit(state.copyWith(
            status: SignInStatus.success,
            user: () => user,
          ));
=======
          emit(state.copyWith(status: SignInStatus.success));
>>>>>>> 35c26355e54afe6023cde3a873a421d55c0cd6c3
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: SignInStatus.failure,
        errorMessage: () => e.toString(),
      ));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isFormValid(SignInState state) {
    return state.email.isNotEmpty &&
        state.password.isNotEmpty &&
        state.emailError == null &&
        state.passwordError == null;
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
