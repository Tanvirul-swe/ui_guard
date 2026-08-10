@Tags(['unstable'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_guard/ui_guard.dart';

void main() {
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  group('ScheduleGuard Widget Tests', () {
    testWidgets('renders builder when schedule is valid and matches time',
        (WidgetTester tester) async {
      // Always matches any valid runtime clock value.
      const schedule = '* * * * *';

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
      await disposeTree(tester);
    });

    testWidgets('renders fallback when schedule does not match time',
        (WidgetTester tester) async {
      // Deterministic non-match for almost all execution times.
      const schedule = '0 0 1 1 *';

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
      await disposeTree(tester);
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
      await disposeTree(tester);
    });

    testWidgets('renders empty container if fallbackBuilder is null',
        (WidgetTester tester) async {
      const schedule = '0 0 1 1 *';

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
      await disposeTree(tester);
    });
  });
}
