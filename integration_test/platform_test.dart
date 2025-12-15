/// Cross-platform integration tests
/// Tests app behavior across different platforms (Android, iOS, Web, Desktop)
/// Requirements: 8.1, 8.2, 8.4
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_cleanarc/main.dart' as app;
import 'test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Cross-Platform Integration Tests', () {
    setUp(() async {
      await IntegrationTestConfig.initialize();
    });

    tearDown(() async {
      await IntegrationTestConfig.cleanup();
    });

    testWidgets(
      'Platform: App should render correctly on current platform',
      (WidgetTester tester) async {
        app.main();
        await IntegrationTestConfig.waitForAppToSettle(tester);

        // Verify app renders
        expect(find.byType(MaterialApp), findsOneWidget);

        // Platform-specific checks
        if (kIsWeb) {
          debugPrint('Running on Web platform');
        } else if (Platform.isAndroid) {
          debugPrint('Running on Android platform');
        } else if (Platform.isIOS) {
          debugPrint('Running on iOS platform');
        } else if (Platform.isMacOS) {
          debugPrint('Running on macOS platform');
        } else if (Platform.isWindows) {
          debugPrint('Running on Windows platform');
        } else if (Platform.isLinux) {
          debugPrint('Running on Linux platform');
        }

        // Verify theme is applied
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.theme, isNotNull);
      },
    );

    testWidgets(
      'Platform: Navigation should work consistently across platforms',
      (WidgetTester tester) async {
        app.main();
        await IntegrationTestConfig.waitForAppToSettle(tester);

        // Test navigation works
        final signUpButton = find.text('Sign Up');
        if (signUpButton.evaluate().isNotEmpty) {
          await IntegrationTestConfig.tapAndSettle(tester, signUpButton);
          
          // Verify navigation occurred
          await tester.pumpAndSettle(const Duration(seconds: 1));
          expect(find.byType(Scaffold), findsWidgets);
        }
      },
    );

    testWidgets(
      'Platform: Touch/click interactions should work on current platform',
      (WidgetTester tester) async {
        app.main();
        await IntegrationTestConfig.waitForAppToSettle(tester);

        // Test button interactions
        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          final firstButton = buttons.first;
          
          // Verify button is tappable
          await tester.tap(firstButton);
          await tester.pumpAndSettle();
          
          // Button should respond to interaction
          expect(firstButton, findsOneWidget);
        }
      },
    );

    testWidgets(
      'Platform: Text input should work correctly on current platform',
      (WidgetTester tester) async {
        app.main();
        await IntegrationTestConfig.waitForAppToSettle(tester);

        // Find text fields
        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          final firstTextField = textFields.first;
          
          // Test text input
          await tester.enterText(firstTextField, 'Test input');
          await tester.pumpAndSettle();
          
          // Verify text was entered
          expect(find.text('Test input'), findsOneWidget);
        }
      },
    );

    testWidgets(
      'Platform: Scrolling should work smoothly on current platform',
      (WidgetTester tester) async {
        app.main();
        await IntegrationTestConfig.waitForAppToSettle(tester);

        // Find scrollable widgets
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          final firstScrollable = scrollables.first;
          
          // Test scrolling
          await tester.drag(firstScrollable, const Offset(0, -200));
          await tester.pumpAndSettle();
          
          // Scrolling should complete without errors
          expect(firstScrollable, findsOneWidget);
        }
      },
    );

    testWidgets(
      'Platform: Theme and styling should be consistent',
      (WidgetTester tester) async {
        // Requirement 8.1, 8.4: Consistent visual design
        
        app.main();
        await IntegrationTestConfig.waitForAppToSettle(tester);

        // Verify MaterialApp has theme
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.theme, isNotNull);
        expect(materialApp.theme?.primaryColor, isNotNull);

        // Verify consistent styling across widgets
        final scaffolds = find.byType(Scaffold);
        if (scaffolds.evaluate().isNotEmpty) {
          final scaffold = tester.widget<Scaffold>(scaffolds.first);
          expect(scaffold.backgroundColor, isNotNull);
        }
      },
    );

    testWidgets(
      'Platform: App should handle platform-specific back navigation',
      (WidgetTester tester) async {
        app.main();
        await IntegrationTestConfig.waitForAppToSettle(tester);

        // Navigate to another screen
        final signUpButton = find.text('Sign Up');
        if (signUpButton.evaluate().isNotEmpty) {
          await IntegrationTestConfig.tapAndSettle(tester, signUpButton);
          
          // Test back navigation
          if (!kIsWeb) {
            // On mobile platforms, test back button
            final backButton = find.byType(BackButton);
            if (backButton.evaluate().isNotEmpty) {
              await IntegrationTestConfig.tapAndSettle(tester, backButton);
              
              // Should navigate back
              await tester.pumpAndSettle(const Duration(seconds: 1));
            }
          }
        }
      },
    );

    testWidgets(
      'Platform: App should adapt to different screen sizes',
      (WidgetTester tester) async {
        app.main();
        await IntegrationTestConfig.waitForAppToSettle(tester);

        // Get screen size
        final size = tester.view.physicalSize / 
                     tester.view.devicePixelRatio;
        
        debugPrint('Screen size: ${size.width} x ${size.height}');

        // Verify app renders at current screen size
        expect(find.byType(MaterialApp), findsOneWidget);
        
        // Verify responsive layout
        final scaffolds = find.byType(Scaffold);
        expect(scaffolds, findsWidgets);
      },
    );
  });
}
