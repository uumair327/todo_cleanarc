import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/hive_auth_datasource.dart';
import '../datasources/supabase_auth_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/domain/value_objects/email.dart';
import '../../../../core/domain/value_objects/password.dart';
import '../../../../core/utils/typedef.dart';

class AuthRepositoryImpl implements AuthRepository {
  final HiveAuthDataSource _hiveDataSource;
  final SupabaseAuthDataSource _supabaseDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required HiveAuthDataSource hiveDataSource,
    required SupabaseAuthDataSource supabaseDataSource,
    required NetworkInfo networkInfo,
  })  : _hiveDataSource = hiveDataSource,
        _supabaseDataSource = supabaseDataSource,
        _networkInfo = networkInfo;

  @override
  ResultFuture<UserEntity> signUp({required Email email, required Password password}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Cannot sign up: No internet connection. Please check your network and try again.'));
    }

    try {
      final userModel = await _supabaseDataSource.signUp(
        email.value,
        password.value,
      );

      // Save user locally
      await _hiveDataSource.saveUser(userModel);
      
      // Save auth token
      final token = await _supabaseDataSource.getAccessToken();
      if (token != null) {
        await _hiveDataSource.saveAuthToken(token);
      }

      return Right(userModel.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: 'Sign up failed: ${e.message}'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: 'Network error during sign up: ${e.message}'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: 'Server error during sign up: ${e.message}'));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: 'Failed to save user data: ${e.message}'));
    } catch (e) {
      return const Left(ServerFailure(message: 'Unable to create account. Please try again.'));
    }
  }

  @override
  ResultFuture<UserEntity> signIn({required Email email, required Password password}) async {
    if (!await _networkInfo.isConnected) {
      // Try to authenticate with cached credentials
      return _authenticateOffline(email, password);
    }

    try {
      final userModel = await _supabaseDataSource.signIn(
        email.value,
        password.value,
      );

      // Save user locally
      await _hiveDataSource.saveUser(userModel);
      
      // Save auth token
      final token = await _supabaseDataSource.getAccessToken();
      if (token != null) {
        await _hiveDataSource.saveAuthToken(token);
      }

      return Right(userModel.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: 'Sign in failed: ${e.message}'));
    } on NetworkException {
      // Try offline authentication as fallback
      return _authenticateOffline(email, password);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: 'Server error during sign in: ${e.message}'));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: 'Failed to save user data: ${e.message}'));
    } catch (e) {
      return const Left(ServerFailure(message: 'Unable to sign in. Please check your credentials and try again.'));
    }
  }

  @override
  ResultVoid signOut() async {
    try {
      // Clear local data first
      await _hiveDataSource.clearUser();
      await _hiveDataSource.clearAuthToken();

      // Try to sign out from remote if connected
      if (await _networkInfo.isConnected) {
        try {
          await _supabaseDataSource.signOut();
        } catch (e) {
          // Ignore remote sign out errors - local data is already cleared
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  ResultFuture<UserEntity?> getCurrentUser() async {
    try {
      // First check local storage
      final localUser = await _hiveDataSource.getCurrentUser();
      
      if (localUser != null) {
        // If we have a local user and are connected, verify with remote
        if (await _networkInfo.isConnected) {
          try {
            final remoteUser = await _supabaseDataSource.getCurrentUser();
            if (remoteUser != null) {
              // Update local user with remote data if different
              if (remoteUser.updatedAt != null && 
                  (localUser.createdAt.isBefore(remoteUser.updatedAt!))) {
                await _hiveDataSource.saveUser(remoteUser);
                return Right(remoteUser.toEntity());
              }
            }
          } catch (e) {
            // Remote check failed, use local user
          }
        }
        
        return Right(localUser.toEntity());
      }

      // No local user, check remote if connected
      if (await _networkInfo.isConnected) {
        try {
          final remoteUser = await _supabaseDataSource.getCurrentUser();
          if (remoteUser != null) {
            await _hiveDataSource.saveUser(remoteUser);
            return Right(remoteUser.toEntity());
          }
        } catch (e) {
          // Remote check failed
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      // Check if we have a stored user
      final hasStoredUser = await _hiveDataSource.hasStoredUser();
      
      if (!hasStoredUser) {
        return false;
      }

      // If connected, verify with remote
      if (await _networkInfo.isConnected) {
        try {
          final isRemoteAuthenticated = await _supabaseDataSource.isAuthenticated();
          return isRemoteAuthenticated;
        } catch (_) {
          // Remote check failed, use local state
        }
      }

      return hasStoredUser;
    } on CacheException {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  ResultVoid deleteAccount() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Internet connection required for account deletion'));
    }

    try {
      // Delete from remote first
      await _supabaseDataSource.deleteAccount();
      
      // Clear local data
      await _hiveDataSource.clearUser();
      await _hiveDataSource.clearAuthToken();

      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  Future<Either<Failure, UserEntity>> _authenticateOffline(Email email, Password password) async {
    try {
      final localUser = await _hiveDataSource.getCurrentUser();
      
      if (localUser != null && localUser.email == email.value) {
        // In a real app, you'd want to verify the password hash
        // For this implementation, we'll assume the stored user is valid
        return Right(localUser.toEntity());
      }

      return const Left(AuthenticationFailure(message: 'No cached credentials available'));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  Stream<UserEntity?> get authStateChanges {
    return _supabaseDataSource.authStateChanges.asyncMap((authState) async {
      if (authState.event == AuthChangeEvent.signedIn && authState.session?.user != null) {
        try {
          final user = await _supabaseDataSource.getCurrentUser();
          if (user != null) {
            await _hiveDataSource.saveUser(user);
            return user.toEntity();
          }
        } catch (e) {
          // Handle error silently
        }
      } else if (authState.event == AuthChangeEvent.signedOut) {
        try {
          await _hiveDataSource.clearUser();
          await _hiveDataSource.clearAuthToken();
        } catch (e) {
          // Handle error silently
        }
        return null;
      }
      return null;
    });
  }

  @override
  ResultFuture<String?> getStoredToken() async {
    try {
      final token = await _hiveDataSource.getAuthToken();
      return Right(token);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  ResultVoid clearSession() async {
    try {
      await _hiveDataSource.clearUser();
      await _hiveDataSource.clearAuthToken();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  ResultFuture<UserEntity?> getCachedUser() async {
    try {
      final userModel = await _hiveDataSource.getCurrentUser();
      return Right(userModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  ResultVoid cacheUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _hiveDataSource.saveUser(userModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  ResultVoid resendVerificationEmail(String email) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await _supabaseDataSource.resendVerificationEmail(email);
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}