import '../../../../core/utils/typedef.dart';
import '../../../../core/utils/pagination_helper.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksPaginatedUseCase {
  final TaskRepository _repository;

  GetTasksPaginatedUseCase(this._repository);

  ResultFuture<PaginatedResult<TaskEntity>> call({
    int page = 0,
    int pageSize = 20,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getTasksPaginated(
      page: page,
      pageSize: pageSize,
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
    );
  }
}