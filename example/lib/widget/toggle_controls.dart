import 'package:flutter/material.dart';

class ToggleControls extends StatelessWidget {
  final bool isAdmin;
  final bool hasEditPermission;
  final bool isInternalMode;
  final bool developerOverrideEnabled;
  final VoidCallback onRoleToggle;
  final VoidCallback onPermissionToggle;
  final VoidCallback onInternalToggle;
  final VoidCallback onDeveloperOverrideToggle;
  final VoidCallback onReset;

  const ToggleControls({
    super.key,
    required this.isAdmin,
    required this.hasEditPermission,
    required this.isInternalMode,
    required this.developerOverrideEnabled,
    required this.onRoleToggle,
    required this.onPermissionToggle,
    required this.onInternalToggle,
    required this.onDeveloperOverrideToggle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Try access combinations',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: onRoleToggle,
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(isAdmin ? 'Switch to Guest' : 'Switch to Admin'),
                ),
                ElevatedButton.icon(
                  onPressed: onPermissionToggle,
                  icon: const Icon(Icons.vpn_key),
                  label: Text(
                    hasEditPermission ? 'Remove edit_team' : 'Grant edit_team',
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onInternalToggle,
                  icon: const Icon(Icons.build),
                  label: Text(
                    isInternalMode
                        ? 'Disable Internal Mode'
                        : 'Enable Internal Mode',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onDeveloperOverrideToggle,
                  icon: Icon(
                    developerOverrideEnabled
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  label: Text(
                    developerOverrideEnabled
                        ? 'Disable Dev Override'
                        : 'Enable Dev Override',
                  ),
                ),
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset Demo State'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
