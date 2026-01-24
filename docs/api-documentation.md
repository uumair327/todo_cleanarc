# API Documentation

This document provides comprehensive API documentation for the Flutter Todo App's core components.

## Table of Contents

1. [Domain Layer](#domain-layer)
   - [Use Cases](#use-cases)
   - [Entities](#entities)
   - [Value Objects](#value-objects)
2. [Data Layer](#data-layer)
   - [Repositories](#repositories)
   - [Data Sources](#data-sources)
3. [Presentation Layer](#presentation-layer)
   - [BLoCs](#blocs)
   - [Widgets](#widgets)
4. [Core Services](#core-services)

---

## Domain Layer

### Use Cases

#### CreateTaskUseCase

Creates a new task in the system.

**Constructor:**
```dart
CreateTaskUseCase(TaskRepository repository)
```

**Method:**
```dart
ResultVoid call(TaskEntity task)
```

**Parameters:**
- `task`: The task entity to create

**Returns:**
- `Right(null)` on success
- `Left(CacheFailure)` if local storage fails

**Example:**
```dart
final createTask = CreateTaskUseCase(taskRepository);
final result = await createTask(newTask);
```

---

#### SearchTasksUseCase

Searches for tasks matching a query string.

**Constructor:**
```dart
SearchTasksUseCase(TaskRepository repository)
```

**Method:**
```dart
ResultFuture<List<TaskEntity>> call(String query)
```

**Parameters:**
- `query`: Search string (case-insensitive). Empty query returns all tasks.

**Returns:**
- `Right(List<TaskEntity>)` with matching tasks
- `Left(CacheFailure)` if search fails

**Search Behavior:**
- Case-insensitive
- Searches title and description
- Partial matches included
- Empty query returns all tasks

**Example:**
```dart
final searchTasks = SearchTasksUseCase(taskRepository);
final result = await searchTasks('project');
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (tasks) => print('Found ${tasks.length} tasks'),
);
```

---

#### GetDashboardStatsUseCase

Retrieves dashboard statistics including task counts by category.

**Constructor:**
```dart
GetDashboardStatsUseCase(TaskRepository repository)
```

**Method:**
```dart
ResultFuture<DashboardStats> call()
```

**Returns:**
- `Right(DashboardStats)` with statistics
- `Left(CacheFailure)` if retrieval fails

**DashboardStats Properties:**
- `ongoingCount`: Number of ongoing tasks
- `completedCount`: Number of completed tasks
- `inProcessCount`: Number of in-process tasks
- `canceledCount`: Number of canceled tasks
- `recentTasks`: List of 5 most recent tasks

**Example:**
```dart
final getStats = GetDashboardStatsUseCase(taskRepository);
final result = await getStats();
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (stats) => print('Ongoing: ${stats.ongoingCount}'),
);
```

---

### Entities

#### TaskEntity

Represents a task in the domain layer.

**Properties:**
- `id`: TaskId - Unique identifier
- `userId`: UserId - Owner's user ID
- `title`: String - Task title (required)
- `description`: String - Task description
- `dueDate`: DateTime - Due date
- `dueTime`: DomainTime - Due time
- `category`: TaskCategory - Task category (ongoing, completed, in_process, canceled)
- `priority`: TaskPriority - Priority level (low, medium, high, urgent)
- `progressPercentage`: int - Progress (0-100)
- `createdAt`: DateTime - Creation timestamp
- `updatedAt`: DateTime - Last update timestamp
- `isDeleted`: bool - Soft delete flag

**Methods:**
```dart
TaskEntity copyWith({...}) // Create a copy with updated fields
```

**Example:**
```dart
final task = TaskEntity(
  id: TaskId.generate(),
  userId: UserId.fromString('user123'),
  title: 'Complete documentation',
  description: 'Write API docs',
  dueDate: DateTime.now().add(Duration(days: 7)),
  dueTime: DomainTime(hour: 17, minute: 0),
  category: TaskCategory.ongoing,
  priority: TaskPriority.high,
  progressPercentage: 0,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

---

### Value Objects

#### Email

Represents a validated email address.

**Constructor:**
```dart
Email.fromString(String value) // Throws ArgumentError if invalid
```

**Properties:**
- `value`: String - The validated email address (lowercase, trimmed)

**Validation Rules:**
- Must contain @ symbol
- Must have local part before @
- Must have domain after @
- Must have valid TLD
- Automatically normalized (lowercase, trimmed)

**Example:**
```dart
try {
  final email = Email.fromString('user@example.com');
  print(email.value); // 'user@example.com'
} catch (e) {
  print('Invalid email: $e');
}
```

---

#### Password

Represents a validated password.

**Constructor:**
```dart
Password.fromString(String value) // Throws ArgumentError if invalid
```

**Properties:**
- `value`: String - The validated password

**Validation Rules:**
- Minimum 6 characters
- No maximum length

**Example:**
```dart
try {
  final password = Password.fromString('securePass123');
  // Use password.value for authentication
} catch (e) {
  print('Invalid password: $e');
}
```

---

## Data Layer

### Repositories

#### TaskRepositoryImpl

Implementation of TaskRepository with offline-first architecture.

**Constructor:**
```dart
TaskRepositoryImpl({
  required HiveTaskDataSource hiveDataSource,
  required SupabaseTaskDataSource supabaseDataSource,
  required NetworkInfo networkInfo,
})
```

**Key Methods:**

##### createTask
```dart
ResultVoid createTask(TaskEntity task)
```
Creates a task locally first, then syncs to remote if connected.

##### getAllTasks
```dart
ResultFuture<List<TaskEntity>> getAllTasks()
```
Returns all tasks from local storage. Syncs with remote if connected.

##### searchTasks
```dart
ResultFuture<List<TaskEntity>> searchTasks(String query)
```
Searches tasks in local storage.

##### syncWithRemote
```dart
ResultVoid syncWithRemote()
```
Synchronizes local changes with remote server. Resolves conflicts using "last write wins".

**Offline-First Behavior:**
1. All write operations save locally first
2. Remote sync attempted if connected
3. Failed syncs queued for later
4. Automatic conflict resolution

---

## Presentation Layer

### BLoCs

#### TaskListBloc

Manages task list state and operations.

**Events:**
- `LoadTasks`: Load all tasks
- `RefreshTasks`: Refresh task list
- `DeleteTask`: Delete a task
- `UpdateTaskCategory`: Update task category
- `SearchTasks`: Search tasks
- `FilterTasksByCategory`: Filter by category
- `SyncTasks`: Sync with remote

**States:**
- `TaskListInitial`: Initial state
- `TaskListLoading`: Loading tasks
- `TaskListLoaded`: Tasks loaded successfully
- `TaskListError`: Error occurred
- `TaskListSyncing`: Syncing with remote

**Example:**
```dart
// Load tasks
context.read<TaskListBloc>().add(const LoadTasks());

// Search tasks
context.read<TaskListBloc>().add(SearchTasks(query: 'project'));

// Delete task
context.read<TaskListBloc>().add(DeleteTask(taskId: task.id));
```

---

#### TaskFormBloc

Manages task creation and editing.

**Events:**
- `TitleChanged`: Update title
- `DescriptionChanged`: Update description
- `DueDateChanged`: Update due date
- `DueTimeChanged`: Update due time
- `CategoryChanged`: Update category
- `PriorityChanged`: Update priority
- `ProgressChanged`: Update progress
- `SubmitTask`: Submit the form
- `LoadTaskForEdit`: Load existing task for editing

**States:**
- `TaskFormInitial`: Initial state
- `TaskFormEditing`: Form is being edited
- `TaskFormSubmitting`: Submitting form
- `TaskFormSuccess`: Form submitted successfully
- `TaskFormError`: Form submission failed

**Example:**
```dart
// Update title
context.read<TaskFormBloc>().add(TitleChanged(title: 'New Title'));

// Submit form
context.read<TaskFormBloc>().add(const SubmitTask());
```

---

### Widgets

#### CustomButton

A customizable button following the design system.

**Constructor:**
```dart
CustomButton({
  required String text,
  VoidCallback? onPressed,
  ButtonVariant variant = ButtonVariant.primary,
  ButtonSize size = ButtonSize.medium,
  Widget? icon,
  bool isLoading = false,
  bool isFullWidth = true,
  Color? backgroundColor,
  Color? foregroundColor,
  EdgeInsets? padding,
})
```

**Parameters:**
- `text`: Button text
- `onPressed`: Callback (null = disabled)
- `variant`: Style variant (primary, secondary, outlined, text)
- `size`: Size (small, medium, large)
- `icon`: Optional leading icon
- `isLoading`: Show loading spinner
- `isFullWidth`: Take full width
- `backgroundColor`: Custom background color
- `foregroundColor`: Custom text color
- `padding`: Custom padding

**Example:**
```dart
CustomButton(
  text: 'Save Task',
  variant: ButtonVariant.primary,
  icon: Icon(Icons.save),
  isLoading: isSubmitting,
  onPressed: () => saveTask(),
)
```

---

#### CustomTextField

A customizable text input field.

**Constructor:**
```dart
CustomTextField({
  required TextEditingController controller,
  String? label,
  String? hint,
  String? errorText,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  Widget? prefixIcon,
  Widget? suffixIcon,
  int? maxLines = 1,
  int? maxLength,
  bool enabled = true,
  ValueChanged<String>? onChanged,
  VoidCallback? onTap,
})
```

**Example:**
```dart
CustomTextField(
  controller: titleController,
  label: 'Task Title',
  hint: 'Enter task title',
  errorText: titleError,
  prefixIcon: Icon(Icons.title),
  onChanged: (value) => validateTitle(value),
)
```

---

## Core Services

### ErrorHandler

Provides error handling utilities and user-friendly messages.

**Static Methods:**

#### executeWithRetry
```dart
static Future<T> executeWithRetry<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration baseDelay = Duration(seconds: 1),
  Duration maxDelay = Duration(seconds: 10),
  bool Function(dynamic error)? shouldRetry,
})
```

Executes an operation with exponential backoff retry.

**Example:**
```dart
final result = await ErrorHandler.executeWithRetry(
  () => apiCall(),
  maxRetries: 3,
  shouldRetry: (error) => error is NetworkException,
);
```

#### handleException
```dart
static Failure handleException(dynamic exception)
```

Converts exceptions to user-friendly failure messages.

**Example:**
```dart
try {
  await operation();
} catch (e) {
  final failure = ErrorHandler.handleException(e);
  showError(failure.message);
}
```

---

### BackgroundSyncService

Manages automatic background synchronization.

**Methods:**

#### startPeriodicSync
```dart
void startPeriodicSync({Duration interval = const Duration(minutes: 15)})
```

Starts periodic background sync.

#### stopPeriodicSync
```dart
void stopPeriodicSync()
```

Stops periodic background sync.

#### syncNow
```dart
Future<void> syncNow()
```

Triggers immediate sync.

**Example:**
```dart
final syncService = sl<BackgroundSyncService>();
syncService.startPeriodicSync(interval: Duration(minutes: 10));
```

---

### ConnectivityService

Monitors network connectivity.

**Properties:**
- `isConnected`: Stream<bool> - Connectivity status stream

**Methods:**

#### checkConnectivity
```dart
Future<bool> checkConnectivity()
```

Checks current connectivity status.

**Example:**
```dart
final connectivityService = sl<ConnectivityService>();
final isConnected = await connectivityService.checkConnectivity();

// Listen to connectivity changes
connectivityService.isConnected.listen((connected) {
  if (connected) {
    print('Back online');
  } else {
    print('Offline');
  }
});
```

---

## Error Handling

### Failure Types

All failures extend the `Failure` base class and include a user-friendly message.

#### NetworkFailure
Network-related errors (no connection, timeout, DNS errors).

#### ServerFailure
Server-related errors (500, 404, 403, 401, 400).

#### CacheFailure
Local storage errors (disk full, corruption).

#### AuthenticationFailure
Authentication errors (invalid credentials, session expired).

#### ValidationFailure
Input validation errors (invalid email, weak password).

### Error Messages

All error messages are user-friendly and provide actionable guidance:

- **Network errors**: "No internet connection. Please check your network settings and try again."
- **Server errors**: "Server is temporarily unavailable. Please try again later."
- **Auth errors**: "Invalid email or password. Please check your credentials and try again."
- **Validation errors**: "Please enter a valid email address."

---

## Testing

### Unit Testing

All use cases, repositories, and BLoCs have comprehensive unit tests.

**Example:**
```dart
test('should create task successfully', () async {
  // Arrange
  when(mockRepository.createTask(any))
      .thenAnswer((_) async => const Right(null));

  // Act
  final result = await useCase(testTask);

  // Assert
  expect(result.isRight(), true);
  verify(mockRepository.createTask(testTask));
});
```

### Property-Based Testing

Critical correctness properties are tested with 100+ iterations.

**Example:**
```dart
test('Search returns only matching tasks', () async {
  for (int i = 0; i < 100; i++) {
    final tasks = generateRandomTasks();
    final query = 'test';
    final result = await searchTasks(query);
    
    // Verify all results match query
    expect(result.every((t) => t.title.contains(query)), true);
  }
});
```

---

## Best Practices

### 1. Always Handle Errors

```dart
final result = await useCase(params);
result.fold(
  (failure) => showError(failure.message),
  (data) => showSuccess(data),
);
```

### 2. Use Value Objects for Validation

```dart
try {
  final email = Email.fromString(emailInput);
  final password = Password.fromString(passwordInput);
  await signIn(email, password);
} catch (e) {
  showValidationError(e.toString());
}
```

### 3. Leverage Offline-First

```dart
// Operations work offline automatically
await createTask(newTask); // Saves locally, syncs when online
```

### 4. Use BLoC for State Management

```dart
BlocBuilder<TaskListBloc, TaskListState>(
  builder: (context, state) {
    if (state is TaskListLoading) return LoadingWidget();
    if (state is TaskListError) return ErrorWidget(state.message);
    if (state is TaskListLoaded) return TaskList(state.tasks);
    return Container();
  },
)
```

### 5. Follow Clean Architecture

- Domain layer: Pure Dart, no Flutter dependencies
- Data layer: Implements domain interfaces
- Presentation layer: Depends on domain abstractions

---

## Additional Resources

- [Architecture Decision Records](./architecture-decisions.md)
- [Testing Guide](../test/README.md)
- [Integration Tests](../integration_test/README.md)
- [Property-Based Tests](../test/property_based/README.md)
