# ui_guard

`ui_guard` helps you control Flutter UI visibility by role, permission, condition, and time.

It is pure Dart and works with any state management approach.

## Installation

```yaml
dependencies:
  ui_guard: ^1.1.0
```

## Quick Start

Use `GuardNotifier` when you want UI to rebuild automatically after role/permission updates.

```dart
import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';

final guard = GuardNotifier()
  ..setUserRoles(['guest'])
  ..setUserPermissions([]);

class ExampleView extends StatelessWidget {
  const ExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return AccessGuard(
      guard: guard,
      rebuildListenable: guard,
      requiredRoles: const ['admin'],
      builder: (_) => const Text('Admin content'),
      fallbackBuilder: (_) => const Text('Access denied'),
    );
  }
}
```

## Which Widget Should You Use?

| Need | Widget |
|---|---|
| Show/hide a full section or page by role | `AccessGuard` |
| Show/hide a small inline widget by role | `RoleBasedView` |
| Require roles + permissions + runtime condition | `CombinedGuard` |
| Reuse named authorization rules across screens | `PolicyGuard` + `AccessPolicy` |
| Enable content only in a start/end time window | `TimedAccessGuard` |
| Enable content by cron schedule | `ScheduleGuard` |

## Core Guide

### 1) Define Access State

#### Basic (non-reactive)
```dart
final guard = Guard();
guard.setUserRoles(['admin']);
guard.setUserPermissions(['users.edit']);
```

#### Reactive (recommended for UI)
```dart
final guard = GuardNotifier();
guard.setUserRoles(['admin']);
guard.setUserPermissions(['users.edit']);
```

Use `rebuildListenable: guard` when using `GuardNotifier`.

### 2) Role-based Access with `AccessGuard`

```dart
AccessGuard(
  guard: guard,
  rebuildListenable: guard, // remove if using Guard()
  requiredRoles: const ['admin'],
  builder: (_) => const AdminPanel(),
  fallbackBuilder: (_) => const Text('No access'),
);
```

### 3) Inline Role-based Access with `RoleBasedView`

```dart
RoleBasedView(
  guard: guard,
  rebuildListenable: guard,
  requiredRoles: const ['guest'],
  child: const Text('Guest banner'),
  fallback: const SizedBox.shrink(),
);
```

### 4) Combine Roles + Permissions + Condition

```dart
CombinedGuard(
  guard: guard,
  rebuildListenable: guard,
  requiredRoles: const ['manager'],
  requiredPermissions: const ['team.edit'],
  condition: () => isInternalMode,
  builder: (_) => const TeamEditor(),
  fallbackBuilder: (_) => const Text('Requirements not met'),
);
```

### 5) Reuse Rules with `AccessPolicy` + `PolicyGuard`

```dart
const manageUsersPolicy = AccessPolicy(
  name: 'manage_users',
  requiredRoles: ['admin'],
  requiredPermissions: ['users.edit'],
);

PolicyGuard(
  guard: guard,
  rebuildListenable: guard,
  policy: manageUsersPolicy,
  builder: (_) => const Text('User manager'),
  fallbackBuilder: (_) => const Text('No access'),
);
```

### 6) Access Diagnostics with `onDecision`

`AccessDecision` tells you why access was denied (`missingRoles`, `missingPermissions`, `failedCondition`, `reasonCode`).

```dart
CombinedGuard(
  guard: guard,
  requiredRoles: const ['manager'],
  onDecision: (decision) {
    if (!decision.allowed) {
      debugPrint('Missing roles: ${decision.missingRoles}');
      debugPrint('Missing permissions: ${decision.missingPermissions}');
      debugPrint('Failed condition: ${decision.failedCondition}');
      debugPrint('Reason code: ${decision.reasonCode}');
    }
  },
  builder: (_) => const Text('Manager area'),
  fallbackBuilder: (_) => const Text('Denied'),
);
```

## Time-based Access

### `TimedAccessGuard` (start/end window)

```dart
TimedAccessGuard(
  start: DateTime(2026, 3, 29, 9),
  end: DateTime(2026, 3, 29, 18),
  checkInterval: const Duration(seconds: 1),
  onTimeUpdate: (remaining) {
    debugPrint('Remaining: ${remaining.inSeconds}s');
  },
  builder: (_) => const Text('Offer active'),
  fallbackBuilder: (_) => const Text('Offer closed'),
);
```

### `ScheduleGuard` (cron)

```dart
ScheduleGuard(
  schedule: '*/15 9-17 * * MON-FRI',
  useUtc: true,
  checkInterval: const Duration(minutes: 1),
  builder: (_) => const Text('Business hours'),
  fallbackBuilder: (_) => const Text('Outside business hours'),
);
```

Supported cron capabilities:
- 5-field cron format (`minute hour day month weekday`)
- Wildcards, lists, ranges, steps (`*`, `1,2`, `1-5`, `*/5`)
- Month/day aliases (`JAN`, `MON-FRI`)
- Macros (`@daily`, `@weekly`, `@hourly`, etc.)

## Developer Override

For local development/testing only:

```dart
GuardConfig.developerOverrideEnabled = true;
```

When enabled, guard checks are bypassed.

## Example App

See the complete working app in [`example/`](example).

It includes:
- Reactive guard updates with `GuardNotifier`
- `AccessGuard`, `RoleBasedView`, `CombinedGuard`, and `PolicyGuard`
- `onDecision` diagnostics
- `TimedAccessGuard` and `ScheduleGuard`

## API Exports

Main export:

```dart
import 'package:ui_guard/ui_guard.dart';
```

Includes:
- Core: `Guard`, `GuardNotifier`, `GuardConfig`, `RoleGuard`, `GuardUtils`
- Policies/diagnostics: `AccessPolicy`, `AccessDecision`
- Widgets: `AccessGuard`, `RoleBasedView`, `CombinedGuard`, `PolicyGuard`, `TimedAccessGuard`, `ScheduleGuard`, `GuardListenableBuilder`

## Contributing

Contributions are welcome.

- Repository: https://github.com/Tanvirul-swe/ui_guard
- Issues: https://github.com/Tanvirul-swe/ui_guard/issues

