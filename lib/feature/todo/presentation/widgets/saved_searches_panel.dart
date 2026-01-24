import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/saved_search.dart';
import '../bloc/advanced_search/advanced_search_bloc.dart';
import '../bloc/advanced_search/advanced_search_event.dart';
import '../bloc/advanced_search/advanced_search_state.dart';

class SavedSearchesPanel extends StatelessWidget {
  final Function(SavedSearch) onSearchSelected;

  const SavedSearchesPanel({
    super.key,
    required this.onSearchSelected,
  });

  @override
  Widget build(BuildContext context) {
    context.read<AdvancedSearchBloc>().add(const AdvancedSearchSavedSearchesLoaded());

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Saved Searches',
            style: AppTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Flexible(
            child: BlocBuilder<AdvancedSearchBloc, AdvancedSearchState>(
              builder: (context, state) {
                final savedSearches = state is AdvancedSearchLoaded
                    ? state.savedSearches
                    : state is AdvancedSearchEmpty
                        ? state.savedSearches
                        : <dynamic>[];

                if (savedSearches.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Text('No saved searches'),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: savedSearches.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final savedSearch = savedSearches[index];
                    return ListTile(
                      leading: const Icon(Icons.bookmark),
                      title: Text(savedSearch.name),
                      subtitle: Text(
                        _buildFilterSummary(savedSearch),
                        style: AppTheme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () {
                          context.read<AdvancedSearchBloc>().add(
                                AdvancedSearchSavedSearchDeleted(savedSearch.id),
                              );
                        },
                      ),
                      onTap: () => onSearchSelected(savedSearch),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _buildFilterSummary(SavedSearch savedSearch) {
    final filter = savedSearch.filter;
    final parts = <String>[];

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      parts.add('Query: "${filter.searchQuery}"');
    }

    if (filter.categories != null && filter.categories!.isNotEmpty) {
      parts.add('${filter.categories!.length} categories');
    }

    if (filter.priorities != null && filter.priorities!.isNotEmpty) {
      parts.add('${filter.priorities!.length} priorities');
    }

    if (filter.startDate != null || filter.endDate != null) {
      parts.add('Date range');
    }

    if (filter.minProgress != null || filter.maxProgress != null) {
      parts.add('Progress filter');
    }

    if (filter.isCompleted != null) {
      parts.add(filter.isCompleted! ? 'Completed' : 'Incomplete');
    }

    return parts.isEmpty ? 'No filters' : parts.join(' • ');
  }
}
