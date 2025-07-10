/// Configuration for ui_guard behavior.
class GuardConfig {
  /// If true, all access restrictions are bypassed for development/testing.
  /// This allows developers to test UI without worrying about role checks.
  /// Set to false in production builds.
  /// Default is false.
  /// This should be used with caution as it disables all role-based access checks.
  /// This is useful for development and testing purposes only.
  /// It should not be enabled in production environments.
  /// Example usage:
  /// ```dart
  /// GuardConfig.developerOverrideEnabled = true; // Enable for testing
  /// ```
  /// Make sure to set it back to false before deploying to production.
  static bool developerOverrideEnabled = false;
}
