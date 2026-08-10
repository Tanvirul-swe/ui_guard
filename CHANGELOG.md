# Changelog

## [1.1.0]
### Added
- `GuardNotifier` for reactive access-control updates via `ChangeNotifier`.
- `AccessPolicy` and `PolicyGuard` for reusable named authorization rules.
- `AccessDecision` and decision callbacks for richer allow/deny diagnostics.
- `ScheduleParser` with advanced cron support (`*/step`, aliases like `MON`, and macros like `@daily`).
- GitHub Actions workflows for CI checks and automated pub.dev publishing.

### Improved
- `AccessGuard`, `RoleBasedView`, and `CombinedGuard` now support optional `rebuildListenable` and `onDecision` callbacks.
- `ScheduleGuard` now supports UTC evaluation and clearer cron validation messages.
- Added `RELEASING.md` checklist to streamline merge-to-pub.dev publishing.

---

## [1.0.4]
### Updated
- Upgraded `flutter_lints` to `^6.0.0` in both package and example project to keep lint rules current.

---

## [1.0.3]
### Added
- `TimedAccessGuard`: show or hide UI elements based on a configurable time window
- Supports automatic refresh with customizable check intervals
- Optional callback to get remaining time updates
- Useful for limited-time offers, maintenance messages, and beta access banners

### Improved
- Updated README with TimedAccessGuard usage examples and best practices

---

## [1.0.2]
### Added
- `CombinedGuard`: combine roles, permissions, and custom runtime conditions
- `GuardConfig.developerOverrideEnabled`: override all restrictions during development

### Improved
- Updated README with usage examples, GitHub badge, and contribution guidelines
- Added gallery and use-case section for better documentation

---

## [1.0.0]
### 🎉 Initial Release
- Role-based UI control for Flutter
- Includes:
  - `Guard`: manages current user roles
  - `AccessGuard`: guard entire screens/widgets by role
  - `RoleBasedView`: show/hide individual widgets
- Stateless, pure Dart implementation
- Example app included
