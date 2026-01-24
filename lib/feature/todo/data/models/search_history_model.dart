import 'package:hive/hive.dart';
import '../../domain/entities/search_history_entry.dart';

part 'search_history_model.g.dart';

@HiveType(typeId: 4)
class SearchHistoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String query;

  @HiveField(2)
  final DateTime timestamp;

  SearchHistoryModel({
    required this.id,
    required this.query,
    required this.timestamp,
  });

  factory SearchHistoryModel.fromEntity(SearchHistoryEntry entity) {
    return SearchHistoryModel(
      id: entity.id,
      query: entity.query,
      timestamp: entity.timestamp,
    );
  }

  SearchHistoryEntry toEntity() {
    return SearchHistoryEntry(
      id: id,
      query: query,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryModel(
      id: json['id'] as String,
      query: json['query'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
