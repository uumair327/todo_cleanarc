import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/sign_out_usecase.dart';
import '../../../domain/usecases/delete_account_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;
  final SignOutUseCase _signOutUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  ProfileBloc({
    required AuthRepository authRepository,
    required SignOutUseCase signOutUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
  })  : _authRepository = authRepository,
        _signOutUseCase = signOutUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileLogoutRequested>(_onProfileLogoutRequested);
    on<ProfileDeleteAccountRequested>(_onProfileDeleteAccountRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    
    try {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) => emit(ProfileError(_getFailureMessage(failure))),
        (user) {
          if (user != null) {
            emit(ProfileLoaded(user));
          } else {
            emit(const ProfileError('No user found'));
          }
        },
      );
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onProfileRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Don't show loading for refresh, just update the data
    try {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) => emit(ProfileError(_getFailureMessage(failure))),
        (user) {
          if (user != null) {
            emit(ProfileLoaded(user));
          } else {
            emit(const ProfileError('No user found'));
          }
        },
      );
    } catch (e) {
      emit(ProfileError('Failed to refresh profile: $e'));
    }
  }

  Future<void> _onProfileLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    
    try {
      final result = await _signOutUseCase();
      result.fold(
        (failure) => emit(ProfileError(_getFailureMessage(failure))),
        (_) => emit(const ProfileLogoutSuccess()),
      );
    } catch (e) {
      emit(ProfileError('Failed to logout: $e'));
    }
  }

  Future<void> _onProfileDeleteAccountRequested(
    ProfileDeleteAccountRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    
    try {
      final result = await _deleteAccountUseCase();
      result.fold(
        (failure) => emit(ProfileError(_getFailureMessage(failure))),
        (_) => emit(const ProfileDeleteAccountSuccess()),
      );
    } catch (e) {
      emit(ProfileError('Failed to delete account: $e'));
    }
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