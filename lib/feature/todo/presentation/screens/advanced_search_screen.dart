import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/search_filter.dart';
import '../bloc/advanced_search/advanced_search_bloc.dart';
import '../bloc/advanced_search/advanced_search_event.dart';
import '../bloc/advanced_search/advanced_search_state.dart';
import '../widgets/task_card.dart';
import '../widgets/advanced_filter_panel.dart';
import '../widgets/search_history_panel.dart';
import '../widgets/saved_searches_panel.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  SearchFilter _currentFilter = const SearchFilter();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    context.read<AdvancedSearchBloc>().add(const AdvancedSearchInitialized());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => _showSavedSearchesDialog(),
            tooltip: 'Saved Searches',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFilterPanel(),
          Expanded(
            child: BlocBuilder<AdvancedSearchBloc, AdvancedSearchState>(
              builder: (context, state) {
                if (state is AdvancedSearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AdvancedSearchError) {
                  return ErrorRetryWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<AdvancedSearchBloc>().add(
                            AdvancedSearchExecuted(_currentFilter),
                          );
                    },
                  );
                } else if (state is AdvancedSearchEmpty) {
                  return _buildEmptyState(state);
                } else if (state is AdvancedSearchLoaded) {
                  return _buildLoadedState(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _searchController,
              hint: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) {
                _currentFilter = _currentFilter.copyWith(searchQuery: value);
              },
              onSubmitted: (value) {
                _executeSearch();
              },
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _currentFilter = _currentFilter.copyWith(
                          clearSearchQuery: true,
                        );
                        _executeSearch();
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: () => _showSearchHistoryDialog(),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton(
            onPressed: _executeSearch,
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return AdvancedFilterPanel(
      currentFilter: _currentFilter,
      onFilterChanged: (filter) {
        setState(() {
          _currentFilter = filter;
        });
      },
      onClearFilters: () {
        setState(() {
          _currentFilter = const SearchFilter();
          _searchController.clear();
        });
        context.read<AdvancedSearchBloc>().add(const AdvancedSearchCleared());
      },
      onSaveSearch: () => _showSaveSearchDialog(),
    );
  }

  Widget _buildEmptyState(AdvancedSearchEmpty state) {
    final hasFilters = !state.currentFilter.isEmpty;

    return EmptyStateWidget(
      title: hasFilters ? 'No matching tasks' : 'Start searching',
      message: hasFilters
          ? 'Try adjusting your filters'
          : 'Use the search bar and filters to find tasks',
      icon: hasFilters ? Icons.search_off : Icons.search,
      actionText: hasFilters ? 'Clear Filters' : null,
      onAction: hasFilters
          ? () {
              setState(() {
                _currentFilter = const SearchFilter();
                _searchController.clear();
              });
              context.read<AdvancedSearchBloc>().add(const AdvancedSearchCleared());
            }
          : null,
    );
  }

  Widget _buildLoadedState(AdvancedSearchLoaded state) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: state.tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.mdSm),
      itemBuilder: (context, index) {
        final task = state.tasks[index];
        return TaskCard(
          task: task,
          onTap: () {
            context.push('/task/edit/${task.id.value}').then((result) {
              if (result == true) {
                // Re-execute search after successful edit
                _executeSearch();
              }
            });
          },
          onEdit: () {
            context.push('/task/edit/${task.id.value}').then((result) {
              if (result == true) {
                // Re-execute search after successful edit
                _executeSearch();
              }
            });
          },
          onComplete: () {
            // Re-execute search after completion
            _executeSearch();
          },
          onDelete: () {
            // Re-execute search after deletion
            _executeSearch();
          },
        );
      },
    );
  }

  void _executeSearch() {
    final filter = _currentFilter.copyWith(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
    );
    context.read<AdvancedSearchBloc>().add(AdvancedSearchExecuted(filter));
  }

  void _showSearchHistoryDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SearchHistoryPanel(
        onQuerySelected: (query) {
          _searchController.text = query;
          _currentFilter = _currentFilter.copyWith(searchQuery: query);
          Navigator.pop(context);
          _executeSearch();
        },
      ),
    );
  }

  void _showSavedSearchesDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SavedSearchesPanel(
        onSearchSelected: (savedSearch) {
          setState(() {
            _currentFilter = savedSearch.filter;
            _searchController.text = savedSearch.filter.searchQuery ?? '';
          });
          Navigator.pop(context);
          _executeSearch();
        },
      ),
    );
  }

  void _showSaveSearchDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save Search'),
        content: CustomTextField(
          controller: nameController,
          hint: 'Search name',
          label: 'Name',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<AdvancedSearchBloc>().add(
                      AdvancedSearchSaved(nameController.text, _currentFilter),
                    );
                Navigator.pop(dialogContext);
                SnackBarHelper.showSuccess(context, 'Search saved successfully');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
