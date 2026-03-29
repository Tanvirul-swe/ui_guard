import 'package:flutter_test/flutter_test.dart';
import 'package:ui_guard/ui_guard.dart';

void main() {
  test('GuardNotifier notifies listeners when roles update', () {
    final guard = GuardNotifier();
    var notified = 0;
    guard.addListener(() => notified++);

    guard.setUserRoles(['admin']);

    expect(guard.currentRoles, ['admin']);
    expect(notified, 1);
  });

  test('GuardNotifier notifies listeners when permissions update', () {
    final guard = GuardNotifier();
    var notified = 0;
    guard.addListener(() => notified++);

    guard.setUserPermissions(['edit']);

    expect(guard.currentPermissions, ['edit']);
    expect(notified, 1);
  });
}
