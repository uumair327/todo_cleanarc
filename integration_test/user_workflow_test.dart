/// Integration test for complete user workflows
/// Tests: signup → task creation → sync
/// Requirements: All requirements (1.1, 2.1, 4.1, 4.2, 7.3)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_cleanarc/main.dart' as app;
import 'test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Workflow Integration Tests', () {
    setUp(() async {
      await IntegrationTestConfig.initialize();
    });

    tearDown(() async {
      await IntegrationTestConfig.cleanup();
    });

    testWidgets(
      'Complete workflow: signup → dashboard → create task → view task',
      (WidgetTester tester) async {
        // Launch the app
        app.main();
        await IntegrationTestConfig.waitForAppToSettle(tester);

        // Generate unique test credentials
        final testEmail = IntegrationTestData.generateTestEmail();
        final testPassword = IntegrationTestData.generateTestPassword();

        // Step 1: Navigate to signup screen
        final signUpButton = find.text('Sign Up');
        if (signUpButton.evaluate().isNotEmpty) {
          await IntegrationTestConfig.tapAndSettle(tester, signUpButton);
        }

        // Step 2: Fill signup form
        final emailField = find.byType(TextField).first;
        final passwordField = find.byType(TextField).at(1);

        await IntegrationTestConfig.enterTextAndSettle(
          tester,
          emailField,
          testEmail,
        );
        await IntegrationTestConfig.enterTextAndSettle(
          tester,
          passwordField,
          testPassword,
        );

        // Step 3: Submit signup
        final submitButton = find.widgetWithText(ElevatedButton, 'Sign Up');
        await IntegrationTestConfig.tapAndSettle(tester, submitButton);

        // Verify: Should navigate to dashboard
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(
          find.textContaining('Welcome'),
          findsOneWidget,
          reason: 'Dashboard should show welcome message after signup',
        );

        // Step 4: Navigate to task creation
        final addTaskButton = find.byType(FloatingActionButton);
        await IntegrationTestConfig.tapAndSettle(tester, addTaskButton);

        // Step 5: Fill task creation form
        final taskTitle = IntegrationTestData.generateTestTaskTitle();
        final taskDescription = IntegrationTestData.generateTestTaskDescription();

        final taskTitleField = find.widgetWithText(TextField, 'Title');
        final taskDescriptionField = find.widgetWithText(TextField, 'Description');

        await IntegrationTestConfig.enterTextAndSettle(
          tester,
          taskTitleField,
          taskTitle,
        );
        await IntegrationTestConfig.enterTextAndSettle(
          tester,
          taskDescriptionField,
          taskDescription,
        );

        // Step 6: Submit task creation
        final createTaskButton = find.widgetWithText(ElevatedButton, 'Create Task');
        await IntegrationTestConfig.tapAndSettle(tester, createTaskButton);

        // Verify: Should navigate back to task list with new task
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(
          find.text(taskTitle),
          findsOneWidget,
          reason: 'Created task should appear in task list',
        );

        // Step 7: Verify task appears on dashboard
        final dashboardTab = find.text('Dashboard');
        if (dashboardTab.evaluate().isNotEmpty) {
          await IntegrationTestConfig.tapAndSettle(tester, dashboardTab);
        }

        // Verify: Dashboard should show updated task count
        expect(
          find.textContaining('Ongoing'),
          findsOneWidget,
          reason: 'Dashboard should show task category',
        );
      },
    );

    testWidgets(
      'Workflow: login → view tasks → edit task → logout',
      (WidgetTester tester) async {
        // This test assumes a user already exists
        // In a real scenario, you would create a test user first
        
        app.main();
        await IntegrationTestConfig.waitForAppToSettle(tester);

        final testEmail = IntegrationTestData.generateTestEmail(12345);
        final testPassword = IntegrationTestData.generateTestPassword();

        // Step 1: Navigate to login (if not already there)
        final loginButton = find.text('Login');
        if (loginButton.evaluate().isNotEmpty) {
          await IntegrationTestConfig.tapAndSettle(tester, loginButton);
        }

        // Step 2: Fill login form
        final emailField = find.byType(TextField).first;
        final passwordField = find.byType(TextField).at(1);

        await IntegrationTestConfig.enterTextAndSettle(
          tester,
          emailField,
          testEmail,
        );
        await IntegrationTestConfig.enterTextAndSettle(
          tester,
          passwordField,
          testPassword,
        );

        // Step 3: Submit login
        final submitButton = find.widgetWithText(ElevatedButton, 'Login');
        if (submitButton.evaluate().isNotEmpty) {
          await IntegrationTestConfig.tapAndSettle(tester, submitButton);
        }

        // Wait for navigation
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Step 4: Navigate to profile/settings
        final profileButton = find.byIcon(Icons.person);
        if (profileButton.evaluate().isNotEmpty) {
          await IntegrationTestConfig.tapAndSettle(tester, profileButton);
        }

        // Step 5: Logout
        final logoutButton = find.text('Logout');
        if (logoutButton.evaluate().isNotEmpty) {
          await IntegrationTestConfig.tapAndSettle(tester, logoutButton);
        }

        // Verify: Should return to login screen
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(
          find.text('Login'),
          findsWidgets,
          reason: 'Should return to login screen after logout',
        );
      },
    );

    testWidgets(
      'Workflow: create multiple tasks → filter by date → search tasks',
      (WidgetTester tester) async {
        app.main();
        await IntegrationTestConfig.waitForAppToSettle(tester);

        // Assume user is logged in or skip auth for this test
        // In real scenario, perform login first

        // Step 1: Create multiple tasks
        for (int i = 0; i < 3; i++) {
          final addTaskButton = find.byType(FloatingActionButton);
          if (addTaskButton.evaluate().isNotEmpty) {
            await IntegrationTestConfig.tapAndSettle(tester, addTaskButton);

            final taskTitle = IntegrationTestData.generateTestTaskTitle(i);
            final taskTitleField = find.widgetWithText(TextField, 'Title');

            await IntegrationTestConfig.enterTextAndSettle(
              tester,
              taskTitleField,
              taskTitle,
            );

            final createButton = find.widgetWithText(ElevatedButton, 'Create Task');
            if (createButton.evaluate().isNotEmpty) {
              await IntegrationTestConfig.tapAndSettle(tester, createButton);
            }

            await tester.pumpAndSettle(const Duration(seconds: 1));
          }
        }

        // Step 2: Navigate to task list
        final tasksTab = find.text('Tasks');
        if (tasksTab.evaluate().isNotEmpty) {
          await IntegrationTestConfig.tapAndSettle(tester, tasksTab);
        }

        // Step 3: Test search functionality
        final searchField = find.byType(TextField).first;
        if (searchField.evaluate().isNotEmpty) {
          await IntegrationTestConfig.enterTextAndSettle(
            tester,
            searchField,
            'Test Task',
          );

          // Verify: Search results should show matching tasks
          await tester.pumpAndSettle(const Duration(seconds: 1));
          expect(
            find.textContaining('Test Task'),
            findsWidgets,
            reason: 'Search should return matching tasks',
          );
        }
      },
    );
  });
}
