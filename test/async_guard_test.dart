import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_guard/ui_guard.dart';

void main() {
  group('AsyncGuard Widget Tests', () {
    tearDown(() {
      GuardConfig.developerOverrideEnabled = false;
    });

    testWidgets(
      'Issue #5 Planned API: renders loading indicator then builder with AccessGuard on completion',
      (tester) async {
        final completer = Completer<List<String>>();

        await tester.pumpWidget(
          MaterialApp(
            home: AsyncGuard(
              roleFuture: completer.future,
              builder: (context, roles) => AccessGuard(
                guard: Guard()..setUserRoles(roles),
                requiredRoles: const ['admin'],
                builder: (_) => const Text('Admin Dashboard'),
                fallbackBuilder: (_) => const Text('Access Denied'),
              ),
            ),
          ),
        );

        // While future is waiting, default loading indicator is shown
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Admin Dashboard'), findsNothing);

        // Complete future with admin role
        completer.complete(['admin']);
        await tester.pump();

        // Admin dashboard should now be rendered
        expect(find.text('Admin Dashboard'), findsOneWidget);
        expect(find.text('Access Denied'), findsNothing);
      },
    );

    testWidgets(
      'renders fallbackBuilder when resolved roles lack requiredRoles',
      (tester) async {
        final completer = Completer<List<String>>();

        await tester.pumpWidget(
          MaterialApp(
            home: AsyncGuard(
              roleFuture: completer.future,
              builder: (context, roles) => AccessGuard(
                guard: Guard()..setUserRoles(roles),
                requiredRoles: const ['admin'],
                builder: (_) => const Text('Admin Dashboard'),
                fallbackBuilder: (_) => const Text('Access Denied'),
              ),
            ),
          ),
        );

        completer.complete(['user']);
        await tester.pump();

        expect(find.text('Access Denied'), findsOneWidget);
        expect(find.text('Admin Dashboard'), findsNothing);
      },
    );

    testWidgets('renders custom loadingBuilder while waiting', (tester) async {
      final completer = Completer<List<String>>();

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncGuard(
            roleFuture: completer.future,
            loadingBuilder: (_) => const Text('Custom Loading...'),
            builder: (context, roles) => Text('Roles: ${roles.join(', ')}'),
          ),
        ),
      );

      expect(find.text('Custom Loading...'), findsOneWidget);

      completer.complete(['editor']);
      await tester.pump();

      expect(find.text('Custom Loading...'), findsNothing);
      expect(find.text('Roles: editor'), findsOneWidget);
    });

    testWidgets('renders custom loading widget while waiting', (tester) async {
      final completer = Completer<List<String>>();

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncGuard(
            roleFuture: completer.future,
            loading: const Text('Static Loading'),
            builder: (context, roles) => Text('Roles: ${roles.join(', ')}'),
          ),
        ),
      );

      expect(find.text('Static Loading'), findsOneWidget);

      completer.complete(['viewer']);
      await tester.pump();

      expect(find.text('Static Loading'), findsNothing);
      expect(find.text('Roles: viewer'), findsOneWidget);
    });

    testWidgets('renders errorBuilder and calls onError when future fails', (tester) async {
      final completer = Completer<List<String>>();
      Object? capturedError;

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncGuard(
            roleFuture: completer.future,
            onError: (err, _) => capturedError = err,
            errorBuilder: (context, error, _) => Text('Error: $error'),
            builder: (context, roles) => const Text('Success'),
          ),
        ),
      );

      completer.completeError(Exception('Server unreachable'));
      await tester.pump();

      expect(find.text('Error: Exception: Server unreachable'), findsOneWidget);
      expect(find.text('Success'), findsNothing);
      expect(capturedError, isNotNull);
    });

    testWidgets('renders error widget when future fails', (tester) async {
      final completer = Completer<List<String>>();

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncGuard(
            roleFuture: completer.future,
            error: const Text('Failed to load roles'),
            builder: (context, roles) => const Text('Success'),
          ),
        ),
      );

      completer.completeError(Exception('Auth token expired'));
      await tester.pump();

      expect(find.text('Failed to load roles'), findsOneWidget);
      expect(find.text('Success'), findsNothing);
    });

    testWidgets('supports roleLoader function', (tester) async {
      Future<List<String>> fetchRoles() async => ['admin', 'manager'];

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncGuard(
            roleLoader: fetchRoles,
            builder: (context, roles) => Text('Count: ${roles.length}'),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Count: 2'), findsOneWidget);
    });

    testWidgets('uses initialRoles before future completes', (tester) async {
      final completer = Completer<List<String>>();

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncGuard(
            roleFuture: completer.future,
            initialRoles: const ['guest'],
            builder: (context, roles) => Text('Current: ${roles.first}'),
          ),
        ),
      );

      // Immediately shows initial data without waiting for future
      expect(find.text('Current: guest'), findsOneWidget);

      completer.complete(['member']);
      await tester.pump();

      expect(find.text('Current: member'), findsOneWidget);
    });

    testWidgets('invokes onLoaded callback when roles resolve', (tester) async {
      final completer = Completer<List<String>>();
      List<String>? loadedRoles;

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncGuard(
            roleFuture: completer.future,
            onLoaded: (roles) => loadedRoles = roles,
            builder: (context, roles) => const Text('Loaded View'),
          ),
        ),
      );

      expect(loadedRoles, isNull);

      completer.complete(['admin']);
      await tester.pump();
      await tester.pump(); // Allow postFrameCallback to execute

      expect(loadedRoles, equals(['admin']));
    });

    testWidgets('AsyncGuard.guard convenience constructor grants access correctly', (tester) async {
      final completer = Completer<List<String>>();

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncGuard.guard(
            roleFuture: completer.future,
            requiredRoles: const ['admin'],
            builder: (_) => const Text('Direct Admin Content'),
            fallbackBuilder: (_) => const Text('Direct Denied'),
          ),
        ),
      );

      completer.complete(['admin']);
      await tester.pump();

      expect(find.text('Direct Admin Content'), findsOneWidget);
      expect(find.text('Direct Denied'), findsNothing);
    });

    testWidgets('AsyncGuard.guard convenience constructor denies access correctly', (tester) async {
      final completer = Completer<List<String>>();

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncGuard.guard(
            roleFuture: completer.future,
            requiredRoles: const ['admin'],
            builder: (_) => const Text('Direct Admin Content'),
            fallbackBuilder: (_) => const Text('Direct Denied'),
          ),
        ),
      );

      completer.complete(['guest']);
      await tester.pump();

      expect(find.text('Direct Denied'), findsOneWidget);
      expect(find.text('Direct Admin Content'), findsNothing);
    });

    testWidgets('updates when roleFuture instance changes in didUpdateWidget', (tester) async {
      final completer1 = Completer<List<String>>();
      final completer2 = Completer<List<String>>();

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncGuard(
            roleFuture: completer1.future,
            builder: (context, roles) => Text('Role: ${roles.join(', ')}'),
          ),
        ),
      );

      completer1.complete(['first_role']);
      await tester.pump();
      expect(find.text('Role: first_role'), findsOneWidget);

      // Swap to a new future
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncGuard(
            roleFuture: completer2.future,
            builder: (context, roles) => Text('Role: ${roles.join(', ')}'),
          ),
        ),
      );

      completer2.complete(['second_role']);
      await tester.pumpAndSettle();
      expect(find.text('Role: second_role'), findsOneWidget);
    });
  });

  group('GuardUtils Async Evaluation Tests', () {
    tearDown(() {
      GuardConfig.developerOverrideEnabled = false;
    });

    test('evaluateAsync returns true when user has required roles', () async {
      final future = Future.value(['admin', 'editor']);
      final allowed = await GuardUtils.evaluateAsync(
        roleFuture: future,
        requiredRoles: ['admin'],
      );
      expect(allowed, isTrue);
    });

    test('evaluateAsync returns false when user lacks required roles', () async {
      final future = Future.value(['viewer']);
      final allowed = await GuardUtils.evaluateAsync(
        roleFuture: future,
        requiredRoles: ['admin'],
      );
      expect(allowed, isFalse);
    });

    test('evaluateDetailedAsync provides denial details', () async {
      final future = Future.value(['viewer']);
      final decision = await GuardUtils.evaluateDetailedAsync(
        roleFuture: future,
        requiredRoles: ['admin'],
        policyName: 'admin_only',
      );

      expect(decision.allowed, isFalse);
      expect(decision.missingRoles, equals(['admin']));
      expect(decision.reasonCode, equals('admin_only'));
    });

    test('evaluateDetailedAsync handles future error gracefully', () async {
      final future = Future<List<String>>.error(Exception('Network error'));
      final decision = await GuardUtils.evaluateDetailedAsync(
        roleFuture: future,
        requiredRoles: ['admin'],
      );

      expect(decision.allowed, isFalse);
      expect(decision.failedCondition, isTrue);
      expect(decision.reasonCode, equals('async_evaluation_error'));
    });

    test('evaluateDetailedAsync respects GuardConfig.developerOverrideEnabled', () async {
      GuardConfig.developerOverrideEnabled = true;

      final future = Future.value(['guest']);
      final decision = await GuardUtils.evaluateDetailedAsync(
        roleFuture: future,
        requiredRoles: ['admin'],
      );

      expect(decision.allowed, isTrue);
    });
  });
}
