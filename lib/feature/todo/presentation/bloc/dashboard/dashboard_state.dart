import 'package:equatable/equatable.dart';
import '../../../domain/usecases/get_dashboard_stats_usecase.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final String userGreeting;

  const DashboardLoaded({
    required this.stats,
    required this.userGreeting,
  });

  @override
  List<Object?> get props => [stats, userGreeting];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}