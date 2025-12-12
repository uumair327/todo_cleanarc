import '../../../../core/utils/typedef.dart';
import '../entities/user_entity.dart';
import '../../../../core/domain/value_objects/email.dart';
import '../../../../core/domain/value_objects/password.dart';

abstract class AuthRepository {
  // Authentication operations
  ResultFuture<UserEntity> signUp({
    required Email email,
    required Password password,
  });
  
  ResultFuture<UserEntity> signIn({
    required Email email,
    required Password password,
  });
  
  ResultVoid signOut();
  
  // Session management
  ResultFuture<UserEntity?> getCurrentUser();
  
  Future<bool> isAuthenticated();
  
  ResultFuture<String?> getStoredToken();
  
  ResultVoid clearSession();
  
  // Offline operations
  ResultFuture<UserEntity?> getCachedUser();
  
  ResultVoid cacheUser(UserEntity user);
  
  // Account management
  ResultVoid deleteAccount();
}