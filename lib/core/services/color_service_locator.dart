import '../domain/repositories/color_repository.dart';
import '../domain/repositories/theme_repository.dart';
import '../infrastructure/color/color_storage_impl.dart';
import '../infrastructure/theme/theme_storage_impl.dart';
import 'color_resolver_service.dart';
import 'color_resolver_service_impl.dart';
import 'theme_provider_service.dart';
import 'theme_provider_service_impl.dart';

/// Service locator for color and theme services
/// 
/// This class provides a centralized way to create and manage instances
/// of color and theme services with proper dependency injection.
class ColorServiceLocator {
  static ColorServiceLocator? _instance;
  
  // Service instances
  ColorRepository? _colorRepository;
  ThemeRepository? _themeRepository;
  ColorResolverService? _colorResolverService;
  ThemeProviderService? _themeProviderService;
  
  // Initialization state
  bool _initialized = false;

  ColorServiceLocator._();

  /// Gets the singleton instance of the service locator
  static ColorServiceLocator get instance {
    _instance ??= ColorServiceLocator._();
    return _instance!;
  }

  /// Initializes all services with their dependencies
  /// 
  /// Must be called before using any services. Sets up the dependency
  /// injection chain and initializes storage implementations.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    // Initialize infrastructure layer
    _colorRepository = ColorStorageImpl();
    
    _themeRepository = ThemeStorageImpl();
    await (_themeRepository as ThemeStorageImpl).initialize();

    // Initialize application layer
    _colorResolverService = ColorResolverServiceImpl(
      colorRepository: _colorRepository!,
    );

    // Get default theme for theme provider initialization
    final defaultThemeResult = await _themeRepository!.getDefaultTheme();
    final defaultTheme = defaultThemeResult.fold(
      (failure) => throw Exception('Failed to get default theme: $failure'),
      (theme) => theme,
    );

    _themeProviderService = ThemeProviderServiceImpl(
      themeRepository: _themeRepository!,
      initialTheme: defaultTheme,
    );

    // Initialize the theme provider service
    final initResult = await _themeProviderService!.initialize();
    initResult.fold(
      (failure) => throw Exception('Failed to initialize theme provider: $failure'),
      (_) => null,
    );

    _initialized = true;
  }

  /// Gets the color repository instance
  ColorRepository get colorRepository {
    _ensureInitialized();
    return _colorRepository!;
  }

  /// Gets the theme repository instance
  ThemeRepository get themeRepository {
    _ensureInitialized();
    return _themeRepository!;
  }

  /// Gets the color resolver service instance
  ColorResolverService get colorResolverService {
    _ensureInitialized();
    return _colorResolverService!;
  }

  /// Gets the theme provider service instance
  ThemeProviderService get themeProviderService {
    _ensureInitialized();
    return _themeProviderService!;
  }

  /// Disposes of all services and clears the singleton instance
  /// 
  /// Should be called when the application is shutting down to
  /// properly clean up resources.
  void dispose() {
    _themeProviderService?.dispose();
    _colorResolverService?.clearCache();
    
    _colorRepository = null;
    _themeRepository = null;
    _colorResolverService = null;
    _themeProviderService = null;
    
    _initialized = false;
    _instance = null;
  }

  /// Resets all services (useful for testing)
  /// 
  /// Disposes current services and allows for re-initialization
  /// with fresh instances.
  Future<void> reset() async {
    dispose();
    await initialize();
  }

  /// Ensures the service locator is initialized before use
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('ColorServiceLocator must be initialized before use. Call initialize() first.');
    }
  }

  /// Checks if the service locator is initialized
  bool get isInitialized => _initialized;
}