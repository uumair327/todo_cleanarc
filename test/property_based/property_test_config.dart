/// Configuration for property-based testing framework
class PropertyTestConfig {
  /// Default number of iterations for property-based tests
  static const int defaultIterations = 100;
  
  /// Minimum number of iterations for property-based tests
  static const int minIterations = 10;
  
  /// Maximum number of iterations for property-based tests
  static const int maxIterations = 10000;
  
  /// Default random seed for reproducible tests
  static const int defaultSeed = 42;
  
  /// Maximum number of failures to show in test reports
  static const int maxFailuresToShow = 5;
  
  /// Feature name for the Flutter Todo App
  static const String featureName = 'flutter-todo-app';
  
  /// Property test configuration for specific test types
  static const Map<String, PropertyTestSettings> testSettings = {
    'authentication': PropertyTestSettings(
      iterations: 100,
      seed: 42,
      timeout: Duration(seconds: 30),
    ),
    'task_persistence': PropertyTestSettings(
      iterations: 150,
      seed: 123,
      timeout: Duration(seconds: 45),
    ),
    'sync_operations': PropertyTestSettings(
      iterations: 200,
      seed: 456,
      timeout: Duration(minutes: 1),
    ),
    'ui_consistency': PropertyTestSettings(
      iterations: 50,
      seed: 789,
      timeout: Duration(seconds: 20),
    ),
    'performance': PropertyTestSettings(
      iterations: 100,
      seed: 101112,
      timeout: Duration(minutes: 2),
    ),
  };
  
  /// Gets test settings for a specific test type
  static PropertyTestSettings getSettingsFor(String testType) {
    return testSettings[testType] ?? const PropertyTestSettings();
  }
}

/// Settings for individual property-based tests
class PropertyTestSettings {
  final int iterations;
  final int? seed;
  final Duration timeout;
  
  const PropertyTestSettings({
    this.iterations = PropertyTestConfig.defaultIterations,
    this.seed,
    this.timeout = const Duration(seconds: 30),
  });
}

/// Property test metadata for tracking requirements validation
class PropertyTestMetadata {
  final String featureName;
  final int propertyNumber;
  final String propertyText;
  final String validates;
  final String description;
  
  const PropertyTestMetadata({
    required this.featureName,
    required this.propertyNumber,
    required this.propertyText,
    required this.validates,
    required this.description,
  });
  
  /// Creates metadata for flutter-todo-app properties
  factory PropertyTestMetadata.forTodoApp({
    required int propertyNumber,
    required String propertyText,
    required String validates,
    required String description,
  }) {
    return PropertyTestMetadata(
      featureName: PropertyTestConfig.featureName,
      propertyNumber: propertyNumber,
      propertyText: propertyText,
      validates: validates,
      description: description,
    );
  }
  
  /// Formats the property test comment as required by the design document
  String get formattedComment {
    return '**Feature: $featureName, Property $propertyNumber: $propertyText**';
  }
}