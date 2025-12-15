import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glimfo_todo/main.dart';

void main() {
  testWidgets('App loads and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the splash screen elements are present.
    expect(find.text('Todo App'), findsOneWidget);
    expect(find.text('Clean Architecture Setup Complete'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });
}
