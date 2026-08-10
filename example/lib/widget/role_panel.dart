import 'package:example/helper/guard_setup.dart';
import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';

class RolePanel extends StatelessWidget {
  final Guard guard;
  final Listenable? rebuildListenable;
  final ValueChanged<AccessDecision>? onDecision;

  const RolePanel({
    super.key,
    required this.guard,
    this.rebuildListenable,
    this.onDecision,
  });

  @override
  Widget build(BuildContext context) {
    return AccessGuard(
      guard: guard,
      requiredRoles: ['admin'],
      rebuildListenable: rebuildListenable,
      onDecision: onDecision,
      builder:
          (_) => buildPanel(
            title: 'AccessGuard',
            icon: Icons.admin_panel_settings,
            color: Colors.green,
            message: 'Allowed: current user has the required admin role.',
          ),
      fallbackBuilder:
          (_) => buildPanel(
            title: 'AccessGuard',
            icon: Icons.lock_outline,
            color: Colors.red,
            message: 'Denied: this area requires the admin role.',
          ),
    );
  }
}
