import 'package:flutter_test/flutter_test.dart';
import 'package:ui_guard/ui_guard.dart';

void main() {
  test('evaluateDetailed returns denial reasons', () {
    final guard = Guard();
    guard.setUserRoles(['viewer']);
    guard.setUserPermissions(['read']);

    final decision = GuardUtils.evaluateDetailed(
      guard: guard,
      requiredRoles: const ['admin'],
      requiredPermissions: const ['write'],
      condition: () => false,
      policyName: 'test_policy',
    );

    expect(decision.allowed, isFalse);
    expect(decision.missingRoles, contains('admin'));
    expect(decision.missingPermissions, contains('write'));
    expect(decision.failedCondition, isTrue);
    expect(decision.reasonCode, 'test_policy');
  });
}
