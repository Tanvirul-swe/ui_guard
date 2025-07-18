# Changelog


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
