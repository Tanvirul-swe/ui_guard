/// A simple class to hold and manage user roles.
class Guard {
  List<String> _currentRoles = [];

  /// Set or update current user roles.
  void setUserRoles(List<String> roles) {
    _currentRoles = roles;
  }

  /// Get the current user roles.
  List<String> get currentRoles => List.unmodifiable(_currentRoles);
}
