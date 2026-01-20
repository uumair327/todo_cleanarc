# Design Document: Color System Centralization

## Overview

This design implements a comprehensive color centralization system for the Flutter Todo application following clean architecture principles and SOLID design patterns. The system eliminates hardcoded colors, introduces semantic color tokens, and provides a theme-aware color management architecture that supports dynamic theming while maintaining performance and accessibility standards.

The design leverages Flutter's Material 3 ColorScheme as the foundation while extending it with custom semantic colors and implementing a clean architecture approach with proper separation of concerns.

## Architecture

### Layer Separation

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   UI Widgets    │  │     Screens     │  │    Themes    │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ Theme Provider  │  │ Color Resolver  │  │ Theme Notif. │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ Color Entities  │  │ Theme Entities  │  │ Color Rules  │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Infrastructure Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ Color Storage   │  │ Theme Storage   │  │ Validators   │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Flow

The architecture follows the dependency inversion principle where:
- Presentation layer depends on abstractions from the application layer
- Application layer depends on abstractions from the domain layer  
- Infrastructure layer implements domain abstractions
- No layer depends on concrete implementations from outer layers

## Components and Interfaces

### Domain Layer

#### Color Entities

```dart
// Core color value object
class AppColor {
  final int value;
  final String semanticName;
  final double opacity;
  
  const AppColor({
    required this.value,
    required this.semanticName,
    this.opacity = 1.0,
  });
  
  AppColor withOpacity(double opacity) => AppColor(
    value: value,
    semanticName: semanticName,
    opacity: opacity,
  );
}

// Semantic color token
class ColorToken {
  final String name;
  final AppColor lightValue;
  final AppColor darkValue;
  final ColorRole role;
  
  const ColorToken({
    required this.name,
    required this.lightValue,
    required this.darkValue,
    required this.role,
  });
}

enum ColorRole {
  surface,
  onSurface,
  primary,
  onPrimary,
  secondary,
  onSecondary,
  error,
  onError,
  success,
  onSuccess,
  warning,
  onWarning,
  info,
  onInfo,
}
```

#### Theme Entities

```dart
// Theme configuration
class AppThemeConfig {
  final String name;
  final ThemeMode mode;
  final Map<String, ColorToken> colorTokens;
  final bool isSystemDefault;
  
  const AppThemeConfig({
    required this.name,
    required this.mode,
    required this.colorTokens,
    this.isSystemDefault = false,
  });
}

// Theme state
class ThemeState {
  final AppThemeConfig currentTheme;
  final List<AppThemeConfig> availableThemes;
  final bool isSystemThemeEnabled;
  
  const ThemeState({
    required this.currentTheme,
    required this.availableThemes,
    this.isSystemThemeEnabled = true,
  });
}
```

#### Repository Interfaces

```dart
abstract class ColorRepository {
  Future<Map<String, ColorToken>> getColorTokens(ThemeMode mode);
  Future<void> validateColorTokens(Map<String, ColorToken> tokens);
  Future<bool> checkAccessibilityCompliance(ColorToken foreground, ColorToken background);
}

abstract class ThemeRepository {
  Future<AppThemeConfig> getCurrentTheme();
  Future<void> saveTheme(AppThemeConfig theme);
  Future<List<AppThemeConfig>> getAvailableThemes();
  Stream<ThemeMode> watchSystemTheme();
}
```

### Application Layer

#### Theme Provider Service

```dart
abstract class ThemeProviderService {
  Stream<ThemeState> get themeStream;
  ThemeState get currentTheme;
  
  Future<void> setTheme(String themeName);
  Future<void> toggleSystemTheme(bool enabled);
  Future<void> addCustomTheme(AppThemeConfig theme);
  
  AppColor getColor(String tokenName);
  AppColor getOnColor(String surfaceTokenName);
  Map<String, AppColor> getAllColors();
}

class ThemeProviderServiceImpl implements ThemeProviderService {
  final ColorRepository _colorRepository;
  final ThemeRepository _themeRepository;
  final StreamController<ThemeState> _themeController;
  
  // Implementation details...
}
```

#### Color Resolver Service

```dart
abstract class ColorResolverService {
  AppColor resolveSemanticColor(String semanticName, ThemeMode mode);
  AppColor resolveCategoryColor(String category, ThemeMode mode);
  AppColor resolveStateColor(String state, ThemeMode mode);
  
  Future<void> validateColorCombination(AppColor foreground, AppColor background);
  Map<String, AppColor> resolveColorPalette(ThemeMode mode);
}
```

