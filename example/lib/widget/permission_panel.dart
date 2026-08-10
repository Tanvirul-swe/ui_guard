import 'package:example/helper/guard_setup.dart';
import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';

class PermissionPanel extends StatelessWidget {
  final Guard guard;
  final Listenable? rebuildListenable;
  final ValueChanged<AccessDecision>? onDecision;

  const PermissionPanel({
    super.key,
    required this.guard,
    this.rebuildListenable,
    this.onDecision,
  });

  @override
  Widget build(BuildContext context) {
    return RoleBasedView(
      guard: guard,
      requiredRoles: ['guest'],
      rebuildListenable: rebuildListenable,
      onDecision: onDecision,
      fallback: buildPanel(
        title: 'RoleBasedView',
        icon: Icons.block,
        color: Colors.redAccent,
        message: 'Denied: switch role back to guest to view this content.',
      ),
      child: buildPanel(
        title: 'RoleBasedView',
        icon: Icons.person_outline,
        color: Colors.orange,
        message: 'Allowed: this content is visible for the guest role.',
      ),
    );
  }
}
