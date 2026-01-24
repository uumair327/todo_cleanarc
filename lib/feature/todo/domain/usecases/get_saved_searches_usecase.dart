import '../../../../core/utils/typedef.dart';
import '../entities/saved_search.dart';
import '../repositories/search_repository.dart';

class GetSavedSearchesUseCase {
  final SearchRepository repository;

  const GetSavedSearchesUseCase(this.repository);

  ResultFuture<List<SavedSearch>> call() {
    return repository.getSavedSearches();
  }
}
