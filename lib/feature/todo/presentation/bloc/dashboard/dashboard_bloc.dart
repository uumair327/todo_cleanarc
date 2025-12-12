import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../../../auth/domain/repositories/auth_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends HydratedBloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase _getDashboardStatsUseCase;
  final AuthRepository _authRepository;

  DashboardBloc({
    required GetDashboardStatsUseCase getDashboardStatsUseCase,
    required AuthRepository authRepository,
  })  : _getDashboardStatsUseCase = getDashboardStatsUseCase,
        _authRepository = authRepository,
        super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onDashboardLoadRequested);
    on<DashboardRefreshRequested>(_onDashboardRefreshRequested);
  }

  Future<void> _onDashboardLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _loadDashboardData(emit);
  }

  Future<void> _onDashboardRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadDashboardData(emit);
  }

  Future<void> _loadDashboardData(Emitter<DashboardState> emit) async {
    try {
      // Get current user for greeting
      final userResult = await _authRepository.getCurrentUser();
      
      // Get dashboard statistics
      final statsResult = await _getDashboardStatsUseCase();

      // Combine results
      final userGreeting = userResult.fold(
        (failure) => _getTimeBasedGreeting(),
        (user) => user != null 
            ? _getPersonalizedGreeting(user.email.value)
            : _getTimeBasedGreeting(),
      );

      statsResult.fold(
        (failure) => emit(DashboardError(_getFailureMessage(failure))),
        (stats) => emit(DashboardLoaded(
          stats: stats,
          userGreeting: userGreeting,
        )),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  String _getPersonalizedGreeting(String email) {
    final hour = DateTime.now().hour;
    final timeGreeting = _getTimeBasedGreeting();
    
    // Extract name from email (part before @)
    final name = email.split('@').first;
    final capitalizedName = name.isNotEmpty 
        ? name[0].toUpperCase() + name.substring(1).toLowerCase()
        : 'User';
    
    return '$timeGreeting, $capitalizedName!';
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  DashboardState? fromJson(Map<String, dynamic> json) {
    try {
      final stateType = json['type'] as String?;
      
      switch (stateType) {
        case 'loaded':
          // For offline persistence, we'll restore to initial state
          // and let the app reload dashboard data from local storage
          return const DashboardInitial();
        default:
          return const DashboardInitial();
      }
    } catch (e) {
      return const DashboardInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(DashboardState state) {
    try {
      if (state is DashboardLoaded) {
        return {'type': 'loaded'};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _getFailureMessage(dynamic failure) {
    if (failure.runtimeType.toString().contains('ServerFailure')) {
      return (failure as dynamic).message;
    } else if (failure.runtimeType.toString().contains('NetworkFailure')) {
      return (failure as dynamic).message;
    } else if (failure.runtimeType.toString().contains('CacheFailure')) {
      return (failure as dynamic).message;
    }
    return 'An unexpected error occurred while loading dashboard data';
  }
}