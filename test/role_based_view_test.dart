import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_guard/ui_guard.dart'; // Adjust import as needed

void main() {
  group('RoleBasedView Widget', () {
    late Guard guard;

    setUp(() {
      guard = Guard();
    });

    testWidgets('shows child when user has required role', (tester) async {
      guard.setUserRoles(['admin']);

      await tester.pumpWidget(
        MaterialApp(
          home: RoleBasedView(
            guard: guard,
            requiredRoles: const ['admin'],
            fallback: const Text('Access Denied'),
            child: const Text('Access Granted'),
          ),
        ),
      );

      expect(find.text('Access Granted'), findsOneWidget);
      expect(find.text('Access Denied'), findsNothing);
    });

    testWidgets('shows fallback when user lacks required role', (tester) async {
      guard.setUserRoles(['user']);

      await tester.pumpWidget(
        MaterialApp(
          home: RoleBasedView(
            guard: guard,
            requiredRoles: const ['admin'],
            fallback: const Text('Access Denied'),
            child: const Text('Access Granted'),
          ),
        ),
      );

      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('Access Granted'), findsNothing);
    });

    testWidgets('shows nothing when no fallback provided and access denied', (tester) async {
      guard.setUserRoles(['user']);

      await tester.pumpWidget(
        MaterialApp(
          home: RoleBasedView(
            guard: guard,
            requiredRoles: const ['admin'],
            child: const Text('Access Granted'),
          ),
        ),
      );

      expect(find.text('Access Granted'), findsNothing);
    });

    testWidgets('uses custom accessEvaluator if provided', (tester) async {
      guard.setUserRoles(['user']);

      bool customEvaluator(List<String> userRoles, List<String> requiredRoles) {
        return userRoles.contains('user');
      }

      await tester.pumpWidget(
        MaterialApp(
          home: RoleBasedView(
            guard: guard,
            requiredRoles: const ['admin'],
            fallback: const Text('Access Denied'),
            accessEvaluator: customEvaluator,
            child: const Text('Access Granted'),
          ),
        ),
      );

      expect(find.text('Access Granted'), findsOneWidget);
      expect(find.text('Access Denied'), findsNothing);
    });
  });
}