### Infrastructure Layer

#### Color Storage Implementation

```dart
class ColorStorageImpl implements ColorRepository {
  static const Map<String, ColorToken> _lightColorTokens = {
    'surface': ColorToken(
      name: 'surface',
      lightValue: AppColor(value: 0xFFFFFFFF, semanticName: 'surface'),
      darkValue: AppColor(value: 0xFF121212, semanticName: 'surface'),
      role: ColorRole.surface,
    ),
    'onSurface': ColorToken(
      name: 'onSurface',
      lightValue: AppColor(value: 0xFF000000, semanticName: 'onSurface'),
      darkValue: AppColor(value: 0xFFFFFFFF, semanticName: 'onSurface'),
      role: ColorRole.onSurface,
    ),
    // ... additional tokens
  };
  
  @override
  Future<Map<String, ColorToken>> getColorTokens(ThemeMode mode) async {
    return _lightColorTokens; // Return appropriate tokens based on mode
  }
  
  @override
  Future<bool> checkAccessibilityCompliance(
    ColorToken foreground, 
    ColorToken background
  ) async {
    // WCAG AA compliance checking logic
    final contrastRatio = _calculateContrastRatio(foreground, background);
    return contrastRatio >= 4.5; // AA standard
  }
}
```

### Presentation Layer

#### Theme Extension

```dart
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  final AppColor surfacePrimary;
  final AppColor surfaceSecondary;
  final AppColor surfaceTertiary;
  final AppColor ongoingTask;
  final AppColor inProcessTask;
  final AppColor completedTask;
  final AppColor canceledTask;
  final AppColor successBackground;
  final AppColor warningBackground;
  final AppColor errorBackground;
  final AppColor infoBackground;
  
  const AppColorExtension({
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceTertiary,
    required this.ongoingTask,
    required this.inProcessTask,
    required this.completedTask,
    required this.canceledTask,
    required this.successBackground,
    required this.warningBackground,
    required this.errorBackground,
    required this.infoBackground,
  });
  
  @override
  AppColorExtension copyWith({...}) { /* implementation */ }
  
  @override
  AppColorExtension lerp(ThemeExtension<AppColorExtension>? other, double t) {
    /* implementation */
  }
}
```

#### Theme Configuration

```dart
class AppThemeData {
  static ThemeData lightTheme(AppColorExtension colorExtension) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colorExtension.ongoingTask.toFlutterColor(),
        brightness: Brightness.light,
      ),
      extensions: [colorExtension],
      // Additional theme configurations
    );
  }
  
  static ThemeData darkTheme(AppColorExtension colorExtension) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colorExtension.ongoingTask.toFlutterColor(),
        brightness: Brightness.dark,
      ),
      extensions: [colorExtension],
      // Additional theme configurations
    );
  }
}
```

#### Widget Color Access Pattern

```dart
// Extension for easy color access in widgets
extension BuildContextColorExtension on BuildContext {
  AppColorExtension get appColors {
    return Theme.of(this).extension<AppColorExtension>()!;
  }
  
  ColorScheme get colorScheme {
    return Theme.of(this).colorScheme;
  }
}

// Usage in widgets
class ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.appColors.surfacePrimary.toFlutterColor(),
      child: Text(
        'Example',
        style: TextStyle(
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }
}
```

## Data Models

### Color Token Registry

