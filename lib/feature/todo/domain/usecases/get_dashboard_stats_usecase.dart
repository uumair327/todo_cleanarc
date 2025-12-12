import 'package:dartz/dartz.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../core/domain/enums/task_enums.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class DashboardStats {
  final int ongoingCount;
  final int completedCount;
  final int inProcessCount;
  final int canceledCount;
  final List<TaskEntity> recentTasks;

  const DashboardStats({
    required this.ongoingCount,
    required this.completedCount,
    required this.inProcessCount,
    required this.canceledCount,
    required this.recentTasks,
  });
}

class GetDashboardStatsUseCase {
  final TaskRepository repository;

  const GetDashboardStatsUseCase(this.repository);

  ResultFuture<DashboardStats> call() async {
    final result = await repository.getAllTasks();
    
    return result.fold(
      (failure) => Left(failure),
      (tasks) {
        final ongoingCount = tasks.where((task) => task.category == TaskCategory.ongoing).length;
        final completedCount = tasks.where((task) => task.category == TaskCategory.completed).length;
        final inProcessCount = tasks.where((task) => task.category == TaskCategory.inProcess).length;
        final canceledCount = tasks.where((task) => task.category == TaskCategory.canceled).length;
        
        // Get recent tasks (last 5 tasks sorted by creation date)
        final recentTasks = List<TaskEntity>.from(tasks)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
          ..take(5);

        final stats = DashboardStats(
          ongoingCount: ongoingCount,
          completedCount: completedCount,
          inProcessCount: inProcessCount,
          canceledCount: canceledCount,
          recentTasks: recentTasks.take(5).toList(),
        );

        return Right(stats);
      },
    );
  }
}