import '../../../../core/utils/typedef.dart';
import '../../../../core/domain/value_objects/email.dart';
import '../../../../core/domain/value_objects/password.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  const SignUpUseCase(this.repository);

  ResultFuture<UserEntity> call({
    required Email email,
    required Password password,
  }) async {
    return repository.signUp(email: email, password: password);
  }
}