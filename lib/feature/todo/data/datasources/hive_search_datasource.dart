import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/saved_search_model.dart';
import '../models/search_history_model.dart';
import 'search_datasource.dart';

class HiveSearchDataSource implements SearchDataSource {
  static const String _searchHistoryBoxName = 'search_history';
  static const String _savedSearchesBoxName = 'saved_searches';

  Future<Box<SearchHistoryModel>> get _searchHistoryBox async {
    if (!Hive.isBoxOpen(_searchHistoryBoxName)) {
      return await Hive.openBox<SearchHistoryModel>(_searchHistoryBoxName);
    }
    return Hive.box<SearchHistoryModel>(_searchHistoryBoxName);
  }

  Future<Box<SavedSearchModel>> get _savedSearchesBox async {
    if (!Hive.isBoxOpen(_savedSearchesBoxName)) {
      return await Hive.openBox<SavedSearchModel>(_savedSearchesBoxName);
    }
    return Hive.box<SavedSearchModel>(_savedSearchesBoxName);
  }

  @override
  Future<List<SearchHistoryModel>> getSearchHistory({int limit = 10}) async {
    try {
      final box = await _searchHistoryBox;
      final allHistory = box.values.toList();
      
      // Sort by timestamp descending (most recent first)
      allHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Return limited results
      return allHistory.take(limit).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get search history: $e');
    }
  }

  @override
  Future<void> addSearchHistory(SearchHistoryModel entry) async {
    try {
      final box = await _searchHistoryBox;
      
      // Check if query already exists
      final existing = box.values.where((e) => e.query == entry.query).toList();
      
      // Remove existing entries with same query
      for (final existingEntry in existing) {
        await existingEntry.delete();
      }
      
      // Add new entry
      await box.put(entry.id, entry);
      
      // Keep only last 50 entries
      if (box.length > 50) {
        final allHistory = box.values.toList();
        allHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        // Delete oldest entries
        for (var i = 0; i < box.length - 50; i++) {
          await allHistory[i].delete();
        }
      }
    } catch (e) {
      throw CacheException(message: 'Failed to add search history: $e');
    }
  }

  @override
  Future<void> clearSearchHistory() async {
    try {
      final box = await _searchHistoryBox;
      await box.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear search history: $e');
    }
  }

  @override
  Future<void> deleteSearchHistoryEntry(String id) async {
    try {
      final box = await _searchHistoryBox;
      await box.delete(id);
    } catch (e) {
      throw CacheException(message: 'Failed to delete search history entry: $e');
    }
  }

  @override
  Future<List<SavedSearchModel>> getSavedSearches() async {
    try {
      final box = await _savedSearchesBox;
      final searches = box.values.toList();
      
      // Sort by updated date descending
      searches.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      return searches;
    } catch (e) {
      throw CacheException(message: 'Failed to get saved searches: $e');
    }
  }

  @override
  Future<SavedSearchModel?> getSavedSearchById(String id) async {
    try {
      final box = await _savedSearchesBox;
      return box.get(id);
    } catch (e) {
      throw CacheException(message: 'Failed to get saved search: $e');
    }
  }

  @override
  Future<void> saveSavedSearch(SavedSearchModel savedSearch) async {
    try {
      final box = await _savedSearchesBox;
      await box.put(savedSearch.id, savedSearch);
    } catch (e) {
      throw CacheException(message: 'Failed to save search: $e');
    }
  }

  @override
  Future<void> updateSavedSearch(SavedSearchModel savedSearch) async {
    try {
      final box = await _savedSearchesBox;
      await box.put(savedSearch.id, savedSearch);
    } catch (e) {
      throw CacheException(message: 'Failed to update saved search: $e');
    }
  }

  @override
  Future<void> deleteSavedSearch(String id) async {
    try {
      final box = await _savedSearchesBox;
      await box.delete(id);
    } catch (e) {
      throw CacheException(message: 'Failed to delete saved search: $e');
    }
  }
}
