import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/feature/todo/presentation/widgets/task_card.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/task_entity.dart';
import 'package:todo_cleanarc/core/domain/value_objects/task_id.dart';
import 'package:todo_cleanarc/core/domain/value_objects/user_id.dart';
import 'package:todo_cleanarc/core/domain/enums/task_enums.dart';

void main() {
  group('TaskCard Widget Tests', () {
    final testTask = TaskEntity(
      id: const TaskId('123'),
      userId: UserId.fromString('user123'),
      title: 'Test Task',
      description: 'Test Description',
      dueDate: DateTime(2026, 1, 25),
      dueTime: const DomainTime(hour: 10, minute: 0),
      category: TaskCategory.ongoing,
      priority: TaskPriority.medium,
      progressPercentage: 50,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('should display task title and description', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: testTask,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('should display progress percentage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: testTask,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: testTask,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TaskCard));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('should display category indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: testTask,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify category chip is displayed
      expect(find.text('Ongoing'), findsOneWidget);
    });

    testWidgets('should show swipe actions when swiped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: testTask,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Swipe to reveal actions
      await tester.drag(find.byType(TaskCard), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Verify delete action is visible
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });
}
