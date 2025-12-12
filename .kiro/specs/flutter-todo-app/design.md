# Flutter Todo App Design Document

## Overview

The Flutter Todo App is a modern task management application built using Clean Architecture principles with offline-first capabilities. The system provides comprehensive task management through a layered architecture that separates business logic from data persistence and UI presentation. The app leverages Flutter's cross-platform capabilities while maintaining native performance through efficient state management and local data caching.

The architecture emphasizes scalability, maintainability, and testability through clear separation of concerns. The offline-first approach ensures users can manage tasks seamlessly regardless of network connectivity, with automatic synchronization when online connectivity is restored.

## Architecture

The application follows Clean Architecture with three distinct layers:

### Domain Layer (Core Business Logic)
- **Entities**: Pure Dart classes representing core business objects (Task, User, Category)
- **Repositories**: Abstract interfaces defining data operations contracts
- **Use Cases**: Single-responsibility classes encapsulating business rules and operations
- **Value Objects**: Immutable objects representing domain concepts (TaskId, Email, Password)

### Data Layer (External Interfaces)
- **Data Sources**: Concrete implementations for Supabase API and Hive local storage
- **Models**: Data transfer objects with JSON serialization capabilities
- **Repositories**: Concrete implementations of domain repository interfaces
- **Mappers**: Conversion utilities between domain entities and data models

### Presentation Layer (UI and State Management)
- **BLoCs**: Business Logic Components managing UI state and user interactions
- **Screens**: Flutter widgets representing complete user interface screens
- **Widgets**: Reusable UI components following design system principles
- **Routes**: GoRouter configuration for declarative navigation

## Components and Interfaces

### Core Domain Entities

```dart
// Task Entity - Core business object
class TaskEntity {
  final TaskId id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final TaskCategory category;
  final TaskPriority priority;
  final int progressPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// User Entity - Authentication and profile
class UserEntity {
  final UserId id;
  final Email email;
  final String displayName;
  final DateTime createdAt;
}

// Category Entity - Task categorization
class CategoryEntity {
  final CategoryId id;
  final String name;
  final Color displayColor;
  final int taskCount;
}
```

### Repository Interfaces

```dart
abstract class TaskRepository {
  Future<List<TaskEntity>> getAllTasks();
  Future<TaskEntity?> getTaskById(TaskId id);
  Future<void> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(TaskId id);
  Future<List<TaskEntity>> getTasksByDateRange(DateTime start, DateTime end);
  Future<List<TaskEntity>> searchTasks(String query);
  Future<void> syncWithRemote();
}

abstract class AuthRepository {
  Future<UserEntity> signUp(Email email, Password password);
  Future<UserEntity> signIn(Email email, Password password);
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<bool> isAuthenticated();
}
```

### Use Cases

```dart
class CreateTaskUseCase {
  final TaskRepository repository;
  
  Future<Result<TaskEntity>> execute(CreateTaskParams params) async {
    // Validation logic
    // Business rules enforcement
    // Repository interaction
  }
}

class GetDashboardStatsUseCase {
  final TaskRepository repository;
  
  Future<DashboardStats> execute() async {
    // Aggregate task statistics
    // Calculate category counts
    // Return dashboard data
  }
}
```

## Data Models

### Local Storage Schema (Hive)

```dart
@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String userId;
  
  @HiveField(2)
  String title;
  
  @HiveField(3)
  String description;
  
  @HiveField(4)
  DateTime dueDate;
  
  @HiveField(5)
  String dueTime;
  
  @HiveField(6)
  String category;
  
  @HiveField(7)
  int priority;
  
  @HiveField(8)
  int progressPercentage;
  
  @HiveField(9)
  DateTime createdAt;
  
  @HiveField(10)
  DateTime updatedAt;
  
  @HiveField(11)
  bool isDeleted;
  
  @HiveField(12)
  bool needsSync;
}
```

