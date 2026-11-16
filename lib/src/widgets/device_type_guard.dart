import 'package:flutter/material.dart';

import '../core/access_decision.dart';
import '../core/device_type.dart';
import '../core/guard_utils.dart';

/// A widget that conditionally renders UI based on the device type the app is running on.
///
/// `DeviceTypeGuard` allows you to deliver responsive, platform-optimized UI by showing
/// or hiding widgets depending on whether the current device is mobile, tablet, desktop, web,
/// or a specific target platform.
///
/// ### Example:
/// ```dart
/// DeviceTypeGuard(
///   allowedDevices: ['mobile', 'tablet'],
///   builder: (_) => MobileView(),
///   fallbackBuilder: (_) => DesktopView(),
/// );
/// ```
///
/// Or using [DeviceType] enum values:
/// ```dart
/// DeviceTypeGuard(
///   allowedDevices: [DeviceType.desktop, DeviceType.web],
///   builder: (_) => DesktopOrWebView(),
///   fallbackBuilder: (_) => MobileView(),
/// );
/// ```
///
/// ### Parameters:
/// - [allowedDevices]: The list of allowed device types. Can be [DeviceType] enum values
///   or strings (e.g. `'mobile'`, `'tablet'`, `'desktop'`, `'web'`, `'android'`, `'ios'`, etc.).
/// - [builder]: A builder function to render if the device type matches.
/// - [child]: An optional widget to show if the device type matches (alternative to [builder]).
/// - [fallbackBuilder]: An optional builder to render if the device type does not match.
/// - [fallback]: An optional widget to render if the device type does not match.
/// - [breakpoints]: Optional custom [DeviceBreakpoints] (mobileBreakpoint, tabletBreakpoint).
///   Defaults to [GuardConfig.deviceBreakpoints].
/// - [currentDevice]: Explicit [DeviceType] override, useful for testing or responsive simulators.
/// - [currentDevices]: Explicit set of [DeviceType] overrides.
/// - [deviceEvaluator]: Optional custom callback to evaluate access given current and allowed types.
/// - [onDecision]: Optional callback with the access decision details.
/// - [rebuildListenable]: Optional [Listenable] to trigger rebuilds when updated.
class DeviceTypeGuard extends StatelessWidget {
  /// The list of device types allowed to access the widget.
  final List<dynamic> allowedDevices;

  /// The widget builder to render when access is granted.
  final WidgetBuilder? builder;

  /// The child widget to render when access is granted.
  final Widget? child;

  /// The fallback builder to render when access is denied.
  final WidgetBuilder? fallbackBuilder;

  /// The fallback widget to render when access is denied.
  final Widget? fallback;

  /// Custom breakpoints for screen size categorization.
  final DeviceBreakpoints? breakpoints;

  /// Explicit single device type override for testing or manual simulation.
  final DeviceType? currentDevice;

  /// Explicit active device types override for testing or manual simulation.
  final Set<DeviceType>? currentDevices;

  /// Custom evaluator function for custom access logic.
  final bool Function(
    Set<DeviceType> currentTypes,
    List<DeviceType> allowedTypes,
  )? deviceEvaluator;

  /// Optional callback invoked with the access decision.
  final void Function(AccessDecision decision)? onDecision;

  /// If provided, rebuilds whenever this listenable updates.
  final Listenable? rebuildListenable;

  const DeviceTypeGuard({
    super.key,
    required this.allowedDevices,
    this.builder,
    this.child,
    this.fallbackBuilder,
    this.fallback,
    this.breakpoints,
    this.currentDevice,
    this.currentDevices,
    this.deviceEvaluator,
    this.onDecision,
    this.rebuildListenable,
  }) : assert(
          builder != null || child != null,
          'Either builder or child must be provided to DeviceTypeGuard.',
        );

  @override
  Widget build(BuildContext context) {
    Widget buildGuard() {
      final decision = GuardUtils.isDeviceAllowedDetailed(
        context: context,
        allowedDevices: allowedDevices,
        breakpoints: breakpoints,
        currentDevice: currentDevice,
        currentDevices: currentDevices,
        deviceEvaluator: deviceEvaluator,
      );

      onDecision?.call(decision);

      if (decision.allowed) {
        if (builder != null) return builder!(context);
        if (child != null) return child!;
        return const SizedBox.shrink();
      }

      if (fallbackBuilder != null) return fallbackBuilder!(context);
      if (fallback != null) return fallback!;
      return const SizedBox.shrink();
    }

    if (rebuildListenable == null) {
      return buildGuard();
    }

    return ListenableBuilder(
      listenable: rebuildListenable!,
      builder: (context, _) => buildGuard(),
    );
  }
}
