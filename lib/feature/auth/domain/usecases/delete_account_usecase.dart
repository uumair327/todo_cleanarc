import '../../../../core/utils/typedef.dart';
import '../repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository repository;

  const DeleteAccountUseCase(this.repository);

  ResultVoid call() async {
    return repository.deleteAccount();
  }
}