import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_guard/ui_guard.dart';

void main() {
  group('TimedAccessGuard Widget Tests', () {
    testWidgets('shows builder when current time is within the range', (tester) async {
      final now = DateTime.now();
      final start = now.subtract(const Duration(minutes: 1));
      final end = now.add(const Duration(minutes: 1));

      await tester.pumpWidget(
        MaterialApp(
          home: TimedAccessGuard(
            start: start,
            end: end,
            builder: (_) => const Text('Access Granted'),
            fallbackBuilder: (_) => const Text('Access Denied'),
            checkInterval: const Duration(milliseconds: 100),
          ),
        ),
      );

      expect(find.text('Access Granted'), findsOneWidget);
      expect(find.text('Access Denied'), findsNothing);
    });

    testWidgets('shows fallbackBuilder when current time is before the start', (tester) async {
      final now = DateTime.now();
      final start = now.add(const Duration(minutes: 1));
      final end = now.add(const Duration(minutes: 5));

      await tester.pumpWidget(
        MaterialApp(
          home: TimedAccessGuard(
            start: start,
            end: end,
            builder: (_) => const Text('Access Granted'),
            fallbackBuilder: (_) => const Text('Access Denied'),
            checkInterval: const Duration(milliseconds: 100),
          ),
        ),
      );

      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('Access Granted'), findsNothing);
    });

    testWidgets('shows fallbackBuilder when current time is after the end', (tester) async {
      final now = DateTime.now();
      final start = now.subtract(const Duration(minutes: 5));
      final end = now.subtract(const Duration(minutes: 1));

      await tester.pumpWidget(
        MaterialApp(
          home: TimedAccessGuard(
            start: start,
            end: end,
            builder: (_) => const Text('Access Granted'),
            fallbackBuilder: (_) => const Text('Access Denied'),
            checkInterval: const Duration(milliseconds: 100),
          ),
        ),
      );

      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('Access Granted'), findsNothing);
    });

    testWidgets('onTimeUpdate callback gets called with correct time left', (tester) async {
      final now = DateTime.now();
      final end = now.add(const Duration(seconds: 10));
      final start = now.subtract(const Duration(seconds: 10));
      Duration? receivedTimeLeft;

      await tester.pumpWidget(
        MaterialApp(
          home: TimedAccessGuard(
            start: start,
            end: end,
            builder: (_) => const Text('Access Granted'),
            fallbackBuilder: (_) => const Text('Access Denied'),
            checkInterval: const Duration(milliseconds: 100),
            onTimeUpdate: (timeLeft) {
              receivedTimeLeft = timeLeft;
            },
          ),
        ),
      );

      // Wait for post-frame callback to be triggered
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(receivedTimeLeft, isNotNull);
      expect(receivedTimeLeft!.inSeconds, lessThanOrEqualTo(10));
    });
  });
}
