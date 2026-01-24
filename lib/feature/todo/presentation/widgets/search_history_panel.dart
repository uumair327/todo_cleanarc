import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_colors.dart';
import '../bloc/advanced_search/advanced_search_bloc.dart';
import '../bloc/advanced_search/advanced_search_event.dart';
import '../bloc/advanced_search/advanced_search_state.dart';

class SearchHistoryPanel extends StatelessWidget {
  final Function(String) onQuerySelected;

  const SearchHistoryPanel({
    super.key,
    required this.onQuerySelected,
  });

  @override
  Widget build(BuildContext context) {
    context.read<AdvancedSearchBloc>().add(const AdvancedSearchHistoryLoaded());

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search History',
                style: AppTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  context.read<AdvancedSearchBloc>().add(
                        const AdvancedSearchHistoryCleared(),
                      );
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Flexible(
            child: BlocBuilder<AdvancedSearchBloc, AdvancedSearchState>(
              builder: (context, state) {
                final history = state is AdvancedSearchLoaded
                    ? state.searchHistory
                    : state is AdvancedSearchEmpty
                        ? state.searchHistory
                        : <dynamic>[];

                if (history.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Text('No search history'),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: history.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(entry.query),
                      subtitle: Text(
                        _formatTimestamp(entry.timestamp),
                        style: AppTheme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          context.read<AdvancedSearchBloc>().add(
                                AdvancedSearchHistoryEntryDeleted(entry.id),
                              );
                        },
                      ),
                      onTap: () => onQuerySelected(entry.query),
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
