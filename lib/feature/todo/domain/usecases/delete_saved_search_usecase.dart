import '../../../../core/utils/typedef.dart';
import '../repositories/search_repository.dart';

class DeleteSavedSearchUseCase {
  final SearchRepository repository;

  const DeleteSavedSearchUseCase(this.repository);

  ResultVoid call(String id) {
    return repository.deleteSavedSearch(id);
  }
}
