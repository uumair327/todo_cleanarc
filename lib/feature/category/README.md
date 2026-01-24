# Category Management Feature

## Overview

This feature implements comprehensive category management for the Todo app, allowing users to create, update, delete, and manage custom categories with colors.

## Architecture

The implementation follows Clean Architecture principles with three layers:

### Domain Layer
- **Entities**: `CategoryEntity` - Core category business object
- **Repositories**: `CategoryRepository` - Abstract interface for category operations
- **Use Cases**:
  - `CreateCategoryUseCase` - Create new categories with validation
  - `UpdateCategoryUseCase` - Update existing categories
  - `DeleteCategoryUseCase` - Soft delete categories
  - `GetCategoriesUseCase` - Retrieve user categories

### Data Layer
- **Models**: `CategoryModel` - Hive adapter (typeId: 2) with JSON serialization
- **Data Sources**:
  - `HiveCategoryDataSource` - Local storage implementation
  - `SupabaseCategoryDataSource` - Remote API implementation
- **Repository**: `CategoryRepositoryImpl` - Offline-first implementation with sync

### Presentation Layer
- **BLoC**: `CategoryBloc` - State management for category operations
- **Screens**: `CategoryManagementScreen` - Main category management UI
- **Widgets**:
  - `CategoryListItem` - Display individual categories
  - `CategoryFormDialog` - Create/edit category form with color picker

## Features

### CRUD Operations
- ✅ Create custom categories with names and colors
- ✅ Update category names and colors
- ✅ Delete categories (soft delete)
- ✅ List all user categories

### Color Management
- ✅ Color picker integration (flutter_colorpicker)
- ✅ Hex color validation
- ✅ Visual color preview
- ✅ Default category colors

### Offline-First
- ✅ Local caching with Hive
- ✅ Automatic sync when online
- ✅ Conflict resolution using timestamps

### Database
- ✅ Supabase categories table
- ✅ Row Level Security (RLS) policies
- ✅ Default categories for all users
- ✅ Indexes for performance

## Database Schema

```sql
CREATE TABLE categories (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    name TEXT NOT NULL,
    color_hex TEXT NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);
```

## Usage

### Creating a Category

```dart
final bloc = context.read<CategoryBloc>();
bloc.add(CreateCategory(
  userId: currentUserId,
  name: 'Work',
  colorHex: '#FF5733',
));
```

### Updating a Category

```dart
bloc.add(UpdateCategory(
  id: categoryId,
  name: 'Personal',
  colorHex: '#3498DB',
));
```

### Deleting a Category

```dart
bloc.add(DeleteCategory(categoryId));
```

### Loading Categories

```dart
bloc.add(LoadCategories(currentUserId));
```

## Dependencies

- `hive` - Local storage
- `supabase_flutter` - Backend integration
- `flutter_colorpicker` - Color selection UI
- `uuid` - ID generation
- `dartz` - Functional error handling

## Migration

Run the database migration to create the categories table:

```bash
# Apply migration 004
psql -d your_database -f scripts/migrations/004_categories_table.sql
```

## Default Categories

The system includes four default categories:
- **Ongoing** (#2196F3 - Blue)
- **In Process** (#FFC107 - Yellow)
- **Completed** (#4CAF50 - Green)
- **Canceled** (#F44336 - Red)

## Testing

Unit tests should cover:
- Category entity validation
- Use case business logic
- Repository offline-first behavior
- BLoC state transitions
- Widget rendering

## Future Enhancements

- Category icons
- Category ordering/sorting
- Category usage statistics
- Bulk category operations
- Category templates
- Category sharing between users
