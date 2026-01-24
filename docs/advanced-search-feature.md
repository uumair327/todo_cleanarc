# Advanced Search Feature

## Overview

The advanced search feature provides comprehensive filtering capabilities for tasks, along with search history tracking and the ability to save frequently used search configurations.

## Features Implemented

### 1. Advanced Filters

Users can filter tasks using multiple criteria:

- **Text Search**: Search by task title or description
- **Date Range**: Filter tasks by due date (start date and/or end date)
- **Categories**: Filter by task categories (ongoing, completed, in process, canceled)
- **Priorities**: Filter by priority levels (low, medium, high, urgent, critical)
- **Progress Range**: Filter by completion percentage (min/max)
- **Completion Status**: Filter by completed/incomplete tasks

### 2. Search History

- Automatically tracks recent search queries
- Displays up to 50 most recent searches
- Shows timestamp for each search (e.g., "2h ago", "3d ago")
- Allows quick re-execution of previous searches
- Individual history entries can be deleted
- Option to clear all search history

### 3. Saved Searches

- Save frequently used filter combinations with custom names
- Quick access to saved searches via bookmark icon
- View summary of filters in each saved search
- Delete saved searches when no longer needed
- Apply saved searches with one tap

## Architecture

### Domain Layer

**Entities:**
- `SearchFilter`: Represents filter criteria
- `SavedSearch`: Represents a saved search configuration
- `SearchHistoryEntry`: Represents a search history item

**Use Cases:**
- `AdvancedSearchTasksUseCase`: Executes advanced search with filters
- `AddSearchHistoryUseCase`: Adds query to search history
- `GetSearchHistoryUseCase`: Retrieves search history
- `GetSavedSearchesUseCase`: Retrieves saved searches
- `SaveSearchUseCase`: Saves a new search configuration
- `DeleteSavedSearchUseCase`: Deletes a saved search

**Repository:**
- `SearchRepository`: Abstract interface for search operations

### Data Layer

**Models:**
- `SavedSearchModel`: Hive model (typeId: 3) for saved searches
- `SearchHistoryModel`: Hive model (typeId: 4) for search history

**Data Sources:**
- `HiveSearchDataSource`: Local storage for search data

**Repository Implementation:**
- `SearchRepositoryImpl`: Implements search repository with Hive storage

### Presentation Layer

**BLoC:**
- `AdvancedSearchBloc`: Manages advanced search state
- Events: Initialize, filter changed, search executed, history/saved searches management
- States: Initial, loading, loaded, empty, error

**Screens:**
- `AdvancedSearchScreen`: Main advanced search interface

**Widgets:**
- `AdvancedFilterPanel`: Collapsible filter panel with all filter options
- `SearchHistoryPanel`: Bottom sheet displaying search history
- `SavedSearchesPanel`: Bottom sheet displaying saved searches

## Usage

### Accessing Advanced Search

Navigate to the advanced search screen from the main task list or dashboard.

### Applying Filters

1. Tap the filter icon to show/hide the filter panel
2. Select desired filter criteria:
   - Enter search text
   - Choose date range
   - Select categories and priorities
   - Set progress range
   - Choose completion status
3. Tap "Search" to apply filters

### Using Search History

1. Tap the history icon in the search bar
2. Select a previous search query to re-execute it
3. Swipe or tap delete icon to remove individual entries
4. Tap "Clear All" to remove all history

### Saving Searches

1. Configure your desired filters
2. Tap "Save" in the filter panel
3. Enter a name for the saved search
4. Tap "Save" to confirm

### Using Saved Searches

1. Tap the bookmark icon in the app bar
2. Select a saved search to apply it
3. Tap delete icon to remove a saved search

## Data Persistence

- Search history is stored locally using Hive (max 50 entries)
- Saved searches are stored locally using Hive (unlimited)
- Data persists across app restarts
- No server synchronization (local only)

## Performance Considerations

- Filters are applied in-memory on the client side
- Search history is limited to 50 entries for performance
- Saved searches have no limit but are stored efficiently
- Filter operations are optimized for large task lists

## Future Enhancements

Potential improvements for future versions:

1. **Server-side Search**: Implement server-side filtering for better performance with large datasets
2. **Search Suggestions**: Auto-complete suggestions based on task content
3. **Advanced Query Syntax**: Support for complex queries (AND, OR, NOT operators)
4. **Search Analytics**: Track most used filters and searches
5. **Shared Saved Searches**: Allow users to share saved search configurations
6. **Export Search Results**: Export filtered tasks to CSV or other formats
7. **Smart Filters**: AI-powered filter suggestions based on usage patterns

## Testing

The advanced search feature includes:

- Unit tests for use cases (to be added)
- Integration tests for repository (to be added)
- Widget tests for UI components (to be added)
- Manual testing completed for all features

## Dependencies

- `hive`: Local storage for search history and saved searches
- `uuid`: Generating unique IDs for search entries
- `flutter_bloc`: State management
- `equatable`: Value equality for entities

## Files Created

### Domain
- `lib/feature/todo/domain/entities/search_filter.dart`
- `lib/feature/todo/domain/entities/saved_search.dart`
- `lib/feature/todo/domain/entities/search_history_entry.dart`
- `lib/feature/todo/domain/repositories/search_repository.dart`
- `lib/feature/todo/domain/usecases/advanced_search_tasks_usecase.dart`
- `lib/feature/todo/domain/usecases/add_search_history_usecase.dart`
- `lib/feature/todo/domain/usecases/get_search_history_usecase.dart`
- `lib/feature/todo/domain/usecases/get_saved_searches_usecase.dart`
- `lib/feature/todo/domain/usecases/save_search_usecase.dart`
- `lib/feature/todo/domain/usecases/delete_saved_search_usecase.dart`

### Data
- `lib/feature/todo/data/models/saved_search_model.dart`
- `lib/feature/todo/data/models/search_history_model.dart`
- `lib/feature/todo/data/datasources/search_datasource.dart`
- `lib/feature/todo/data/datasources/hive_search_datasource.dart`
- `lib/feature/todo/data/repositories/search_repository_impl.dart`

### Presentation
- `lib/feature/todo/presentation/bloc/advanced_search/advanced_search_bloc.dart`
- `lib/feature/todo/presentation/bloc/advanced_search/advanced_search_event.dart`
- `lib/feature/todo/presentation/bloc/advanced_search/advanced_search_state.dart`
- `lib/feature/todo/presentation/screens/advanced_search_screen.dart`
- `lib/feature/todo/presentation/widgets/advanced_filter_panel.dart`
- `lib/feature/todo/presentation/widgets/search_history_panel.dart`
- `lib/feature/todo/presentation/widgets/saved_searches_panel.dart`

### Documentation
- `docs/advanced-search-feature.md`