### Supabase Schema

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks table
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  due_date DATE,
  due_time TIME,
  category TEXT CHECK (category IN ('ongoing', 'completed', 'in_process', 'canceled')),
  priority INTEGER CHECK (priority BETWEEN 1 AND 5),
  progress_percentage INTEGER CHECK (progress_percentage BETWEEN 0 AND 100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes for performance
CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_category ON tasks(category);
CREATE INDEX idx_tasks_updated_at ON tasks(updated_at);
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Based on the prework analysis, I'll consolidate related properties to eliminate redundancy and create comprehensive correctness properties:

**Property Reflection:**
- Authentication properties (1.1-2.5) can be consolidated into comprehensive authentication behavior properties
- Task CRUD properties (4.2, 6.2, 6.3) can be combined into task persistence properties  
- UI consistency properties (8.1-8.5) can be consolidated into theme and styling consistency
- Performance properties (3.5, 7.1, 10.1, 10.4) can be grouped by performance characteristics
- Sync properties (6.5, 7.4) are redundant and can be combined into one conflict resolution property

**Property 1: Authentication round trip**
*For any* valid email and password combination, creating an account then logging in with those credentials should succeed and grant access to the dashboard
**Validates: Requirements 1.1, 2.1**

**Property 2: Input validation consistency**
*For any* invalid input (malformed emails, short passwords, empty required fields), the system should reject the input and display appropriate validation errors
**Validates: Requirements 1.2, 1.3, 4.3**

**Property 3: Task persistence round trip**
*For any* valid task data, creating a task then retrieving it should return equivalent task information with all fields preserved
**Validates: Requirements 4.2, 6.2, 6.3**

**Property 4: Offline-online sync consistency**
*For any* task operations performed offline, when connectivity is restored, the local and remote data should be synchronized with conflict resolution based on latest timestamps
**Validates: Requirements 6.5, 7.3, 7.4**

**Property 5: Dashboard statistics accuracy**
*For any* set of tasks, the dashboard category counts should equal the actual number of tasks in each category (Ongoing, Completed, In Process, Canceled)
**Validates: Requirements 3.2**

**Property 6: Search and filter correctness**
*For any* search query or date filter, all returned results should match the specified criteria and no matching items should be excluded
**Validates: Requirements 5.2, 5.4**

**Property 7: UI theme consistency**
*For any* screen or component, the applied styling should conform to the centralized theme with consistent colors, typography, and spacing
**Validates: Requirements 8.1, 8.3, 8.4**

**Property 8: Performance bounds**
*For any* database operation or search query, response times should remain within specified limits (50ms for cache reads, 100ms for searches) regardless of dataset size
**Validates: Requirements 3.5, 7.1, 10.1, 10.4**

**Property 9: Session management integrity**
*For any* authentication state change (login, logout, session expiry), the system should maintain data integrity and provide appropriate navigation
**Validates: Requirements 2.3, 9.2, 9.5**

**Property 10: Form population accuracy**
*For any* existing task selected for editing, the form fields should be populated with the current task data exactly as stored
**Validates: Requirements 6.1**

## Error Handling

### Network Error Handling
- **Connection Loss**: Graceful degradation to offline mode with user notification
- **Sync Failures**: Retry mechanism with exponential backoff and user feedback
- **API Errors**: Structured error responses with user-friendly messages
- **Timeout Handling**: Configurable timeout values with fallback to cached data

### Data Validation Errors
- **Client-side Validation**: Immediate feedback for form validation errors
- **Server-side Validation**: Handling of backend validation failures
- **Data Integrity**: Validation of data consistency between local and remote storage
- **Constraint Violations**: Proper handling of database constraint violations

### Authentication Errors
- **Invalid Credentials**: Clear error messaging for authentication failures
- **Session Expiry**: Automatic token refresh or re-authentication prompts
- **Permission Errors**: Appropriate handling of unauthorized access attempts
- **Account State Issues**: Handling of disabled or suspended accounts

### Storage Errors
- **Disk Space**: Graceful handling of insufficient storage space
- **Corruption**: Detection and recovery from corrupted local data
- **Migration Errors**: Safe handling of database schema migrations
- **Backup Failures**: Error handling for data backup operations

## Testing Strategy

### Dual Testing Approach

The application will implement both unit testing and property-based testing to ensure comprehensive coverage:

**Unit Testing**:
- Specific examples demonstrating correct behavior
- Edge cases and boundary conditions
- Integration points between components
- Error condition handling
- Mock-based testing for external dependencies

**Property-Based Testing**:
- Universal properties verified across all inputs using **fast_check** library for Dart
- Each property-based test configured to run minimum 100 iterations
- Tests tagged with comments referencing design document properties
- Format: `**Feature: flutter-todo-app, Property {number}: {property_text}**`

### Testing Framework Configuration

**Unit Testing**: 
- Flutter's built-in `flutter_test` package
- Mockito for dependency mocking
- Integration testing with `integration_test` package

**Property-Based Testing**:
- `fast_check` library for Dart property-based testing
- Custom generators for domain objects (Task, User, Category)
- Shrinking capabilities for minimal failing examples

### Test Categories

**Domain Layer Tests**:
- Entity validation and business rules
- Use case execution and error handling
- Value object immutability and equality

**Data Layer Tests**:
- Repository implementations
- Data source operations
- Model serialization/deserialization
- Mapper functionality

**Presentation Layer Tests**:
- BLoC state transitions
- Widget rendering and interactions
- Navigation flow testing
- Theme application verification

### Performance Testing

**Load Testing**:
- Database operations with large datasets (10,000+ tasks)
- Memory usage monitoring during bulk operations
- UI responsiveness under heavy data loads

**Benchmark Testing**:
- Cache read operations (target: <50ms)
- Search operations (target: <100ms)
- Sync operation performance
- App startup time measurement

### Integration Testing

**End-to-End Scenarios**:
- Complete user workflows (signup → task creation → sync)
- Offline-online transition scenarios
- Cross-platform consistency testing
- Real device testing on multiple form factors

**API Integration**:
- Supabase authentication flow testing
- Data synchronization accuracy
- Error handling for API failures
- Network condition simulation

### Continuous Testing

**Automated Test Execution**:
- Pre-commit hooks for unit tests
- CI/CD pipeline integration
- Automated property-based test execution
- Performance regression detection

**Test Data Management**:
- Isolated test environments
- Test data cleanup and setup
- Deterministic test execution
- Cross-test data isolation