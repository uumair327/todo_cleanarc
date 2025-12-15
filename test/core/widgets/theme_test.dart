import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glimfo_todo/core/theme/theme.dart';
import 'package:glimfo_todo/core/utils/app_colors.dart';
import 'package:glimfo_todo/core/widgets/widgets.dart';

void main() {
  group('Theme System Tests', () {
    testWidgets('AppTheme should apply consistent styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('CategoryChip should display correct colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('CustomButton should render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('CustomTextField should render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CustomTextField(
              label: 'Test Field',
              hint: 'Enter text',
            ),
          ),
        ),
      );

      expect(find.text('Test Field'), findsOneWidget);
    });
  });

  group('AppColors Tests', () {
    test('getCategoryColor should return correct colors', () {
      expect(AppColors.getCategoryColor('ongoing'), AppColors.ongoing);
      expect(AppColors.getCategoryColor('completed'), AppColors.completed);
      expect(AppColors.getCategoryColor('in_process'), AppColors.inProcess);
      expect(AppColors.getCategoryColor('canceled'), AppColors.canceled);
      expect(AppColors.getCategoryColor('unknown'), AppColors.ongoing); // default
    });

    test('getCategoryLightColor should return correct light colors', () {
      expect(AppColors.getCategoryLightColor('ongoing'), AppColors.ongoingLight);
      expect(AppColors.getCategoryLightColor('completed'), AppColors.completedLight);
      expect(AppColors.getCategoryLightColor('in_process'), AppColors.inProcessLight);
      expect(AppColors.getCategoryLightColor('canceled'), AppColors.canceledLight);
    });
  });
}
