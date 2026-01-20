import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/pagination_helper.dart';
import '../../../../core/utils/loading_manager.dart';
import '../bloc/task_list/task_list_bloc.dart';
import '../bloc/task_list/task_list_event.dart';
import '../bloc/task_list/task_list_state.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PaginationHelper _paginationHelper = PaginationHelper(pageSize: 20);
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<TaskListBloc>().add(TaskListLoadPaginatedRequested(
          page: _paginationHelper.currentPage,
          pageSize: _paginationHelper.pageSize,
        ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreTasks();
    }
  }

  void _loadMoreTasks() {
    if (!_isLoadingMore && _paginationHelper.hasMoreData) {
      setState(() {
        _isLoadingMore = true;
      });

      _paginationHelper.nextPage();
      context.read<TaskListBloc>().add(TaskListLoadMoreRequested(
            page: _paginationHelper.currentPage,
            pageSize: _paginationHelper.pageSize,
            searchQuery:
                _searchController.text.isEmpty ? null : _searchController.text,
            startDate: _selectedStartDate,
            endDate: _selectedEndDate,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.tasks),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to task form for creation
              // This will be implemented when navigation is set up
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilterSection(),

          // Task List
          Expanded(
            child: BlocBuilder<TaskListBloc, TaskListState>(
              builder: (context, state) {
                return StreamBuilder<LoadingState>(
                  stream: loadingManager.stateStream,
                  builder: (context, loadingSnapshot) {
                    final loadingState =
                        loadingSnapshot.data ?? const LoadingState.idle();

                    if (state is TaskListLoading) {
                      return LoadingWidget(
                        message:
                            loadingState.message ?? AppStrings.loadingTasks,
                        progress: loadingState.progress > 0
                            ? loadingState.progress
                            : null,
                        showProgress: loadingState.progress > 0,
                      );
                    } else if (state is TaskListError) {
                      return _buildErrorState(state.message);
                    } else if (state is TaskListEmpty) {
                      return _buildEmptyState();
                    } else if (state is TaskListLoaded) {
                      return _buildLoadedState(state);
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          CustomTextField(
            controller: _searchController,
            hint: AppStrings.searchTasksHint,
            prefixIcon: const Icon(Icons.search),
            onChanged: (value) {
              // Debounce search to avoid too many API calls
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchController.text == value) {
                  _paginationHelper.reset();
                  context.read<TaskListBloc>().add(
                        TaskListLoadPaginatedRequested(
                          page: 0,
                          pageSize: _paginationHelper.pageSize,
                          searchQuery: value.isEmpty ? null : value,
                          startDate: _selectedStartDate,
                          endDate: _selectedEndDate,
                        ),
                      );
                }
              });
            },
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _paginationHelper.reset();
                      context.read<TaskListBloc>().add(
                            TaskListLoadPaginatedRequested(
                              page: 0,
                              pageSize: _paginationHelper.pageSize,
                              startDate: _selectedStartDate,
                              endDate: _selectedEndDate,
                            ),
                          );
                    },
                  )
                : null,
          ),
          const SizedBox(height: 12),

          // Filter Row
          Row(
            children: [
              Expanded(
                child: _buildDateFilterButton(
                  AppStrings.startDate,
                  _selectedStartDate,
                  (date) {
                    setState(() {
                      _selectedStartDate = date;
                    });
                    _applyDateFilter();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateFilterButton(
                  AppStrings.endDate,
                  _selectedEndDate,
                  (date) {
                    setState(() {
                      _selectedEndDate = date;
                    });
                    _applyDateFilter();
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: _clearFilters,
                tooltip: AppStrings.clearFilters,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterButton(
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        onDateSelected(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedDate != null
                    ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    : label,
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: selectedDate != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyDateFilter() {
    _paginationHelper.reset();
    context.read<TaskListBloc>().add(
          TaskListLoadPaginatedRequested(
            page: 0,
            pageSize: _paginationHelper.pageSize,
            searchQuery:
                _searchController.text.isEmpty ? null : _searchController.text,
            startDate: _selectedStartDate,
            endDate: _selectedEndDate,
          ),
        );
  }

  void _clearFilters() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
    });
    _searchController.clear();
    _paginationHelper.reset();
    context.read<TaskListBloc>().add(
          TaskListLoadPaginatedRequested(
            page: 0,
            pageSize: _paginationHelper.pageSize,
          ),
        );
  }

  Widget _buildErrorState(String message) {
    // Determine if this is a network error
    final isNetworkError = message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('connection');

    if (isNetworkError) {
      return NetworkErrorWidget(
        message: message,
        onRetry: () {
          _paginationHelper.reset();
          loadingManager.clearError();
          context.read<TaskListBloc>().add(
                TaskListLoadPaginatedRequested(
                  page: 0,
                  pageSize: _paginationHelper.pageSize,
                ),
              );
        },
        onGoOffline: () {
          // Show cached data or offline mode
          SnackBarHelper.showInfo(context, AppStrings.workingOffline);
        },
      );
    }

    return ErrorRetryWidget(
      message: message,
      onRetry: () {
        _paginationHelper.reset();
        loadingManager.clearError();
        context.read<TaskListBloc>().add(
              TaskListLoadPaginatedRequested(
                page: 0,
                pageSize: _paginationHelper.pageSize,
              ),
            );
      },
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _searchController.text.isNotEmpty ||
        _selectedStartDate != null ||
        _selectedEndDate != null;

    return EmptyStateWidget(
      title: hasFilters ? AppStrings.noMatchingTasks : AppStrings.noTasksYet,
      message:
          hasFilters ? AppStrings.adjustFilters : AppStrings.createFirstTask,
      icon: hasFilters ? Icons.search_off : Icons.task_alt,
      actionText: hasFilters ? AppStrings.clearFilters : AppStrings.createTask,
      onAction: () {
        if (hasFilters) {
          _clearFilters();
        } else {
          // Navigate to task form for creation
          // This will be implemented when navigation is set up
          SnackBarHelper.showInfo(
              context, 'Task creation will be available soon');
        }
      },
    );
  }

  Widget _buildLoadedState(TaskListLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        _paginationHelper.reset();
        setState(() {
          _isLoadingMore = false;
        });
        context.read<TaskListBloc>().add(
              TaskListLoadPaginatedRequested(
                page: 0,
                pageSize: _paginationHelper.pageSize,
                searchQuery: _searchController.text.isEmpty
                    ? null
                    : _searchController.text,
                startDate: _selectedStartDate,
                endDate: _selectedEndDate,
              ),
            );
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.tasks.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= state.tasks.length) {
            // Loading indicator for more items
            setState(() {
              _isLoadingMore = false;
            });
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final task = state.tasks[index];
          return TaskCard(
            task: task,
            onTap: () {
              // Navigate to task details or edit
              // This will be implemented when navigation is set up
            },
            onComplete: () {
              context.read<TaskListBloc>().add(
                    TaskListTaskCompleted(task),
                  );
            },
            onDelete: () {
              _showDeleteConfirmation(task.id.value, task.title);
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(String taskId, String taskTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTaskTitle),
        content: Text('${AppStrings.deleteTaskConfirm}"$taskTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TaskListBloc>().add(
                    TaskListTaskDeleted(
                      // Convert string back to TaskId
                      // This is a temporary solution until proper navigation is implemented
                      taskId as dynamic,
                    ),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
