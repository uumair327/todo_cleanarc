import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/build_context_color_extension.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../widgets/task_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceSecondary,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context
                .read<DashboardBloc>()
                .add(const DashboardRefreshRequested());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return _buildLoadingState();
                } else if (state is DashboardError) {
                  return _buildErrorState(state.message);
                } else if (state is DashboardLoaded) {
                  return _buildLoadedState(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting skeleton
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: context.surfacePrimary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.mdLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: 200,
                  height: 28,
                ),
                SizedBox(height: AppSpacing.sm),
                SkeletonLoader(
                  width: 150,
                  height: 18,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Stats section skeleton
        SkeletonLoader(
          width: 150,
          height: 24,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: AppSpacing.md),
        const DashboardStatsSkeleton(),
        const SizedBox(height: AppSpacing.lg),
        
        // Recent tasks skeleton
        SkeletonLoader(
          width: 120,
          height: 24,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: AppSpacing.md),
        const TaskCardSkeleton(),
        const SizedBox(height: AppSpacing.mdSm),
        const TaskCardSkeleton(),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: context.colorScheme.error,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.errorLoadingDashboard,
            style: AppTheme.textTheme.headlineSmall?.copyWith(
              color: context.colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: context.onSurfaceSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomButton(
            text: AppStrings.retry,
            onPressed: () {
              context.read<DashboardBloc>().add(const DashboardLoadRequested());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Greeting
        _buildGreetingSection(state.userGreeting),
        const SizedBox(height: AppSpacing.lg),

        // Category Statistics
        _buildCategoryStatsSection(state),
        const SizedBox(height: AppSpacing.lg),

        // Recent Tasks
        _buildRecentTasksSection(state),
      ],
    );
  }

  Widget _buildGreetingSection(String greeting) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.mdLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.ongoingTaskColor,
            context.appColors.ongoingTask
                .toFlutterColor()
                .withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: context.appColors.ongoingTask
                .toFlutterColor()
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: AppTheme.textTheme.headlineMedium?.copyWith(
              color: context.onOngoingTaskColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.dashProductiveTagline,
            style: AppTheme.textTheme.bodyLarge?.copyWith(
              color: context.appColors.onOngoingTask
                  .toFlutterColor()
                  .withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStatsSection(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.taskOverview,
          style: AppTheme.textTheme.headlineSmall?.copyWith(
            color: context.onSurfacePrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.mdSm,
          mainAxisSpacing: AppSpacing.mdSm,
          childAspectRatio: 1.2,
          children: [
            _buildCategoryCard(
              AppStrings.ongoing,
              state.stats.ongoingCount,
              context.ongoingTaskColor,
              Icons.play_circle_outline,
            ),
            _buildCategoryCard(
              AppStrings.completed,
              state.stats.completedCount,
              context.completedTaskColor,
              Icons.check_circle_outline,
            ),
            _buildCategoryCard(
              AppStrings.inProcess,
              state.stats.inProcessCount,
              context.inProcessTaskColor,
              Icons.hourglass_empty,
            ),
            _buildCategoryCard(
              AppStrings.canceled,
              state.stats.canceledCount,
              context.canceledTaskColor,
              Icons.cancel_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfacePrimary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: context.onSurfacePrimaryOpacity40,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.mdSm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppDimensions.iconSize,
            ),
          ),
          const SizedBox(height: AppSpacing.mdSm),
          Text(
            count.toString(),
            style: AppTheme.textTheme.headlineMedium?.copyWith(
              color: context.onSurfacePrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: context.onSurfaceSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTasksSection(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentTasks,
              style: AppTheme.textTheme.headlineSmall?.copyWith(
                color: context.onSurfacePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to task list
                // This will be implemented when navigation is set up
              },
              child: Text(
                AppStrings.viewAll,
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: context.ongoingTaskColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.stats.recentTasks.isEmpty)
          _buildEmptyRecentTasks()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.stats.recentTasks.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.mdSm),
            itemBuilder: (context, index) {
              final task = state.stats.recentTasks[index];
              return TaskCard(
                task: task,
                onTap: () {
                  context.push('/task/edit/${task.id.value}').then((result) {
                    if (result == true) {
                      // Refresh dashboard after successful edit
                      context
                          .read<DashboardBloc>()
                          .add(const DashboardRefreshRequested());
                    }
                  });
                },
                onEdit: () {
                  context.push('/task/edit/${task.id.value}').then((result) {
                    if (result == true) {
                      // Refresh dashboard after successful edit
                      context
                          .read<DashboardBloc>()
                          .add(const DashboardRefreshRequested());
                    }
                  });
                },
                onComplete: () {
                  // Handle task completion
                  // This will trigger a dashboard refresh
                  context
                      .read<DashboardBloc>()
                      .add(const DashboardRefreshRequested());
                },
                onDelete: () {
                  // Handle task deletion
                  // This will trigger a dashboard refresh
                  context
                      .read<DashboardBloc>()
                      .add(const DashboardRefreshRequested());
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyRecentTasks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.surfacePrimary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: context.onSurfacePrimaryOpacity40,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: AppSpacing.xxl,
            color: context.appColors.onSurfaceSecondary
                .toFlutterColor()
                .withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.noTasksYet,
            style: AppTheme.textTheme.titleMedium?.copyWith(
              color: context.onSurfaceSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.createFirstTask,
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: context.appColors.onSurfaceSecondary
                  .toFlutterColor()
                  .withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
