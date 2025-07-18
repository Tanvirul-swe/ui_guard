import 'package:example/helper/guard_setup.dart';
import 'package:example/pages/timed_access_page.dart';
import 'package:example/widget/combined_guard_panel.dart';
import 'package:example/widget/permission_panel.dart';
import 'package:example/widget/role_panel.dart';
import 'package:example/widget/toggle_controls.dart';
import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';

class RoleHomePage extends StatefulWidget {
  const RoleHomePage({super.key});

  @override
  State<RoleHomePage> createState() => _RoleHomePageState();
}

class _RoleHomePageState extends State<RoleHomePage> {
  final Guard guard = Guard();
  bool isInternalMode = false;

  @override
  void initState() {
    super.initState();
    guard.setUserRoles(['guest']);
    guard.setUserPermissions([]);
  }

  void _toggleRole() {
    setState(() {
      if (guard.currentRoles.contains('admin')) {
        guard.setUserRoles(['guest']);
      } else {
        guard.setUserRoles(['admin']);
      }
    });
  }

  void _togglePermission() {
    setState(() {
      if (guard.currentPermissions.contains('edit_team')) {
        guard.setUserPermissions([]);
      } else {
        guard.setUserPermissions(['edit_team']);
      }
    });
  }

  void _toggleInternalMode() {
    setState(() {
      isInternalMode = !isInternalMode;
    });
  }

  void _toggleDevOverride() {
    setState(() {
      GuardConfig.developerOverrideEnabled =
          !GuardConfig.developerOverrideEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Guard Full Example'),
        actions: [
          IconButton(
            icon: Icon(
              GuardConfig.developerOverrideEnabled
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.white,
            ),
            tooltip: 'Toggle Developer Override',
            onPressed: _toggleDevOverride,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildInfoCard('Roles', guard.currentRoles.join(', ')),
          buildInfoCard('Permissions', guard.currentPermissions.join(', ')),
          buildInfoCard('Internal Mode', isInternalMode.toString()),
          const Divider(),

          RolePanel(guard: guard),
          PermissionPanel(guard: guard),
          CombinedGuardPanel(guard: guard, isInternalMode: isInternalMode),

          const SizedBox(height: 30),
          ToggleControls(
            onRoleToggle: _toggleRole,
            onPermissionToggle: _togglePermission,
            onInternalToggle: _toggleInternalMode,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TimedAccessPage()),
              );
            },
            label: Text("Go to Timed Access Page"),
            icon: Icon(Icons.timer_outlined),
          ),
        ],
      ),
    );
  }
}
