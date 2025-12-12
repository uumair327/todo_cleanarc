import '../../../../core/utils/typedef.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  const SignOutUseCase(this.repository);

  ResultVoid call() async {
    return repository.signOut();
  }
}