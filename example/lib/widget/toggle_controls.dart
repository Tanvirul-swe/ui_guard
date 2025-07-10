import 'package:flutter/material.dart';

class ToggleControls extends StatelessWidget {
  final VoidCallback onRoleToggle;
  final VoidCallback onPermissionToggle;
  final VoidCallback onInternalToggle;

  const ToggleControls({
    super.key,
    required this.onRoleToggle,
    required this.onPermissionToggle,
    required this.onInternalToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: onRoleToggle,
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Toggle Role (Admin / Guest)'),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onPermissionToggle,
          icon: const Icon(Icons.vpn_key),
          label: const Text('Toggle Permission (edit_team)'),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onInternalToggle,
          icon: const Icon(Icons.build),
          label: const Text('Toggle Internal Mode'),
        ),
      ],
    );
  }
}
