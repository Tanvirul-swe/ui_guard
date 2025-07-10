import 'package:example/helper/guard_setup.dart';
import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';


class CombinedGuardPanel extends StatelessWidget {
  final Guard guard;
  final bool isInternalMode;

  const CombinedGuardPanel({
    super.key,
    required this.guard,
    required this.isInternalMode,
  });

  @override
  Widget build(BuildContext context) {
    return CombinedGuard(
      guard: guard,
      requiredRoles: ['admin'],
      requiredPermissions: ['edit_team'],
      condition: () => isInternalMode,
      builder: (_) => buildPanel(
        title: 'CombinedGuard',
        icon: Icons.security,
        color: Colors.blue,
        message:
            'Access granted! Admin + edit_team + Internal mode active.',
      ),
      fallbackBuilder: (_) => buildPanel(
        title: 'CombinedGuard',
        icon: Icons.lock_outline,
        color: Colors.red,
        message: 'Access denied. You need all conditions.',
      ),
    );
  }
}
