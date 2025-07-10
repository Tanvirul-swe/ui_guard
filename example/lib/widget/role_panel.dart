import 'package:example/helper/guard_setup.dart';
import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';


class RolePanel extends StatelessWidget {
  final Guard guard;
  const RolePanel({super.key, required this.guard});

  @override
  Widget build(BuildContext context) {
    return AccessGuard(
      guard: guard,
      requiredRoles: ['admin'],
      builder: (_) => buildPanel(
        title: 'AccessGuard - Admin Only',
        icon: Icons.admin_panel_settings,
        color: Colors.green,
        message: 'Welcome Admin. You passed the AccessGuard!',
      ),
    );
  }
}
