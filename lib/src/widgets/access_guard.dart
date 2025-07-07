import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';
/// A widget that guards an entire screen or widget subtree based on user roles.
///
/// It renders the [builder] content if the user has any of the [requiredRoles].
/// If not, it renders the optional [fallbackBuilder] or nothing.
class AccessGuard extends StatelessWidget {
  /// List of roles required to access the content.
  final List<String> requiredRoles;

  /// Builder for the widget shown when access is granted.
  final WidgetBuilder builder;

  /// Builder for the widget shown when access is denied.
  final WidgetBuilder? fallbackBuilder;

  /// Optional custom logic for determining access.
  final bool Function(List<String> userRoles, List<String> requiredRoles)? accessEvaluator;

  /// The Guard instance holding current roles.
  final Guard guard;

  const AccessGuard({
    super.key,
    required this.requiredRoles,
    required this.builder,
    this.fallbackBuilder,
    this.accessEvaluator,
    required this.guard,
  });

  @override
  Widget build(BuildContext context) {
    final roles = guard.currentRoles;

    final hasAccess = accessEvaluator != null
        ? accessEvaluator!(roles, requiredRoles)
        : RoleGuard.hasAnyRole(roles, requiredRoles);

    return hasAccess
        ? builder(context)
        : (fallbackBuilder?.call(context) ?? const SizedBox.shrink());
  }
}
