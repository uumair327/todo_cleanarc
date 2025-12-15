# TaskFlow - Clean Architecture

**Package**: `todo_cleanarc` | **Version**: 1.0.0+1

A production-ready, offline-first task management application built with Flutter using Clean Architecture principles. TaskFlow provides comprehensive task management features with seamless offline-online synchronization powered by Supabase.

## Features

- **User Authentication**: Secure email/password authentication with session management
- **Task Management**: Create, read, update, and delete tasks with rich metadata
- **Offline-First**: Full functionality without internet connectivity
- **Automatic Sync**: Seamless synchronization when connectivity is restored
- **Dashboard Analytics**: Visual statistics and insights about your tasks
- **Category Management**: Organize tasks by status (Ongoing, Completed, In Process, Canceled)
- **Search & Filter**: Quickly find tasks by title, description, or date
- **Cross-Platform**: Runs on iOS, Android, Web, Windows, macOS, and Linux

## Architecture

This project follows Clean Architecture principles with three distinct layers:

### Domain Layer (Core Business Logic)
- **Entities**: Pure Dart classes representing core business objects
- **Repositories**: Abstract interfaces defining data operations
- **Use Cases**: Single-responsibility classes encapsulating business rules
- **Value Objects**: Immutable objects with validation (Email, Password, TaskId, etc.)

### Data Layer (External Interfaces)
- **Data Sources**: Concrete implementations for Supabase API and Hive local storage
- **Models**: Data transfer objects with JSON serialization
- **Repositories**: Concrete implementations of domain repository interfaces
- **Mappers**: Conversion utilities between entities and models

### Presentation Layer (UI & State Management)
- **BLoCs**: Business Logic Components managing UI state
- **Screens**: Flutter widgets representing complete UI screens
- **Widgets**: Reusable UI components following design system
- **Routes**: GoRouter configuration for declarative navigation

## Tech Stack

- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **flutter_bloc**: State management with BLoC pattern
- **hydrated_bloc**: State persistence for offline support
- **Hive**: Fast, lightweight local database
- **Supabase**: Backend-as-a-Service for authentication and data sync
- **GoRouter**: Declarative routing and navigation
- **GetIt**: Dependency injection container
- **Dartz**: Functional programming utilities (Either, Option)

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Supabase account and project

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd todo_cleanarc
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code for Hive adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Configure Supabase (Required):
   - See detailed instructions in `SETUP_GUIDE.md`
   - Create a Supabase project at https://supabase.com
   - Run the SQL script from `scripts/supabase_setup.sql`
   - Update `lib/core/constants/app_constants.dart` with your credentials

5. Run the app:
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

For production deployment, see `PRODUCTION_CHECKLIST.md`.

## Project Structure

```
lib/
├── core/                      # Core functionality shared across features
│   ├── constants/            # App-wide constants
│   ├── domain/               # Core domain objects (enums, value objects)
│   ├── error/                # Error handling (failures, exceptions)
│   ├── network/              # Network connectivity utilities
│   ├── router/               # Navigation and routing configuration
│   ├── services/             # Core services (DI, sync, connectivity)
│   ├── theme/                # App theme and styling
│   ├── utils/                # Utility functions and helpers
│   └── widgets/              # Reusable UI components
├── feature/                   # Feature modules
│   ├── auth/                 # Authentication feature
│   │   ├── data/            # Data sources, models, repositories
│   │   ├── domain/          # Entities, repositories, use cases
│   │   └── presentation/    # BLoCs, screens, widgets
│   └── todo/                 # Todo/Task management feature
│       ├── data/            # Data sources, models, repositories
│       ├── domain/          # Entities, repositories, use cases
│       └── presentation/    # BLoCs, screens, widgets
└── main.dart                 # App entry point
```

## Testing

The project includes comprehensive testing:

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Property-Based Tests
```bash
flutter test test/property_based/
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Performance

The app is optimized for performance:

- **Database Operations**: <50ms for cache reads
- **Search Operations**: <100ms regardless of dataset size
- **Large Datasets**: Efficiently handles 10,000+ tasks
- **Memory Management**: Automatic cleanup and garbage collection
- **Lazy Loading**: Pagination for large task lists

## Offline Support

The app provides full offline functionality:

- All CRUD operations work offline
- Changes are queued for synchronization
- Automatic sync when connectivity is restored
- Conflict resolution using timestamp-based strategy
- Visual feedback for sync status

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Code Quality

The project maintains high code quality standards:

- Comprehensive linting rules (see `analysis_options.yaml`)
- Clean Architecture principles
- SOLID principles
- Dependency injection
- Error handling with Either type
- Immutable data structures

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Supabase team for the excellent backend service
- Clean Architecture community for best practices
- All contributors and supporters

## Documentation

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)**: Complete setup instructions including Supabase configuration
- **[PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md)**: Pre-deployment checklist for all platforms
- **[integration_test/README.md](integration_test/README.md)**: Integration testing documentation
- **[scripts/supabase_setup.sql](scripts/supabase_setup.sql)**: Database schema for Supabase

## Platform Support

| Platform | Status | Package/Bundle ID |
|----------|--------|-------------------|
| Android  | ✅ Ready | com.example.todo_cleanarc |
| iOS      | ✅ Ready | com.example.todo_cleanarc |
| Web      | ✅ Ready | - |
| Windows  | ✅ Ready | - |
| macOS    | ✅ Ready | com.example.todo_cleanarc |
| Linux    | ✅ Ready | com.example.todo_cleanarc |

## Quick Start for Production

1. **Setup Supabase**: Follow `SETUP_GUIDE.md`
2. **Update Credentials**: Edit `lib/core/constants/app_constants.dart`
3. **Build for Platform**:
   ```bash
   # Android (Play Store)
   flutter build appbundle --release
   
   # iOS (App Store)
   flutter build ipa --release
   
   # Web
   flutter build web --release
   ```
4. **Deploy**: Follow platform-specific instructions in `PRODUCTION_CHECKLIST.md`

## Support

For issues, questions, or contributions:
- Check existing documentation in the repository
- Review integration tests for usage examples
- Consult Supabase documentation for backend issues

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)
