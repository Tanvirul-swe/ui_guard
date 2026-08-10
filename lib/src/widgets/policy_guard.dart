import 'package:flutter/material.dart';

import '../core/access_decision.dart';
import '../core/access_policy.dart';
import '../core/guard.dart';
import '../core/guard_utils.dart';

/// Guards UI using a reusable [AccessPolicy].
class PolicyGuard extends StatelessWidget {
  final Guard guard;
  final AccessPolicy policy;
  final WidgetBuilder builder;
  final WidgetBuilder? fallbackBuilder;
  final void Function(AccessDecision decision)? onDecision;
  final Listenable? rebuildListenable;

  const PolicyGuard({
    super.key,
    required this.guard,
    required this.policy,
    required this.builder,
    this.fallbackBuilder,
    this.onDecision,
    this.rebuildListenable,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildGuard() {
      final decision = GuardUtils.evaluatePolicyDetailed(guard: guard, policy: policy);
      onDecision?.call(decision);
      if (decision.allowed) return builder(context);
      return fallbackBuilder?.call(context) ?? const SizedBox.shrink();
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
