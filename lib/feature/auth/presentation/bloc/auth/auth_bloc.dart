import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/sign_out_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SignOutUseCase _signOutUseCase;

  AuthBloc({
    required AuthRepository authRepository,
    required SignOutUseCase signOutUseCase,
  })  : _authRepository = authRepository,
        _signOutUseCase = signOutUseCase,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) => emit(const AuthUnauthenticated()),
        (user) {
          if (user != null) {
            emit(AuthAuthenticated(user));
          } else {
            emit(const AuthUnauthenticated());
          }
        },
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await _signOutUseCase();
      result.fold(
        (failure) => emit(AuthError(_getFailureMessage(failure))),
        (_) => emit(const AuthUnauthenticated()),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      final stateType = json['type'] as String?;

      switch (stateType) {
        case 'authenticated':
          // For security reasons, we don't persist user data
          // Instead, we'll check authentication status on app start
          return const AuthUnauthenticated();
        case 'unauthenticated':
          return const AuthUnauthenticated();
        default:
          return const AuthInitial();
      }
    } catch (e) {
      return const AuthInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    try {
      if (state is AuthAuthenticated) {
        return {'type': 'authenticated'};
      } else if (state is AuthUnauthenticated) {
        return {'type': 'unauthenticated'};
      }
      return null;
    } catch (e) {
      return null;
    }
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
    return 'An unexpected error occurred';
  }
}
