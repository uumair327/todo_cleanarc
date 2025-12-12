import '../../../../core/utils/typedef.dart';
import '../../../../core/domain/value_objects/email.dart';
import '../../../../core/domain/value_objects/password.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  const SignInUseCase(this.repository);

  ResultFuture<UserEntity> call({
    required Email email,
    required Password password,
  }) async {
    return repository.signIn(email: email, password: password);
  }
}