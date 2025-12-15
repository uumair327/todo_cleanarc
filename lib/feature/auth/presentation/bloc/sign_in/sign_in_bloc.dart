import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/domain/value_objects/email.dart';
import '../../../../../core/domain/value_objects/password.dart';
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
      emailError = 'Email is required';
    } else if (!_isValidEmail(email)) {
      emailError = 'Please enter a valid email address';
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
      passwordError = 'Password is required';
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
          emit(state.copyWith(status: SignInStatus.success));
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