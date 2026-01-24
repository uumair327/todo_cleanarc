import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/domain/value_objects/email.dart';
import '../../../../../core/domain/value_objects/password.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/validation_utils.dart';
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
    final emailError = ValidationUtils.validateEmail(email);

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
    final passwordError = ValidationUtils.validatePassword(password, minLength: 6);

    // Re-validate confirm password with the new password
    final confirmPasswordError = state.confirmPassword.isNotEmpty
        ? ValidationUtils.validatePasswordConfirmation(
            state.confirmPassword,
            password,
          )
        : null;

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
    final confirmPasswordError = ValidationUtils.validatePasswordConfirmation(
      confirmPassword,
      state.password,
    );

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
      final email = Email.fromString(state.email);
      final password = Password.fromString(state.password);

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
          emit(state.copyWith(
            status: SignUpStatus.success,
            user: () => user,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: () => e.toString(),
      ));
    }
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
