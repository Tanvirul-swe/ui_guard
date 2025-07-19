import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_guard/ui_guard.dart';

void main() {
  group('ScheduleGuard Widget Tests', () {
    testWidgets('renders builder when schedule is valid and matches time',
        (WidgetTester tester) async {
      // Use a schedule that matches current time for test simplicity
      final now = DateTime.now();
      final minute = now.minute;
      final hour = now.hour;

      // A cron string that matches current hour and minute, wildcard for others
      final schedule = '$minute $hour * * *';

      await tester.pumpWidget(
        MaterialApp(
          home: ScheduleGuard(
            schedule: schedule,
            checkInterval: const Duration(seconds: 1),
            builder: (_) => const Text('Access Granted'),
            fallbackBuilder: (_) => const Text('Access Denied'),
          ),
        ),
      );

      // Since schedule matches, builder widget should appear
      expect(find.text('Access Granted'), findsOneWidget);
      expect(find.text('Access Denied'), findsNothing);
    });

    testWidgets('renders fallback when schedule does not match time',
        (WidgetTester tester) async {
      // Use a schedule that will NOT match current time (minute + 1)
      final now = DateTime.now();
      final invalidMinute = (now.minute + 1) % 60;
      final hour = now.hour;

      final schedule = '$invalidMinute $hour * * *';

      await tester.pumpWidget(
        MaterialApp(
          home: ScheduleGuard(
            schedule: schedule,
            checkInterval: const Duration(seconds: 1),
            builder: (_) => const Text('Access Granted'),
            fallbackBuilder: (_) => const Text('Access Denied'),
          ),
        ),
      );

      // Since schedule does not match, fallback widget should appear
      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('Access Granted'), findsNothing);
    });

    testWidgets('renders error message when schedule is invalid',
        (WidgetTester tester) async {
      const invalidSchedule = 'invalid schedule string';

      await tester.pumpWidget(
        MaterialApp(
          home: ScheduleGuard(
            schedule: invalidSchedule,
            builder: (_) => const Text('Access Granted'),
          ),
        ),
      );

      expect(find.textContaining('Invalid schedule format'), findsOneWidget);
      expect(find.text('Access Granted'), findsNothing);
    });

    testWidgets('renders empty container if fallbackBuilder is null',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final invalidMinute = (now.minute + 1) % 60;
      final hour = now.hour;
      final schedule = '$invalidMinute $hour * * *';

      await tester.pumpWidget(
        MaterialApp(
          home: ScheduleGuard(
            schedule: schedule,
            builder: (_) => const Text('Access Granted'),
          ),
        ),
      );

      // No fallbackBuilder provided, so empty widget shown when no access
      expect(find.text('Access Granted'), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
