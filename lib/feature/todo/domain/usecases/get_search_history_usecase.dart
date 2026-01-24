import '../../../../core/utils/typedef.dart';
import '../entities/search_history_entry.dart';
import '../repositories/search_repository.dart';

class GetSearchHistoryUseCase {
  final SearchRepository repository;

  const GetSearchHistoryUseCase(this.repository);

  ResultFuture<List<SearchHistoryEntry>> call({int limit = 10}) {
    return repository.getSearchHistory(limit: limit);
  }
}
