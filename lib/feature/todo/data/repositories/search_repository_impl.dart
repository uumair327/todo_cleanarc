import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/saved_search.dart';
import '../../domain/entities/search_history_entry.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_datasource.dart';
import '../models/saved_search_model.dart';
import '../models/search_history_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchDataSource _dataSource;
  final Uuid _uuid = const Uuid();

  SearchRepositoryImpl({required SearchDataSource dataSource})
      : _dataSource = dataSource;

  @override
  ResultFuture<List<SearchHistoryEntry>> getSearchHistory({int limit = 10}) async {
    try {
      final models = await _dataSource.getSearchHistory(limit: limit);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to get search history'));
    }
  }

  @override
  ResultVoid addSearchHistory(String query) async {
    try {
      if (query.trim().isEmpty) {
        return const Right(null);
      }

      final entry = SearchHistoryModel(
        id: _uuid.v4(),
        query: query.trim(),
        timestamp: DateTime.now(),
      );

      await _dataSource.addSearchHistory(entry);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to add search history'));
    }
  }

  @override
  ResultVoid clearSearchHistory() async {
    try {
      await _dataSource.clearSearchHistory();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to clear search history'));
    }
  }

  @override
  ResultVoid deleteSearchHistoryEntry(String id) async {
    try {
      await _dataSource.deleteSearchHistoryEntry(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to delete search history entry'));
    }
  }

  @override
  ResultFuture<List<SavedSearch>> getSavedSearches() async {
    try {
      final models = await _dataSource.getSavedSearches();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to get saved searches'));
    }
  }

  @override
  ResultFuture<SavedSearch?> getSavedSearchById(String id) async {
    try {
      final model = await _dataSource.getSavedSearchById(id);
      return Right(model?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to get saved search'));
    }
  }

  @override
  ResultVoid saveSavedSearch(SavedSearch savedSearch) async {
    try {
      final model = SavedSearchModel.fromEntity(savedSearch);
      await _dataSource.saveSavedSearch(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to save search'));
    }
  }

  @override
  ResultVoid updateSavedSearch(SavedSearch savedSearch) async {
    try {
      final model = SavedSearchModel.fromEntity(savedSearch);
      await _dataSource.updateSavedSearch(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to update saved search'));
    }
  }

  @override
  ResultVoid deleteSavedSearch(String id) async {
    try {
      await _dataSource.deleteSavedSearch(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to delete saved search'));
    }
  }
}
