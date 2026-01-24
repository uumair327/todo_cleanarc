import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/advanced_search_tasks_usecase.dart';
import '../../../domain/usecases/add_search_history_usecase.dart';
import '../../../domain/usecases/get_search_history_usecase.dart';
import '../../../domain/usecases/get_saved_searches_usecase.dart';
import '../../../domain/usecases/save_search_usecase.dart';
import '../../../domain/usecases/delete_saved_search_usecase.dart';
import '../../../domain/repositories/search_repository.dart';
import '../../../domain/entities/search_filter.dart';
import '../../../domain/entities/search_history_entry.dart';
import '../../../domain/entities/saved_search.dart';
import 'advanced_search_event.dart';
import 'advanced_search_state.dart';

class AdvancedSearchBloc extends Bloc<AdvancedSearchEvent, AdvancedSearchState> {
  final AdvancedSearchTasksUseCase _advancedSearchTasksUseCase;
  final AddSearchHistoryUseCase _addSearchHistoryUseCase;
  final GetSearchHistoryUseCase _getSearchHistoryUseCase;
  final GetSavedSearchesUseCase _getSavedSearchesUseCase;
  final SaveSearchUseCase _saveSearchUseCase;
  final DeleteSavedSearchUseCase _deleteSavedSearchUseCase;
  final SearchRepository _searchRepository;

  AdvancedSearchBloc({
    required AdvancedSearchTasksUseCase advancedSearchTasksUseCase,
    required AddSearchHistoryUseCase addSearchHistoryUseCase,
    required GetSearchHistoryUseCase getSearchHistoryUseCase,
    required GetSavedSearchesUseCase getSavedSearchesUseCase,
    required SaveSearchUseCase saveSearchUseCase,
    required DeleteSavedSearchUseCase deleteSavedSearchUseCase,
    required SearchRepository searchRepository,
  })  : _advancedSearchTasksUseCase = advancedSearchTasksUseCase,
        _addSearchHistoryUseCase = addSearchHistoryUseCase,
        _getSearchHistoryUseCase = getSearchHistoryUseCase,
        _getSavedSearchesUseCase = getSavedSearchesUseCase,
        _saveSearchUseCase = saveSearchUseCase,
        _deleteSavedSearchUseCase = deleteSavedSearchUseCase,
        _searchRepository = searchRepository,
        super(const AdvancedSearchInitial()) {
    on<AdvancedSearchInitialized>(_onInitialized);
    on<AdvancedSearchFilterChanged>(_onFilterChanged);
    on<AdvancedSearchExecuted>(_onSearchExecuted);
    on<AdvancedSearchCleared>(_onSearchCleared);
    on<AdvancedSearchHistoryLoaded>(_onHistoryLoaded);
    on<AdvancedSearchHistoryEntryDeleted>(_onHistoryEntryDeleted);
    on<AdvancedSearchHistoryCleared>(_onHistoryCleared);
    on<AdvancedSearchSavedSearchesLoaded>(_onSavedSearchesLoaded);
    on<AdvancedSearchSaved>(_onSearchSaved);
    on<AdvancedSearchSavedSearchDeleted>(_onSavedSearchDeleted);
    on<AdvancedSearchSavedSearchApplied>(_onSavedSearchApplied);
  }

  Future<void> _onInitialized(
    AdvancedSearchInitialized event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    emit(const AdvancedSearchLoading());
    await _loadSearchData(emit, const SearchFilter());
  }

  Future<void> _onFilterChanged(
    AdvancedSearchFilterChanged event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    // Just update the filter without executing search
    if (state is AdvancedSearchLoaded) {
      final currentState = state as AdvancedSearchLoaded;
      emit(currentState.copyWith(currentFilter: event.filter));
    }
  }

  Future<void> _onSearchExecuted(
    AdvancedSearchExecuted event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    emit(const AdvancedSearchLoading());

    // Add to search history if there's a query
    if (event.filter.searchQuery != null && event.filter.searchQuery!.isNotEmpty) {
      await _addSearchHistoryUseCase(event.filter.searchQuery!);
    }

    await _loadSearchData(emit, event.filter);
  }

