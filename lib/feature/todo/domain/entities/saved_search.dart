import 'package:equatable/equatable.dart';
import 'search_filter.dart';

/// Entity representing a saved search configuration
class SavedSearch extends Equatable {
  final String id;
  final String name;
  final SearchFilter filter;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedSearch({
    required this.id,
    required this.name,
    required this.filter,
    required this.createdAt,
    required this.updatedAt,
  });

  SavedSearch copyWith({
    String? id,
    String? name,
    SearchFilter? filter,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedSearch(
      id: id ?? this.id,
      name: name ?? this.name,
      filter: filter ?? this.filter,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, filter, createdAt, updatedAt];
}
