import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_guard/ui_guard.dart';

void main() {
  late Guard guard;

  setUp(() {
    guard = Guard();
  });

  Widget buildTestWidget({
    required List<String> requiredRoles,
    WidgetBuilder? fallbackBuilder,
    bool Function(List<String>, List<String>)? accessEvaluator,
  }) {
    return MaterialApp(
      home: AccessGuard(
        guard: guard,
        requiredRoles: requiredRoles,
        builder: (context) => const Text('Access Granted', textDirection: TextDirection.ltr),
        fallbackBuilder: fallbackBuilder ??
            (context) => const Text('Access Denied', textDirection: TextDirection.ltr),
        accessEvaluator: accessEvaluator,
      ),
    );
  }

  testWidgets('shows builder when user has required role', (tester) async {
    guard.setUserRoles(['admin', 'user']);

    await tester.pumpWidget(buildTestWidget(requiredRoles: ['admin']));

    expect(find.text('Access Granted'), findsOneWidget);
    expect(find.text('Access Denied'), findsNothing);
  });

  testWidgets('shows fallback when user lacks required role', (tester) async {
    guard.setUserRoles(['user']);

    await tester.pumpWidget(buildTestWidget(requiredRoles: ['admin']));

    expect(find.text('Access Denied'), findsOneWidget);
    expect(find.text('Access Granted'), findsNothing);
  });

  testWidgets('shows empty widget when fallbackBuilder is null and access denied', (tester) async {
    guard.setUserRoles(['user']);

    await tester.pumpWidget(
      MaterialApp(
        home: AccessGuard(
          guard: guard,
          requiredRoles: const ['admin'],
          builder: (context) => const Text('Access Granted', textDirection: TextDirection.ltr),
          fallbackBuilder: null,
        ),
      ),
    );

    expect(find.text('Access Granted'), findsNothing);
    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('uses custom accessEvaluator when provided', (tester) async {
    guard.setUserRoles(['guest']);

    bool customEvaluator(List<String> userRoles, List<String> requiredRoles) {
      // Only allow if userRoles contains 'guest' and requiredRoles contains 'guest'
      return userRoles.contains('guest') && requiredRoles.contains('guest');
    }

    await tester.pumpWidget(buildTestWidget(
      requiredRoles: ['guest'],
      accessEvaluator: customEvaluator,
    ));

    expect(find.text('Access Granted'), findsOneWidget);
    expect(find.text('Access Denied'), findsNothing);
  });

  testWidgets('denies access when custom accessEvaluator returns false', (tester) async {
    guard.setUserRoles(['guest']);

    bool customEvaluator(List<String> userRoles, List<String> requiredRoles) {
      // Deny access no matter what
      return false;
    }

    await tester.pumpWidget(buildTestWidget(
      requiredRoles: ['guest'],
      accessEvaluator: customEvaluator,
    ));

    expect(find.text('Access Denied'), findsOneWidget);
    expect(find.text('Access Granted'), findsNothing);
  });

  testWidgets('handles empty user roles gracefully', (tester) async {
    guard.setUserRoles([]);

    await tester.pumpWidget(buildTestWidget(requiredRoles: ['admin']));

    expect(find.text('Access Denied'), findsOneWidget);
    expect(find.text('Access Granted'), findsNothing);
  });

  testWidgets('handles empty required roles as deny access', (tester) async {
    guard.setUserRoles(['admin']);

    await tester.pumpWidget(buildTestWidget(requiredRoles: []));

    // By default RoleGuard.hasAnyRole([], userRoles) returns false
    expect(find.text('Access Denied'), findsOneWidget);
    expect(find.text('Access Granted'), findsNothing);
  });
}
