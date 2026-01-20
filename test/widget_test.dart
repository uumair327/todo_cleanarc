import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/core/theme/app_theme.dart';

void main() {
  testWidgets('App theme loads correctly', (WidgetTester tester) async {
    // Build a simple widget with our theme
    await tester.pumpWidget(
      MaterialApp(
        title: 'TaskFlow Test',
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: Text('TaskFlow'),
          ),
        ),
      ),
    );

    // Verify that the app loads successfully with our theme
    expect(find.text('TaskFlow'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
