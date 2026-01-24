import '../models/saved_search_model.dart';
import '../models/search_history_model.dart';

abstract class SearchDataSource {
  // Search History
  Future<List<SearchHistoryModel>> getSearchHistory({int limit = 10});
  Future<void> addSearchHistory(SearchHistoryModel entry);
  Future<void> clearSearchHistory();
  Future<void> deleteSearchHistoryEntry(String id);

  // Saved Searches
  Future<List<SavedSearchModel>> getSavedSearches();
  Future<SavedSearchModel?> getSavedSearchById(String id);
  Future<void> saveSavedSearch(SavedSearchModel savedSearch);
  Future<void> updateSavedSearch(SavedSearchModel savedSearch);
  Future<void> deleteSavedSearch(String id);
}
