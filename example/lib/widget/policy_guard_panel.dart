import 'package:example/helper/guard_setup.dart';
import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';

class PolicyGuardPanel extends StatelessWidget {
  final Guard guard;
  final Listenable? rebuildListenable;
  final ValueChanged<AccessDecision>? onDecision;

  static const AccessPolicy _manageTeamPolicy = AccessPolicy(
    name: 'manage_team_policy',
    requiredRoles: ['admin'],
    requiredPermissions: ['edit_team'],
  );

  const PolicyGuardPanel({
    super.key,
    required this.guard,
    this.rebuildListenable,
    this.onDecision,
  });

  @override
  Widget build(BuildContext context) {
    return PolicyGuard(
      guard: guard,
      policy: _manageTeamPolicy,
      rebuildListenable: rebuildListenable,
      onDecision: onDecision,
      builder:
          (_) => buildPanel(
            title: 'PolicyGuard',
            icon: Icons.rule_folder_outlined,
            color: Colors.teal,
            message: 'Access granted by policy: admin + edit_team.',
          ),
      fallbackBuilder:
          (_) => buildPanel(
            title: 'PolicyGuard',
            icon: Icons.policy_outlined,
            color: Colors.brown,
            message: 'Policy denied. Need admin role and edit_team permission.',
          ),
    );
  }
}
