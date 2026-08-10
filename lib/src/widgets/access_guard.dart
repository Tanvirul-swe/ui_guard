import 'package:flutter/material.dart';

import '../core/access_decision.dart';
import '../core/guard.dart';
import '../core/role_guard.dart';

/// A widget that guards an entire screen or widget subtree based on user roles.
class AccessGuard extends StatelessWidget {
  final List<String> requiredRoles;
  final WidgetBuilder builder;
  final WidgetBuilder? fallbackBuilder;
  final bool Function(List<String> userRoles, List<String> requiredRoles)? accessEvaluator;
  final Guard guard;

  /// Optional callback with access decision details.
  final void Function(AccessDecision decision)? onDecision;

  /// If provided, rebuilds whenever this listenable updates.
  final Listenable? rebuildListenable;

  const AccessGuard({
    super.key,
    required this.requiredRoles,
    required this.builder,
    this.fallbackBuilder,
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
            : AccessDecision.deny(missingRoles: missing, reasonCode: 'access_guard_denied'),
      );

      return hasAccess
          ? builder(context)
          : (fallbackBuilder?.call(context) ?? const SizedBox.shrink());
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
