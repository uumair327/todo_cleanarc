# Color Validation System

This document describes the build-time color validation system that prevents hardcoded colors from being committed to the codebase.

## Overview

The color validation system automatically scans Dart files for hardcoded color usage and enforces the use of semantic color tokens. It integrates with:

- Build process (via build_runner)
- Git pre-commit hooks
- CI/CD pipelines (GitHub Actions)
- Development workflow

## What Gets Detected

The system detects the following hardcoded color patterns:

### Material Colors
```dart
// ❌ Detected violations
Colors.red
Colors.blue.shade500
Colors.white

// ✅ Allowed alternatives
context.colorScheme.primary
context.appColors.errorBackground
```

### Hex Colors
```dart
// ❌ Detected violations
Color(0xFF123456)
Color(0xFFFF0000)

// ✅ Allowed alternatives
context.appColors.customColor
ColorTokenRegistry.tokens['customColor']!.lightValue
```

### RGB/ARGB Colors
```dart
// ❌ Detected violations
Color.fromRGBO(255, 0, 0, 1.0)
Color.fromARGB(255, 255, 0, 0)

// ✅ Allowed alternatives
context.appColors.semanticColorName
```

## Excluded Files

The following files are excluded from validation:

- Test files (`test/` directory)
- Generated files (`**/*.g.dart`, `**/*.freezed.dart`)
- Build artifacts (`.dart_tool/`, `build/`)
- Platform-specific code (`android/`, `ios/`, etc.)
- Color definition files:
  - `color_token_registry.dart`
  - `color_storage_impl.dart`
  - `app_colors.dart` (legacy, during migration)

## Usage

### Command Line

#### Basic validation
```bash
dart scripts/validate_colors.dart
```

#### Include test files
```bash
dart scripts/validate_colors.dart --include-tests
```

#### JSON output for CI/CD
```bash
dart scripts/validate_colors.dart --json --output violations.json
```

#### Warning mode (don't fail)
```bash
dart scripts/validate_colors.dart --no-fail
```

### Shell Scripts

#### Linux/macOS
```bash
# Basic validation
./scripts/validate_colors.sh

# Development mode (includes tests, doesn't fail)
./scripts/validate_colors.sh --dev

# CI/CD mode (JSON output, fails on violations)
./scripts/validate_colors.sh --ci --output violations.json

# Pre-commit mode
./scripts/validate_colors.sh --pre-commit
```

#### Windows PowerShell
```powershell
# Basic validation
.\scripts\validate_colors.ps1

# Development mode
.\scripts\validate_colors.ps1 -Dev

# CI/CD mode
.\scripts\validate_colors.ps1 -CI -Output violations.json
```

### Build Integration

The validation runs automatically during the build process:

```bash
# Run build with validation
flutter packages pub run build_runner build

# Clean build (includes validation)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Pre-commit Hook

Install the pre-commit hook to validate colors before each commit:

```bash
# Install the hook
./scripts/setup_hooks.sh

# Commit will now run validation automatically
git commit -m "Your changes"

# Bypass validation temporarily (not recommended)
git commit --no-verify -m "Emergency commit"
```

## CI/CD Integration

### GitHub Actions

The repository includes a GitHub Actions workflow (`.github/workflows/color-validation.yml`) that:

1. Runs on push and pull requests
2. Validates color usage
3. Comments on PRs with violation details
4. Fails the build if violations are found
5. Uploads validation results as artifacts

### Custom CI/CD

For other CI/CD systems, use the validation script:

```yaml
# Example for GitLab CI
color_validation:
  stage: test
  script:
    - dart scripts/validate_colors.dart --json --output violations.json
  artifacts:
    reports:
      junit: violations.json
    when: always
```

## Output Formats

### Text Output
```
Color Validation Report
======================
Files scanned: 45
Violations found: 3
Status: FAIL

Violations:
-----------

lib/feature/todo/presentation/screens/dashboard_screen.dart:
  Line 25: Colors.white
    Suggestion: Use context.appColors.semanticColorName or context.colorScheme.colorName
  Line 30: Color(0xFF123456)
    Suggestion: Define color in ColorTokenRegistry and access via semantic name
```

### JSON Output
```json
{
  "isValid": false,
  "filesScanned": 45,
  "violationCount": 3,
  "violations": [
    {
      "filePath": "lib/feature/todo/presentation/screens/dashboard_screen.dart",
      "lineNumber": 25,
      "line": "color: Colors.white,",
      "colorValue": "Colors.white",
      "suggestion": "Use context.appColors.semanticColorName or context.colorScheme.colorName",
      "type": "materialColors"
    }
  ]
}
```

## Configuration

### Customizing Excluded Files

Edit `lib/core/validation/color_lint_rules.dart`:

```dart
static const List<String> _excludedFiles = [
  'app_colors.dart',
  'color_lint_rules.dart',
  'color_token_registry.dart',
  'color_storage_impl.dart',
  'your_custom_file.dart', // Add your exclusions
];
```

### Customizing Detection Patterns

Modify the patterns in `ColorLintScanner._colorPatterns`:

```dart
static final Map<ColorViolationType, RegExp> _colorPatterns = {
  ColorViolationType.materialColors: RegExp(
    r'Colors\.\w+(?!\s*\.\s*withOpacity\s*\(\s*0\.0\s*\))',
    multiLine: true,
  ),
  // Add custom patterns here
};
```

## Troubleshooting

### Common Issues

#### "Dart is not installed or not in PATH"
- Ensure Dart SDK is installed
- Add Dart to your system PATH
- Use Flutter's Dart: `flutter dart scripts/validate_colors.dart`

#### "Permission denied" on shell scripts
```bash
chmod +x scripts/validate_colors.sh
chmod +x scripts/setup_hooks.sh
```

#### False positives
- Add files to exclusion list if they legitimately need hardcoded colors
- Use comments to document why hardcoded colors are necessary
- Consider if the color should be moved to the color token registry

#### Build failures
- Run validation manually to see detailed violations
- Fix violations before running build
- Temporarily disable build validation by commenting out the builder in `build.yaml`

### Debugging

Enable verbose output:
```bash
./scripts/validate_colors.sh --verbose
```

Run validation on specific directory:
```bash
dart scripts/validate_colors.dart --root lib/feature/todo
```

## Migration Strategy

When migrating existing code:

1. Run validation to identify all violations
2. Create semantic color tokens for commonly used colors
3. Replace hardcoded colors gradually, file by file
4. Use `--no-fail` mode during migration to avoid blocking development
5. Enable strict mode once migration is complete

## Best Practices

1. **Define semantic colors**: Create meaningful color tokens in `ColorTokenRegistry`
2. **Use context extensions**: Access colors via `context.appColors.semanticName`
3. **Document color usage**: Add comments explaining color choices
4. **Test color changes**: Verify accessibility and visual consistency
5. **Review violations regularly**: Don't let violations accumulate

## Integration with IDEs

### VS Code

Add to `.vscode/tasks.json`:
```json
{
  "label": "Validate Colors",
  "type": "shell",
  "command": "dart",
  "args": ["scripts/validate_colors.dart"],
  "group": "test",
  "presentation": {
    "echo": true,
    "reveal": "always",
    "focus": false,
    "panel": "shared"
  }
}
```

### IntelliJ/Android Studio

Add as an external tool:
- Program: `dart`
- Arguments: `scripts/validate_colors.dart`
- Working directory: `$ProjectFileDir$`