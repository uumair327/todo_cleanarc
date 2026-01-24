import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/entities/search_filter.dart';
import '../../../domain/entities/search_history_entry.dart';
import '../../../domain/entities/saved_search.dart';

abstract class AdvancedSearchState extends Equatable {
  const AdvancedSearchState();

  @override
  List<Object?> get props => [];
}

class AdvancedSearchInitial extends AdvancedSearchState {
  const AdvancedSearchInitial();
}

class AdvancedSearchLoading extends AdvancedSearchState {
  const AdvancedSearchLoading();
}

class AdvancedSearchLoaded extends AdvancedSearchState {
  final List<TaskEntity> tasks;
  final SearchFilter currentFilter;
  final List<SearchHistoryEntry> searchHistory;
  final List<SavedSearch> savedSearches;

  const AdvancedSearchLoaded({
    required this.tasks,
    required this.currentFilter,
    this.searchHistory = const [],
    this.savedSearches = const [],
  });

  @override
  List<Object?> get props => [tasks, currentFilter, searchHistory, savedSearches];

  AdvancedSearchLoaded copyWith({
    List<TaskEntity>? tasks,
    SearchFilter? currentFilter,
    List<SearchHistoryEntry>? searchHistory,
    List<SavedSearch>? savedSearches,
  }) {
    return AdvancedSearchLoaded(
      tasks: tasks ?? this.tasks,
      currentFilter: currentFilter ?? this.currentFilter,
      searchHistory: searchHistory ?? this.searchHistory,
      savedSearches: savedSearches ?? this.savedSearches,
    );
  }
}

class AdvancedSearchEmpty extends AdvancedSearchState {
  final SearchFilter currentFilter;
  final List<SearchHistoryEntry> searchHistory;
  final List<SavedSearch> savedSearches;

  const AdvancedSearchEmpty({
    required this.currentFilter,
    this.searchHistory = const [],
    this.savedSearches = const [],
  });

  @override
  List<Object?> get props => [currentFilter, searchHistory, savedSearches];
}

class AdvancedSearchError extends AdvancedSearchState {
  final String message;

  const AdvancedSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
