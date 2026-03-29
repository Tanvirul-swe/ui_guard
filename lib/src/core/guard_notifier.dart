import 'package:flutter/foundation.dart';

import 'guard.dart';

/// Reactive variant of [Guard] that notifies listeners on changes.
class GuardNotifier extends ChangeNotifier implements Guard {
  List<String> _currentRoles = [];
  List<String> _currentPermissions = [];

  @override
  List<String> get currentRoles => List.unmodifiable(_currentRoles);

  @override
  List<String> get currentPermissions => List.unmodifiable(_currentPermissions);

  @override
  void setUserRoles(List<String> roles) {
    _currentRoles = List<String>.from(roles);
    notifyListeners();
  }

  @override
  void setUserPermissions(List<String> permissions) {
    _currentPermissions = List<String>.from(permissions);
    notifyListeners();
  }
}
