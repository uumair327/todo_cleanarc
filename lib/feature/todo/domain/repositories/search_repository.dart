import '../../../../core/utils/typedef.dart';
import '../entities/saved_search.dart';
import '../entities/search_history_entry.dart';

abstract class SearchRepository {
  // Search History
  ResultFuture<List<SearchHistoryEntry>> getSearchHistory({int limit = 10});
  ResultVoid addSearchHistory(String query);
  ResultVoid clearSearchHistory();
  ResultVoid deleteSearchHistoryEntry(String id);

  // Saved Searches
  ResultFuture<List<SavedSearch>> getSavedSearches();
  ResultFuture<SavedSearch?> getSavedSearchById(String id);
  ResultVoid saveSavedSearch(SavedSearch savedSearch);
  ResultVoid updateSavedSearch(SavedSearch savedSearch);
  ResultVoid deleteSavedSearch(String id);
}
