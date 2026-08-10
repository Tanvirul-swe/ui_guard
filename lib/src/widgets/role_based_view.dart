import 'package:flutter/material.dart';

import '../core/access_decision.dart';
import '../core/guard.dart';
import '../core/role_guard.dart';

/// A widget that shows [child] only if the current user has any of the [requiredRoles].
class RoleBasedView extends StatelessWidget {
  final Widget child;
  final List<String> requiredRoles;
  final Widget? fallback;
  final bool Function(List<String> userRoles, List<String> requiredRoles)? accessEvaluator;
  final Guard guard;

  /// Optional callback with access decision details.
  final void Function(AccessDecision decision)? onDecision;

  /// If provided, rebuilds whenever this listenable updates.
  final Listenable? rebuildListenable;

  const RoleBasedView({
    super.key,
    required this.child,
    required this.requiredRoles,
    this.fallback,
    this.accessEvaluator,
    required this.guard,
    this.onDecision,
    this.rebuildListenable,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildGuard() {
      final roles = guard.currentRoles;
      final hasAccess = accessEvaluator != null
          ? accessEvaluator!(roles, requiredRoles)
          : RoleGuard.hasAnyRole(roles, requiredRoles);

      final missing = hasAccess
          ? const <String>[]
          : requiredRoles.where((role) => !roles.contains(role)).toList(growable: false);

      onDecision?.call(
        hasAccess
            ? AccessDecision.allow()
            : AccessDecision.deny(missingRoles: missing, reasonCode: 'role_based_view_denied'),
      );

      return hasAccess ? child : (fallback ?? const SizedBox.shrink());
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
