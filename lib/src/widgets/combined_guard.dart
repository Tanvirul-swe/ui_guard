import 'package:flutter/material.dart';

import '../core/access_decision.dart';
import '../core/guard.dart';
import '../core/guard_utils.dart';

/// A flexible access control widget that combines roles, permissions,
/// and custom conditions into a single guard.
class CombinedGuard extends StatelessWidget {
  final Guard guard;
  final List<String> requiredRoles;
  final List<String> requiredPermissions;
  final bool Function()? condition;
  final WidgetBuilder builder;
  final WidgetBuilder? fallbackBuilder;

  /// Optional callback with access decision details.
  final void Function(AccessDecision decision)? onDecision;

  /// If provided, rebuilds whenever this listenable updates.
  final Listenable? rebuildListenable;

  const CombinedGuard({
    super.key,
    required this.guard,
    this.requiredRoles = const [],
    this.requiredPermissions = const [],
    this.condition,
    required this.builder,
    this.fallbackBuilder,
    this.onDecision,
    this.rebuildListenable,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildGuard() {
      final decision = GuardUtils.evaluateDetailed(
        guard: guard,
        requiredRoles: requiredRoles,
        requiredPermissions: requiredPermissions,
        condition: condition,
        policyName: 'combined_guard',
      );
      onDecision?.call(decision);

      return decision.allowed
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
