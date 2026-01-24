import '../../../../core/utils/typedef.dart';
import '../repositories/search_repository.dart';

class AddSearchHistoryUseCase {
  final SearchRepository repository;

  const AddSearchHistoryUseCase(this.repository);

  ResultVoid call(String query) {
    return repository.addSearchHistory(query);
  }
}
