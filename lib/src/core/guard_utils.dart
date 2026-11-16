import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'access_decision.dart';
import 'access_policy.dart';
import 'device_type.dart';
import 'guard.dart';
import 'guard_config.dart';
import 'guard_diagnostics.dart';
import 'role_guard.dart';
import 'schedule_parser.dart';

/// A utility class for evaluating complex access control logic
/// using roles, permissions, and custom conditions.
class GuardUtils {
  static bool evaluate({
    required Guard guard,
    List<String> requiredRoles = const [],
    List<String> requiredPermissions = const [],
    bool Function()? condition,
  }) {
    return evaluateDetailed(
      guard: guard,
      requiredRoles: requiredRoles,
      requiredPermissions: requiredPermissions,
      condition: condition,
    ).allowed;
  }

  /// Detailed evaluation with denial reasons.
  static AccessDecision evaluateDetailed({
    required Guard guard,
    List<String> requiredRoles = const [],
    List<String> requiredPermissions = const [],
    bool Function()? condition,
    String? policyName,
  }) {
    if (GuardConfig.developerOverrideEnabled) {
      return AccessDecision.allow();
    }

    final missingRoles = requiredRoles
        .where((role) => !guard.currentRoles.contains(role))
        .toList(growable: false);

    final missingPermissions = requiredPermissions
        .where((permission) => !guard.currentPermissions.contains(permission))
        .toList(growable: false);

    final failedCondition = condition != null && !condition();
    final allowed =
        missingRoles.isEmpty && missingPermissions.isEmpty && !failedCondition;

    final decision = allowed
        ? AccessDecision.allow()
        : AccessDecision.deny(
            missingRoles: missingRoles,
            missingPermissions: missingPermissions,
            failedCondition: failedCondition,
            reasonCode: policyName,
          );

    GuardDiagnostics.logDecision(policyName ?? 'GuardUtils.evaluateDetailed', decision);
    return decision;
  }

  static bool evaluatePolicy({required Guard guard, required AccessPolicy policy}) {
    return evaluateDetailed(
      guard: guard,
      requiredRoles: policy.requiredRoles,
      requiredPermissions: policy.requiredPermissions,
      condition: policy.condition == null ? null : () => policy.condition!(guard),
      policyName: policy.name,
    ).allowed;
  }

  static AccessDecision evaluatePolicyDetailed({
    required Guard guard,
    required AccessPolicy policy,
  }) {
    return evaluateDetailed(
      guard: guard,
      requiredRoles: policy.requiredRoles,
      requiredPermissions: policy.requiredPermissions,
      condition: policy.condition == null ? null : () => policy.condition!(guard),
      policyName: policy.name,
    );
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
  static bool isInTimeRange(DateTime start, DateTime end, {DateTime? now}) {
    final current = now ?? DateTime.now();
    return current.isAfter(start) && current.isBefore(end);
  }

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

  static Duration timeLeft(DateTime end, {DateTime? now}) {
    final current = now ?? DateTime.now();
    return current.isBefore(end) ? end.difference(current) : Duration.zero;
  }

  static Duration timeUntilStart(DateTime start, {DateTime? now}) {
    final current = now ?? DateTime.now();
    return current.isBefore(start) ? start.difference(current) : Duration.zero;
  }

  static Stream<DateTime> periodicTimeStream({
    Duration interval = const Duration(seconds: 1),
  }) async* {
    yield DateTime.now();
    await for (final _ in Stream.periodic(interval)) {
      yield DateTime.now();
    }
  }

  /// Checks if [now] matches cron [schedule] with optional UTC matching.
  static bool isInSchedule(
    String schedule, {
    DateTime? now,
    bool useUtc = false,
  }) {
    try {
      final current = now ?? (useUtc ? DateTime.now().toUtc() : DateTime.now());
      return ScheduleParser.matches(schedule, current);
    } catch (_) {
      return false;
    }
  }

  static Stream<bool> scheduleStream(
    String schedule,
    Duration interval, {
    bool useUtc = false,
  }) async* {
    yield isInSchedule(schedule, useUtc: useUtc);
    await for (final _ in Stream.periodic(interval)) {
      yield isInSchedule(schedule, useUtc: useUtc);
    }
  }

  static bool isValidCron(String cron) => ScheduleParser.validate(cron).isValid;

  static String? cronValidationError(String cron) => ScheduleParser.validate(cron).error;

  /// Returns the set of active [DeviceType]s for the given [context].
  ///
  /// This includes:
  /// - Screen size category: [DeviceType.mobile], [DeviceType.tablet], or [DeviceType.desktop]
  ///   based on screen width and [breakpoints].
  /// - [DeviceType.web] if running on Flutter Web.
  /// - Platform device type ([DeviceType.android], [DeviceType.ios], [DeviceType.macos],
  ///   [DeviceType.windows], [DeviceType.linux], [DeviceType.fuchsia]) if not on Web.
  static Set<DeviceType> currentDeviceTypes(
    BuildContext context, {
    DeviceBreakpoints? breakpoints,
  }) {
    final bp = breakpoints ?? GuardConfig.deviceBreakpoints;
    final types = <DeviceType>{};

    if (kIsWeb) {
      types.add(DeviceType.web);
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          types.add(DeviceType.android);
          break;
        case TargetPlatform.iOS:
          types.add(DeviceType.ios);
          break;
        case TargetPlatform.macOS:
          types.add(DeviceType.macos);
          break;
        case TargetPlatform.windows:
          types.add(DeviceType.windows);
          break;
        case TargetPlatform.linux:
          types.add(DeviceType.linux);
          break;
        case TargetPlatform.fuchsia:
          types.add(DeviceType.fuchsia);
          break;
      }
    }

    double? width = MediaQuery.maybeSizeOf(context)?.width;
    if (width == null) {
      final view = View.maybeOf(context);
      if (view != null && view.devicePixelRatio > 0) {
        width = view.physicalSize.width / view.devicePixelRatio;
      }
    }

    if (width != null && width > 0) {
      types.add(DeviceType.fromWidth(width, breakpoints: bp));
    } else {
      types.add(DeviceType.mobile);
    }

    return types;
  }

