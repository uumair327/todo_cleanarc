import 'package:equatable/equatable.dart';
import '../../../domain/entities/search_filter.dart';

abstract class AdvancedSearchEvent extends Equatable {
  const AdvancedSearchEvent();

  @override
  List<Object?> get props => [];
}

class AdvancedSearchInitialized extends AdvancedSearchEvent {
  const AdvancedSearchInitialized();
}

class AdvancedSearchFilterChanged extends AdvancedSearchEvent {
  final SearchFilter filter;

  const AdvancedSearchFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class AdvancedSearchExecuted extends AdvancedSearchEvent {
  final SearchFilter filter;

  const AdvancedSearchExecuted(this.filter);

  @override
  List<Object?> get props => [filter];
}

class AdvancedSearchCleared extends AdvancedSearchEvent {
  const AdvancedSearchCleared();
}

class AdvancedSearchHistoryLoaded extends AdvancedSearchEvent {
  const AdvancedSearchHistoryLoaded();
}

class AdvancedSearchHistoryEntryDeleted extends AdvancedSearchEvent {
  final String id;

  const AdvancedSearchHistoryEntryDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class AdvancedSearchHistoryCleared extends AdvancedSearchEvent {
  const AdvancedSearchHistoryCleared();
}

class AdvancedSearchSavedSearchesLoaded extends AdvancedSearchEvent {
  const AdvancedSearchSavedSearchesLoaded();
}

class AdvancedSearchSaved extends AdvancedSearchEvent {
  final String name;
  final SearchFilter filter;

  const AdvancedSearchSaved(this.name, this.filter);

  @override
  List<Object?> get props => [name, filter];
}

class AdvancedSearchSavedSearchDeleted extends AdvancedSearchEvent {
  final String id;

  const AdvancedSearchSavedSearchDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class AdvancedSearchSavedSearchApplied extends AdvancedSearchEvent {
  final String id;

  const AdvancedSearchSavedSearchApplied(this.id);

  @override
  List<Object?> get props => [id];
}
