import 'guard.dart';
import 'guard_config.dart';
import 'role_guard.dart';

/// A utility class for evaluating complex access control logic
/// using roles, permissions, and custom conditions.
class GuardUtils {
  /// Evaluate access based on:
  /// - all required roles
  /// - all required permissions
  /// - an optional runtime condition
  ///
  /// If `GuardConfig.developerOverrideEnabled` is true, access is always granted.
  static bool evaluate({
    required Guard guard,
    List<String> requiredRoles = const [],
    List<String> requiredPermissions = const [],
    bool Function()? condition,
  }) {
    if (GuardConfig.developerOverrideEnabled) return true;

    final hasRoles = hasAllRoles(guard, requiredRoles);
    final hasPermissions = hasAllPermissions(guard, requiredPermissions);
    final passesCondition = condition == null || condition();

    return hasRoles && hasPermissions && passesCondition;
  }

  /// Check if user has all of the given roles.
  static bool hasAllRoles(Guard guard, List<String> roles) {
    if (GuardConfig.developerOverrideEnabled) return true;
    return RoleGuard.hasAllRoles(guard.currentRoles, roles);
  }

  /// Check if user has any of the given roles.
  static bool hasAnyRole(Guard guard, List<String> roles) {
    if (GuardConfig.developerOverrideEnabled) return true;
    return RoleGuard.hasAnyRole(guard.currentRoles, roles);
  }

  /// Check if user has all of the given permissions.
  static bool hasAllPermissions(Guard guard, List<String> permissions) {
    if (GuardConfig.developerOverrideEnabled) return true;
    return RoleGuard.hasAllRoles(guard.currentPermissions, permissions);
  }

  /// Check if user has any of the given permissions.
  static bool hasAnyPermission(Guard guard, List<String> permissions) {
    if (GuardConfig.developerOverrideEnabled) return true;
    return RoleGuard.hasAnyRole(guard.currentPermissions, permissions);
  }
}
