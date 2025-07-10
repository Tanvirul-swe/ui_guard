import 'package:example/helper/guard_setup.dart';
import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';

class PermissionPanel extends StatelessWidget {
  final Guard guard;
  const PermissionPanel({super.key, required this.guard});

  @override
  Widget build(BuildContext context) {
    return RoleBasedView(
      guard: guard,
      requiredRoles: ['guest'],
      child: buildPanel(
        title: 'RoleBasedView - Guest Only',
        icon: Icons.person_outline,
        color: Colors.orange,
        message: 'Welcome Guest. This is guest-only content.',
      ),
    );
  }
}
