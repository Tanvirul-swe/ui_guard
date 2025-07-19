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

  /// Checks if the current time matches the cron-style schedule.
  /// Returns false if the schedule string is invalid.
  static bool isInSchedule(String cron) {
    try {
      final now = DateTime.now();
      final parts = cron.trim().split(RegExp(r'\s+'));

      if (parts.length != 5) return false;

      final minute = parts[0];
      final hour = parts[1];
      final dayOfMonth = parts[2];
      final month = parts[3];
      final dayOfWeek = parts[4];

      bool match(String pattern, int current) {
        if (pattern == '*') return true;
        if (pattern.contains(',')) {
          return pattern.split(',').any((p) => match(p, current));
        }
        if (pattern.contains('-')) {
          final rangeParts = pattern.split('-');
          if (rangeParts.length != 2) return false;
          final start = int.tryParse(rangeParts[0]);
          final end = int.tryParse(rangeParts[1]);
          if (start == null || end == null) return false;
          return current >= start && current <= end;
        }
        final value = int.tryParse(pattern);
        return value != null && value == current;
      }

      // Note: Dart's DateTime weekday: Monday=1 ... Sunday=7
      // Cron dayOfWeek: Sunday=0 or 7, Monday=1
      int cronWeekday = now.weekday % 7; // Sunday=0
      return match(minute, now.minute) &&
          match(hour, now.hour) &&
          match(dayOfMonth, now.day) &&
          match(month, now.month) &&
          match(dayOfWeek, cronWeekday);
    } catch (e) {
      // On any error, consider schedule not matching
      return false;
    }
  }

  /// Stream emitting if current time matches the schedule on every [interval].
  /// Safely handles exceptions and emits false if schedule invalid.
  static Stream<bool> scheduleStream(String cron, Duration interval) async* {
    yield isInSchedule(cron);
    await for (final _ in Stream.periodic(interval)) {
      yield isInSchedule(cron);
    }
  }

  // Validate cron string format (5 parts, valid ranges etc.)
  static bool isValidCron(String cron) {
    try {
      final parts = cron.trim().split(RegExp(r'\s+'));
      if (parts.length != 5) return false;

      bool validPart(String part, int min, int max) {
        if (part == '*') return true;
        for (final token in part.split(',')) {
          if (token.contains('-')) {
            final range = token.split('-');
            if (range.length != 2) return false;
            final start = int.tryParse(range[0]);
            final end = int.tryParse(range[1]);
            if (start == null || end == null) return false;
            if (start < min || end > max || start > end) return false;
          } else {
            final val = int.tryParse(token);
            if (val == null || val < min || val > max) return false;
          }
        }
        return true;
      }

      return validPart(parts[0], 0, 59) && // minute
          validPart(parts[1], 0, 23) && // hour
          validPart(parts[2], 1, 31) && // day of month
          validPart(parts[3], 1, 12) && // month
          validPart(parts[4], 0, 7); // day of week (0=Sun,7=Sun)
    } catch (_) {
      return false;
    }
  }
}
