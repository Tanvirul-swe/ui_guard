/// A utility class for evaluating role-based access rules.
class RoleGuard {
  /// Returns true if the user has **at least one** of the required roles.
  static bool hasAnyRole(List<String> userRoles, List<String> requiredRoles) {
    return userRoles.any((role) => requiredRoles.contains(role));
  }

  /// Returns true only if the user has **all** of the required roles.
  static bool hasAllRoles(List<String> userRoles, List<String> requiredRoles) {
    return requiredRoles.every((role) => userRoles.contains(role));
  }
}
