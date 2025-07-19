import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_guard/ui_guard.dart'; // Adjust to your package import path

void main() {
  group('CombinedGuard Widget', () {
    late Guard guard;

    setUp(() {
      guard = Guard();
    });

    testWidgets('renders builder when user has required role', (tester) async {
      guard.setUserRoles(['admin']);
      guard.setUserPermissions(['edit']);

      await tester.pumpWidget(
        MaterialApp(
          home: CombinedGuard(
            guard: guard,
            requiredRoles: const ['admin'],
            requiredPermissions: const ['edit'],
            builder: (_) => const Text('Access Granted'),
            fallbackBuilder: (_) => const Text('Access Denied'),
          ),
        ),
      );

      expect(find.text('Access Granted'), findsOneWidget);
      expect(find.text('Access Denied'), findsNothing);
    });

    testWidgets('renders fallback when user lacks role', (tester) async {
      guard.setUserRoles(['user']);
      guard.setUserPermissions(['edit']);

      await tester.pumpWidget(
        MaterialApp(
          home: CombinedGuard(
            guard: guard,
            requiredRoles: const ['admin'],
            requiredPermissions: const ['edit'],
            builder: (_) => const Text('Access Granted'),
            fallbackBuilder: (_) => const Text('Access Denied'),
          ),
        ),
      );

      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('Access Granted'), findsNothing);
    });

    testWidgets('renders fallback when user lacks permission', (tester) async {
      guard.setUserRoles(['admin']);
      guard.setUserPermissions(['view']);

      await tester.pumpWidget(
        MaterialApp(
          home: CombinedGuard(
            guard: guard,
            requiredRoles: const ['admin'],
            requiredPermissions: const ['edit'],
            builder: (_) => const Text('Access Granted'),
            fallbackBuilder: (_) => const Text('Access Denied'),
          ),
        ),
      );

      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('Access Granted'), findsNothing);
    });

    testWidgets('respects custom condition', (tester) async {
      guard.setUserRoles(['admin']);
      guard.setUserPermissions(['edit']);

      bool customCondition() => false;

      await tester.pumpWidget(
        MaterialApp(
          home: CombinedGuard(
            guard: guard,
            requiredRoles: const ['admin'],
            requiredPermissions: const ['edit'],
            condition: customCondition,
            builder: (_) => const Text('Access Granted'),
            fallbackBuilder: (_) => const Text('Access Denied'),
          ),
        ),
      );

      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('Access Granted'), findsNothing);
    });

    testWidgets('renders builder when condition is true', (tester) async {
      guard.setUserRoles(['admin']);
      guard.setUserPermissions(['edit']);

      bool customCondition() => true;

      await tester.pumpWidget(
        MaterialApp(
          home: CombinedGuard(
            guard: guard,
            requiredRoles: const ['admin'],
            requiredPermissions: const ['edit'],
            condition: customCondition,
            builder: (_) => const Text('Access Granted'),
            fallbackBuilder: (_) => const Text('Access Denied'),
          ),
        ),
      );

      expect(find.text('Access Granted'), findsOneWidget);
      expect(find.text('Access Denied'), findsNothing);
    });
  });
}
