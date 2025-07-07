import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';
import '../core/guard.dart';

/// A widget that shows [child] only if the current user has any of the [requiredRoles].
///
/// Optionally, a [fallback] widget can be shown if access is denied.
/// You can override the default access logic using [accessEvaluator].
class RoleBasedView extends StatelessWidget {
  /// The widget to display if access is granted.
  final Widget child;

  /// The roles required to show the [child].
  final List<String> requiredRoles;

  /// The widget to display if access is denied.
  final Widget? fallback;

  /// Optional function to override the default role-based access logic.
  final bool Function(List<String> userRoles, List<String> requiredRoles)? accessEvaluator;

  /// The Guard instance holding current roles.
  final Guard guard;

  const RoleBasedView({
    super.key,
    required this.child,
    required this.requiredRoles,
    this.fallback,
    this.accessEvaluator,
    required this.guard,
  });

  @override
  Widget build(BuildContext context) {
    final roles = guard.currentRoles;

    final hasAccess = accessEvaluator != null
        ? accessEvaluator!(roles, requiredRoles)
        : RoleGuard.hasAnyRole(roles, requiredRoles);

    return hasAccess ? child : (fallback ?? const SizedBox.shrink());
  }
}
