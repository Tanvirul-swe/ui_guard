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

  /// Returns true if the current time is within the given [start] and [end] window.
  static bool isInTimeRange(DateTime start, DateTime end) {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }

  /// Returns a stream that emits a boolean indicating whether
  /// the current time is within [start] and [end].
  ///
  /// This stream can be used in widgets to automatically rebuild
  /// when the time-based condition changes.
  static Stream<bool> timeWindowStream(
    DateTime start,
    DateTime end,
    Duration interval,
  ) async* {
    while (true) {
      yield isInTimeRange(start, end);
      await Future.delayed(interval);
    }
  }

  /// Returns how much time is left until the [end] time.
  /// If [end] is in the past, returns [Duration.zero].
  static Duration timeLeft(DateTime end) {
    final now = DateTime.now();
    return now.isBefore(end) ? end.difference(now) : Duration.zero;
  }

  /// Returns how long until the [start] time.
  /// If [start] is in the past, returns [Duration.zero].
  static Duration timeUntilStart(DateTime start) {
    final now = DateTime.now();
    return now.isBefore(start) ? start.difference(now) : Duration.zero;
  }

  /// Returns a stream that emits current DateTime immediately
  /// and then periodically every [interval].
  static Stream<DateTime> periodicTimeStream({
    Duration interval = const Duration(seconds: 1),
  }) async* {
    yield DateTime.now(); // emit immediately
    await for (final _ in Stream.periodic(interval)) {
      yield DateTime.now();
    }
  }
}
