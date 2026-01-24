import 'package:equatable/equatable.dart';

/// Entity representing a search history entry
class SearchHistoryEntry extends Equatable {
  final String id;
  final String query;
  final DateTime timestamp;

  const SearchHistoryEntry({
    required this.id,
    required this.query,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, query, timestamp];
}
