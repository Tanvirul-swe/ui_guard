import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_guard/ui_guard.dart';

void main() {
  testWidgets('PolicyGuard renders builder when policy passes', (tester) async {
    final guard = GuardNotifier();
    guard.setUserRoles(['admin']);
    guard.setUserPermissions(['users.edit']);

    const policy = AccessPolicy(
      name: 'manage_users',
      requiredRoles: ['admin'],
      requiredPermissions: ['users.edit'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PolicyGuard(
          guard: guard,
          policy: policy,
          rebuildListenable: guard,
          builder: (_) => const Text('Allowed'),
          fallbackBuilder: (_) => const Text('Denied'),
        ),
      ),
    );

    expect(find.text('Allowed'), findsOneWidget);
    expect(find.text('Denied'), findsNothing);
  });

  testWidgets('PolicyGuard rebuilds when GuardNotifier changes', (tester) async {
    final guard = GuardNotifier();
    guard.setUserRoles(['user']);

    const policy = AccessPolicy(requiredRoles: ['admin']);

    await tester.pumpWidget(
      MaterialApp(
        home: PolicyGuard(
          guard: guard,
          policy: policy,
          rebuildListenable: guard,
          builder: (_) => const Text('Allowed'),
          fallbackBuilder: (_) => const Text('Denied'),
        ),
      ),
    );

    expect(find.text('Denied'), findsOneWidget);

    guard.setUserRoles(['admin']);
    await tester.pump();

    expect(find.text('Allowed'), findsOneWidget);
  });
}