  Future<void> _onSearchCleared(
    AdvancedSearchCleared event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    emit(const AdvancedSearchLoading());
    await _loadSearchData(emit, const SearchFilter());
  }

  Future<void> _onHistoryLoaded(
    AdvancedSearchHistoryLoaded event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    if (state is AdvancedSearchLoaded) {
      final currentState = state as AdvancedSearchLoaded;
      final historyResult = await _getSearchHistoryUseCase();

      historyResult.fold(
        (failure) => emit(AdvancedSearchError(failure.toString())),
        (history) => emit(currentState.copyWith(searchHistory: history)),
      );
    }
  }

  Future<void> _onHistoryEntryDeleted(
    AdvancedSearchHistoryEntryDeleted event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    await _searchRepository.deleteSearchHistoryEntry(event.id);
    add(const AdvancedSearchHistoryLoaded());
  }

  Future<void> _onHistoryCleared(
    AdvancedSearchHistoryCleared event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    await _searchRepository.clearSearchHistory();
    add(const AdvancedSearchHistoryLoaded());
  }

  Future<void> _onSavedSearchesLoaded(
    AdvancedSearchSavedSearchesLoaded event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    if (state is AdvancedSearchLoaded) {
      final currentState = state as AdvancedSearchLoaded;
      final savedSearchesResult = await _getSavedSearchesUseCase();

      savedSearchesResult.fold(
        (failure) => emit(AdvancedSearchError(failure.toString())),
        (savedSearches) => emit(currentState.copyWith(savedSearches: savedSearches)),
      );
    }
  }

  Future<void> _onSearchSaved(
    AdvancedSearchSaved event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    final result = await _saveSearchUseCase(event.name, event.filter);

    result.fold(
      (failure) => emit(AdvancedSearchError(failure.toString())),
      (_) => add(const AdvancedSearchSavedSearchesLoaded()),
    );
  }

  Future<void> _onSavedSearchDeleted(
    AdvancedSearchSavedSearchDeleted event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    await _deleteSavedSearchUseCase(event.id);
    add(const AdvancedSearchSavedSearchesLoaded());
  }

  Future<void> _onSavedSearchApplied(
    AdvancedSearchSavedSearchApplied event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    final savedSearchResult = await _searchRepository.getSavedSearchById(event.id);

    savedSearchResult.fold(
      (failure) => emit(AdvancedSearchError(failure.toString())),
      (savedSearch) {
        if (savedSearch != null) {
          add(AdvancedSearchExecuted(savedSearch.filter));
        }
      },
    );
  }

  Future<void> _loadSearchData(
    Emitter<AdvancedSearchState> emit,
    SearchFilter filter,
  ) async {
    try {
      // Execute search
      final tasksResult = await _advancedSearchTasksUseCase(filter);

      // Load search history
      final historyResult = await _getSearchHistoryUseCase();

      // Load saved searches
      final savedSearchesResult = await _getSavedSearchesUseCase();

      tasksResult.fold(
        (failure) => emit(AdvancedSearchError(failure.toString())),
        (tasks) {
          final history = historyResult.fold(
            (failure) => <SearchHistoryEntry>[],
            (h) => h,
          );

          final savedSearches = savedSearchesResult.fold(
            (failure) => <SavedSearch>[],
            (s) => s,
          );

          if (tasks.isEmpty) {
            emit(AdvancedSearchEmpty(
              currentFilter: filter,
              searchHistory: history,
              savedSearches: savedSearches,
            ));
          } else {
            emit(AdvancedSearchLoaded(
              tasks: tasks,
              currentFilter: filter,
              searchHistory: history,
              savedSearches: savedSearches,
            ));
          }
        },
      );
    } catch (e) {
      emit(AdvancedSearchError(e.toString()));
    }
  }
}
