import 'package:example/pages/shedule_guard_page.dart';
import 'package:example/pages/timed_access_page.dart';
import 'package:example/widget/combined_guard_panel.dart';
import 'package:example/widget/permission_panel.dart';
import 'package:example/widget/policy_guard_panel.dart';
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
  final GuardNotifier guard = GuardNotifier();
  bool isInternalMode = false;
  String? _lastDecisionSource;
  final Map<String, String> _decisionBySource = <String, String>{};

  bool get _isAdmin => guard.currentRoles.contains('admin');
  bool get _hasEditPermission => guard.currentPermissions.contains('edit_team');
  String get _activeRole => _isAdmin ? 'admin' : 'guest';

  @override
  void initState() {
    super.initState();
    _initializeDemoState();
  }

  @override
  void dispose() {
    guard.dispose();
    super.dispose();
  }

  void _initializeDemoState() {
    guard.setUserRoles(['guest']);
    guard.setUserPermissions([]);
    GuardConfig.developerOverrideEnabled = false;
  }

  void _resetDemoState() {
    _initializeDemoState();
    setState(() {
      isInternalMode = false;
      _lastDecisionSource = null;
      _decisionBySource.clear();
    });
  }

  void _toggleRole() {
    guard.setUserRoles(_isAdmin ? ['guest'] : ['admin']);
  }

  void _togglePermission() {
    guard.setUserPermissions(_hasEditPermission ? [] : ['edit_team']);
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

  void _recordDecision(String source, AccessDecision decision) {
    final summary =
        'allowed=${decision.allowed}, '
        'missingRoles=${decision.missingRoles.join(', ')}, '
        'missingPermissions=${decision.missingPermissions.join(', ')}, '
        'failedCondition=${decision.failedCondition}, '
        'reason=${decision.reasonCode ?? 'none'}';

    if (_decisionBySource[source] == summary) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _decisionBySource[source] == summary) {
        return;
      }
      setState(() {
        _decisionBySource[source] = summary;
        _lastDecisionSource = source;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ui_guard Example'),
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
      body: GuardListenableBuilder(
        listenable: guard,
        builder: (_) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _GuideCard(
                title: 'Quick Start',
                icon: Icons.lightbulb_outline,
                lines: const [
                  '1. Start from guest role (default).',
                  '2. Use controls to change role, permission, and internal mode.',
                  '3. Watch each guard section update immediately.',
                  '4. Open time-based pages for TimedAccessGuard and ScheduleGuard.',
                ],
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: '1) Current Session'),
              _SessionStateCard(
                role: _activeRole,
                hasEditPermission: _hasEditPermission,
                isInternalMode: isInternalMode,
                developerOverrideEnabled: GuardConfig.developerOverrideEnabled,
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: '2) Change Inputs'),
              ToggleControls(
                isAdmin: _isAdmin,
                hasEditPermission: _hasEditPermission,
                isInternalMode: isInternalMode,
                developerOverrideEnabled: GuardConfig.developerOverrideEnabled,
                onRoleToggle: _toggleRole,
                onPermissionToggle: _togglePermission,
                onInternalToggle: _toggleInternalMode,
                onDeveloperOverrideToggle: _toggleDevOverride,
                onReset: _resetDemoState,
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: '3) Guard Examples'),
              _ExampleCard(
                title: 'AccessGuard',
                rule: "requiredRoles: ['admin']",
                useCase: 'Gate full widgets or pages by role.',
                child: RolePanel(
                  guard: guard,
                  rebuildListenable: guard,
                  onDecision:
                      (decision) => _recordDecision('AccessGuard', decision),
                ),
              ),
              const SizedBox(height: 12),
              _ExampleCard(
                title: 'RoleBasedView',
                rule: "requiredRoles: ['guest']",
                useCase: 'Inline visibility for small UI parts.',
                child: PermissionPanel(
                  guard: guard,
                  rebuildListenable: guard,
                  onDecision:
                      (decision) => _recordDecision('RoleBasedView', decision),
                ),
              ),
              const SizedBox(height: 12),
              _ExampleCard(
                title: 'CombinedGuard',
                rule:
                    "requiredRoles: ['admin'] + requiredPermissions: ['edit_team'] + condition: internal mode",
                useCase: 'Combine role, permission, and runtime condition.',
                child: CombinedGuardPanel(
                  guard: guard,
                  isInternalMode: isInternalMode,
                  rebuildListenable: guard,
                  onDecision:
                      (decision) => _recordDecision('CombinedGuard', decision),
                ),
              ),
              const SizedBox(height: 12),
              _ExampleCard(
                title: 'PolicyGuard + AccessPolicy',
                rule:
                    "policy: AccessPolicy(name: 'manage_team_policy', requiredRoles: ['admin'], requiredPermissions: ['edit_team'])",
                useCase: 'Reuse named policies across multiple screens.',
                child: PolicyGuardPanel(
                  guard: guard,
                  rebuildListenable: guard,
                  onDecision:
                      (decision) => _recordDecision('PolicyGuard', decision),
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: '4) Time-based Guards'),
              _NavigationCard(
                title: 'TimedAccessGuard Page',
                subtitle: 'Start/end window with live countdown updates.',
                icon: Icons.timer_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TimedAccessPage()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _NavigationCard(
                title: 'ScheduleGuard Page',
                subtitle: 'Cron schedule access with advanced UTC support.',
                icon: Icons.schedule,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScheduleGuardTestPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: '5) Diagnostics'),
              _DiagnosticsCard(
                lastDecisionSource: _lastDecisionSource,
                decisionBySource: _decisionBySource,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> lines;

  const _GuideCard({
    required this.title,
    required this.icon,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(line),
              ),
          ],
        ),
      ),
    );
  }
}

class _SessionStateCard extends StatelessWidget {
  final String role;
  final bool hasEditPermission;
  final bool isInternalMode;
  final bool developerOverrideEnabled;

  const _SessionStateCard({
    required this.role,
    required this.hasEditPermission,
    required this.isInternalMode,
    required this.developerOverrideEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(
              label: 'Role: $role',
              active: role == 'admin',
              activeColor: Colors.green,
            ),
            _StatusChip(
              label:
                  'Permission edit_team: ${hasEditPermission ? 'ON' : 'OFF'}',
              active: hasEditPermission,
              activeColor: Colors.blue,
            ),
            _StatusChip(
              label: 'Internal Mode: ${isInternalMode ? 'ON' : 'OFF'}',
              active: isInternalMode,
              activeColor: Colors.orange,
            ),
            _StatusChip(
              label: 'Dev Override: ${developerOverrideEnabled ? 'ON' : 'OFF'}',
              active: developerOverrideEnabled,
              activeColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;

  const _StatusChip({
    required this.label,
    required this.active,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor:
          active
              ? activeColor.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.14),
      side: BorderSide(
        color:
            active
                ? activeColor.withValues(alpha: 0.45)
                : Colors.grey.withValues(alpha: 0.25),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final String rule;
  final String useCase;
  final Widget child;

  const _ExampleCard({
    required this.title,
    required this.rule,
    required this.useCase,
    required this.child,
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
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Rule: $rule'),
            const SizedBox(height: 4),
            Text('Use case: $useCase'),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _DiagnosticsCard extends StatelessWidget {
  final String? lastDecisionSource;
  final Map<String, String> decisionBySource;

  const _DiagnosticsCard({
    required this.lastDecisionSource,
    required this.decisionBySource,
  });

  @override
  Widget build(BuildContext context) {
    final latestSummary =
        lastDecisionSource == null
            ? 'No decision captured yet.'
            : '$lastDecisionSource: ${decisionBySource[lastDecisionSource]}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Decision',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(latestSummary),
            const SizedBox(height: 12),
            Text(
              'Per Guard Summary',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            if (decisionBySource.isEmpty)
              const Text('No guard decisions yet.')
            else
              for (final entry in decisionBySource.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
          ],
        ),
      ),
    );
  }
}
