/// A simple class to hold and manage user roles.
class Guard {
  List<String> _currentRoles = [];
  List<String> _currentPermissions = [];

  /// Set or update current user roles.
  void setUserRoles(List<String> roles) {
    _currentRoles = roles;
  }

  void setUserPermissions(List<String> permissions) {
    _currentPermissions = permissions;
  }

  /// Get the current user roles.
  List<String> get currentRoles => List.unmodifiable(_currentRoles);
  List<String> get currentPermissions => List.unmodifiable(_currentPermissions);
}
