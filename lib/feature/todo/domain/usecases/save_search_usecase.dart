import 'package:uuid/uuid.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/saved_search.dart';
import '../entities/search_filter.dart';
import '../repositories/search_repository.dart';

class SaveSearchUseCase {
  final SearchRepository repository;
  final Uuid _uuid = const Uuid();

  SaveSearchUseCase(this.repository);

  ResultVoid call(String name, SearchFilter filter) {
    final savedSearch = SavedSearch(
      id: _uuid.v4(),
      name: name,
      filter: filter,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return repository.saveSavedSearch(savedSearch);
  }
}