```dart
class ColorTokenRegistry {
  static const Map<String, ColorToken> tokens = {
    // Surface colors
    'surfacePrimary': ColorToken(
      name: 'surfacePrimary',
      lightValue: AppColor(value: 0xFFFFFFFF, semanticName: 'surfacePrimary'),
      darkValue: AppColor(value: 0xFF121212, semanticName: 'surfacePrimary'),
      role: ColorRole.surface,
    ),
    'surfaceSecondary': ColorToken(
      name: 'surfaceSecondary',
      lightValue: AppColor(value: 0xFFFAFAFA, semanticName: 'surfaceSecondary'),
      darkValue: AppColor(value: 0xFF1E1E1E, semanticName: 'surfaceSecondary'),
      role: ColorRole.surface,
    ),
    
    // Task category colors
    'ongoingTask': ColorToken(
      name: 'ongoingTask',
      lightValue: AppColor(value: 0xFF2196F3, semanticName: 'ongoingTask'),
      darkValue: AppColor(value: 0xFF64B5F6, semanticName: 'ongoingTask'),
      role: ColorRole.primary,
    ),
    'inProcessTask': ColorToken(
      name: 'inProcessTask',
      lightValue: AppColor(value: 0xFFFFC107, semanticName: 'inProcessTask'),
      darkValue: AppColor(value: 0xFFFFD54F, semanticName: 'inProcessTask'),
      role: ColorRole.secondary,
    ),
    'completedTask': ColorToken(
      name: 'completedTask',
      lightValue: AppColor(value: 0xFF4CAF50, semanticName: 'completedTask'),
      darkValue: AppColor(value: 0xFF81C784, semanticName: 'completedTask'),
      role: ColorRole.success,
    ),
    'canceledTask': ColorToken(
      name: 'canceledTask',
      lightValue: AppColor(value: 0xFFF44336, semanticName: 'canceledTask'),
      darkValue: AppColor(value: 0xFFE57373, semanticName: 'canceledTask'),
      role: ColorRole.error,
    ),
    
    // State colors with backgrounds
    'successBackground': ColorToken(
      name: 'successBackground',
      lightValue: AppColor(value: 0xFFE8F5E8, semanticName: 'successBackground'),
      darkValue: AppColor(value: 0xFF1B5E20, semanticName: 'successBackground'),
      role: ColorRole.surface,
    ),
    'warningBackground': ColorToken(
      name: 'warningBackground',
      lightValue: AppColor(value: 0xFFFFF8E1, semanticName: 'warningBackground'),
      darkValue: AppColor(value: 0xFFE65100, semanticName: 'warningBackground'),
      role: ColorRole.surface,
    ),
    'errorBackground': ColorToken(
      name: 'errorBackground',
      lightValue: AppColor(value: 0xFFFFEBEE, semanticName: 'errorBackground'),
      darkValue: AppColor(value: 0xFFB71C1C, semanticName: 'errorBackground'),
      role: ColorRole.surface,
    ),
    'infoBackground': ColorToken(
      name: 'infoBackground',
      lightValue: AppColor(value: 0xFFE3F2FD, semanticName: 'infoBackground'),
      darkValue: AppColor(value: 0xFF0D47A1, semanticName: 'infoBackground'),
      role: ColorRole.surface,
    ),
  };
}
```

Now I'll use the prework tool to analyze the acceptance criteria before writing correctness properties:

<function_calls>
<invoke name="prework">
<parameter name="featureName">color-system-centralization

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

After analyzing all acceptance criteria, several properties can be consolidated to eliminate redundancy:

- **Hardcoded color detection properties (1.1, 1.2, 5.3)** can be combined into a comprehensive codebase scanning property
- **Semantic color properties (1.3, 2.1, 5.2)** can be consolidated into semantic color system validation
- **Accessibility properties (2.4, 2.5, 5.1, 5.4)** can be grouped into comprehensive accessibility compliance validation
- **Architecture separation properties (4.1, 4.2, 4.3, 4.4, 4.5)** can be combined into clean architecture compliance
- **Performance properties (3.5, 7.1, 7.2, 7.3, 7.4, 7.5)** can be grouped by performance characteristics
- **Theme management properties (3.2, 6.1, 6.2, 6.3, 6.5)** can be consolidated into comprehensive theme behavior validation

### Core Properties

**Property 1: Hardcoded color elimination**
*For any* presentation layer component file, scanning the codebase should find no direct `Colors.*` references or `Color(0x...)` hex values
**Validates: Requirements 1.1, 1.2, 5.3**

**Property 2: Semantic color system completeness**
*For any* color token name requested by components, the color system should resolve it to a valid semantic color value through the token registry
**Validates: Requirements 1.3, 2.1, 5.2**

**Property 3: Opacity variant consistency**
*For any* color token with opacity variations, the system should provide pre-defined opacity variants rather than runtime calculations
**Validates: Requirements 1.5**

**Property 4: Surface color completeness**
*For any* surface color requirement, the system should provide primary, secondary, and tertiary surface variants with appropriate text colors
**Validates: Requirements 2.2, 2.3**

**Property 5: Accessibility compliance**
*For any* foreground and background color combination, the contrast ratio should meet WCAG AA standards (≥4.5:1 for normal text, ≥3:1 for large text)
**Validates: Requirements 2.4, 2.5, 5.1, 5.4**

**Property 6: Dependency injection architecture**
*For any* presentation component requiring colors, it should receive them through dependency injection interfaces rather than direct access
**Validates: Requirements 3.1, 3.4**

**Property 7: Theme change notification**
*For any* theme change event, all registered components should receive automatic notifications and update consistently
**Validates: Requirements 3.2, 6.1**

