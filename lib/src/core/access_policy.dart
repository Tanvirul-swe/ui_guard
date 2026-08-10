import 'guard.dart';

/// Reusable authorization policy.
class AccessPolicy {
  final String? name;
  final List<String> requiredRoles;
  final List<String> requiredPermissions;
  final bool Function(Guard guard)? condition;

  const AccessPolicy({
    this.name,
    this.requiredRoles = const [],
    this.requiredPermissions = const [],
    this.condition,
  });
}