  /// Returns the primary screen [DeviceType] for the given [context] based on [breakpoints].
  static DeviceType currentDeviceType(
    BuildContext context, {
    DeviceBreakpoints? breakpoints,
  }) {
    final bp = breakpoints ?? GuardConfig.deviceBreakpoints;
    double? width = MediaQuery.maybeSizeOf(context)?.width;
    if (width == null) {
      final view = View.maybeOf(context);
      if (view != null && view.devicePixelRatio > 0) {
        width = view.physicalSize.width / view.devicePixelRatio;
      }
    }

    if (width != null && width > 0) {
      return DeviceType.fromWidth(width, breakpoints: bp);
    }
    if (kIsWeb) return DeviceType.web;
    return DeviceType.mobile;
  }

  /// Evaluates whether the current environment matches any of the [allowedDevices].
  ///
  /// [allowedDevices] may contain [DeviceType] instances or [String]s ('mobile', 'tablet', 'desktop', 'web', etc.).
  static bool isDeviceAllowed({
    required BuildContext context,
    required List<dynamic> allowedDevices,
    DeviceBreakpoints? breakpoints,
    DeviceType? currentDevice,
    Set<DeviceType>? currentDevices,
    bool Function(Set<DeviceType> currentTypes, List<DeviceType> allowedTypes)? deviceEvaluator,
  }) {
    if (GuardConfig.developerOverrideEnabled) return true;
    if (allowedDevices.isEmpty) return false;

    final Set<DeviceType> activeTypes;
    if (currentDevices != null) {
      activeTypes = currentDevices;
    } else if (currentDevice != null) {
      activeTypes = {currentDevice};
    } else {
      activeTypes = currentDeviceTypes(context, breakpoints: breakpoints);
    }

    final allowedTypes = allowedDevices
        .map(DeviceType.from)
        .whereType<DeviceType>()
        .toList(growable: false);

    if (deviceEvaluator != null) {
      return deviceEvaluator(activeTypes, allowedTypes);
    }

    return activeTypes.any(allowedTypes.contains);
  }

  /// Detailed evaluation for device-based access control with [AccessDecision].
  static AccessDecision isDeviceAllowedDetailed({
    required BuildContext context,
    required List<dynamic> allowedDevices,
    DeviceBreakpoints? breakpoints,
    DeviceType? currentDevice,
    Set<DeviceType>? currentDevices,
    bool Function(Set<DeviceType> currentTypes, List<DeviceType> allowedTypes)? deviceEvaluator,
  }) {
    if (GuardConfig.developerOverrideEnabled) {
      final decision = AccessDecision.allow();
      GuardDiagnostics.logDecision('DeviceTypeGuard', decision);
      return decision;
    }

    final allowed = isDeviceAllowed(
      context: context,
      allowedDevices: allowedDevices,
      breakpoints: breakpoints,
      currentDevice: currentDevice,
      currentDevices: currentDevices,
      deviceEvaluator: deviceEvaluator,
    );

    final decision = allowed
        ? AccessDecision.allow()
        : AccessDecision.deny(
            failedCondition: true,
            reasonCode: 'device_type_guard_denied',
          );

    GuardDiagnostics.logDecision('DeviceTypeGuard', decision);
    return decision;
  }

  /// Checks if a single [currentDevice] is contained within [allowedDevices].
  static bool isDeviceTypeAllowed({
    required DeviceType currentDevice,
    required List<dynamic> allowedDevices,
  }) {
    if (GuardConfig.developerOverrideEnabled) return true;
    final allowedTypes = allowedDevices
        .map(DeviceType.from)
        .whereType<DeviceType>()
        .toSet();
    return allowedTypes.contains(currentDevice);
  }
}