**Property 8: Theme abstraction**
*For any* UI component, it should not contain theme selection logic and should access colors only through abstracted interfaces
**Validates: Requirements 3.3, 4.2**

**Property 9: Clean architecture separation**
*For any* color-related code, it should be properly separated into domain (definitions), infrastructure (provision), and presentation (usage) layers
**Validates: Requirements 4.1, 4.3, 4.4, 4.5**

**Property 10: System theme integration**
*For any* system theme change (light/dark mode), the application should automatically adapt without manual intervention
**Validates: Requirements 6.2**

**Property 11: Theme extensibility**
*For any* new custom theme added to the system, existing UI components should support it without code modifications
**Validates: Requirements 6.3**

**Property 12: Theme persistence**
*For any* user theme preference change, the selection should be persisted and restored correctly across application sessions
**Validates: Requirements 6.5**

**Property 13: Performance optimization**
*For any* frequently accessed color, the system should cache computed values and minimize widget rebuilds during theme changes
**Validates: Requirements 3.5, 7.1, 7.2, 7.3, 7.4, 7.5**

**Property 14: Migration compatibility**
*For any* existing hardcoded color being migrated, the replacement should maintain identical visual appearance and provide compatibility layers for legacy code
**Validates: Requirements 8.1, 8.2, 8.3, 8.5**

## Error Handling

### Color Resolution Errors

```dart
class ColorResolutionException implements Exception {
  final String tokenName;
  final String message;
  
  const ColorResolutionException(this.tokenName, this.message);
  
  @override
  String toString() => 'ColorResolutionException: $message for token "$tokenName"';
}
```

**Error Scenarios:**
- **Unknown color token**: When a component requests a color token that doesn't exist
- **Invalid theme mode**: When theme mode is not supported by the color token
- **Accessibility violation**: When color combinations fail contrast requirements
- **Circular dependency**: When color tokens reference each other in a loop

### Theme Loading Errors

```dart
class ThemeLoadingException implements Exception {
  final String themeName;
  final String reason;
  
  const ThemeLoadingException(this.themeName, this.reason);
}
```

**Error Scenarios:**
- **Theme not found**: When requested theme doesn't exist in available themes
- **Invalid theme configuration**: When theme configuration is malformed
- **Storage failure**: When theme preferences cannot be saved or loaded
- **System theme unavailable**: When system theme detection fails

### Validation Errors

```dart
class ColorValidationException implements Exception {
  final String colorName;
  final String validationRule;
  final String details;
  
  const ColorValidationException(this.colorName, this.validationRule, this.details);
}
```

**Error Recovery Strategies:**
- **Fallback colors**: Use default color tokens when resolution fails
- **Graceful degradation**: Continue with reduced functionality when themes fail to load
- **Error reporting**: Log validation errors for debugging while maintaining app stability
- **Retry mechanisms**: Attempt to reload themes or color configurations on transient failures

## Testing Strategy

### Dual Testing Approach

The color system requires both **unit tests** and **property-based tests** for comprehensive coverage:

**Unit Tests** focus on:
- Specific color token resolution examples
- Theme switching scenarios
- Error handling edge cases
- Integration points between layers
- Accessibility compliance for known color combinations

**Property-Based Tests** focus on:
- Universal properties across all color tokens
- Theme behavior across all available themes
- Accessibility compliance across all possible color combinations
- Architecture compliance across all components
- Performance characteristics under various loads

### Property-Based Testing Configuration

- **Testing Framework**: Use `test` package with custom property testing utilities
- **Minimum Iterations**: 100 iterations per property test
- **Test Tagging**: Each property test must reference its design document property
- **Tag Format**: `// Feature: color-system-centralization, Property {number}: {property_text}`

### Test Categories

**Architecture Tests:**
- Verify clean architecture layer separation
- Test dependency injection patterns
- Validate interface abstractions

**Accessibility Tests:**
- WCAG AA contrast ratio compliance
- Color blindness compatibility
- High contrast mode support

**Performance Tests:**
- Color resolution caching efficiency
- Theme change rebuild minimization
- Memory usage optimization

**Integration Tests:**
- End-to-end theme switching
- System theme synchronization
- Persistence and restoration flows

**Migration Tests:**
- Visual consistency validation
- Backward compatibility verification
- Gradual migration support

The testing strategy ensures that both specific examples work correctly (unit tests) and universal properties hold across all inputs (property tests), providing comprehensive validation of the color system's correctness and reliability.