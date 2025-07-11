
<p align="center">
<img src="https://github.com/user-attachments/assets/59d153fd-40d7-4cef-8e5f-b108ad6515dc" height="100" alt="UI Guard Package" />
</p>

<p align="center">
<a href="https://pub.dev/packages/ui_guard"><img src="https://img.shields.io/pub/v/flutter_bloc.svg" alt="Pub"></a>
<a href="https://github.com/Tanvirul-swe/ui_guard/actions"><img src="https://github.com/felangel/bloc/actions/workflows/main.yaml/badge.svg" alt="build"></a>
<a href="https://github.com/Tanvirul-swe/ui_guard"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
</p>

<p align="center"> <strong>Widgets that make role, permission, and condition-based UI control <em>simple, scalable,</em> and <em>secure</em>.</strong><br> Built entirely in Dart to help you build smarter, access-aware Flutter apps. </p> <p align="center"> <em>✨ ui_guard works seamlessly with any role management logic or state management approach.</em> </p>

## 🔐 Why use ui_guard?

In many apps, you need to control access to certain parts of your UI:

- Show settings only to admins
- Render upgrade buttons for guests
- Show/hide widgets based on subscription level

`ui_guard` lets you do this easily and declaratively — using only Dart.

---

## ✨ Features

- ✅ Guard widgets or entire screens based on roles
- 🧩 Combine roles, permissions, and runtime conditions
- 🧪 Developer override mode for UI testing
- 🔄 Easily update roles at runtime
- 📦 Pure Dart — no platform dependencies
- ♻️ Works with any state management

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  ui_guard: ^1.0.0
```


## 🧠 Core API

A simple class to store and manage the current user's roles.

#### 🔹 Guard
A simple class to store and manage the current user's roles.
```dart
final guard = Guard();
guard.setUserRoles(['admin']); // Set roles for current user

print(guard.currentRoles); // ['admin']
```

#### 🔹 AccessGuard
Renders content conditionally based on required roles.

```dart
AccessGuard(
  guard: guard,
  requiredRoles: ['admin'],
  builder: (_) => const Text('Admin Panel'),
  fallbackBuilder: (_) => const Text('Access Denied'),
);
```

#### 🔹 RoleBasedView
Use when you want to show/hide a single widget inline.

```dart
AccessGuard(
  guard: guard,
  requiredRoles: ['admin'],
  builder: (_) => const Text('Admin Panel'),
  fallbackBuilder: (_) => const Text('Access Denied'),
);
```

#### 🔹 RoleGuard
Utility class with common access logic:

```dart
RoleGuard.hasAnyRole(['admin'], ['admin', 'user']); // true
RoleGuard.hasAllRoles(['admin', 'editor'], ['admin']); // true
```

#### 🧪 Developer Override Mode
Bypass all restrictions during development or testing:

```dart
class GuardConfig {
  static bool developerOverrideEnabled = true; // Use in dev only
}
```

#### 🧮 Combined Access Conditions
Create advanced rules using roles, permissions, and runtime checks:

```dart
CombinedGuard(
  guard: guard,
  requiredRoles: ['manager'],
  requiredPermissions: ['edit_team'],
  condition: () => organization.isInternalMode,
  builder: (_) => const TeamEditor(),
  fallbackBuilder: (_) => const Text('Access Restricted'),
);

```

## 📱 Example App
Explore the full working example in the [`/example`](example) directory.

## 🧩 Use Cases

Here are some common scenarios where `ui_guard` is useful:

| Use Case                  | Example                                         |
|---------------------------|------------------------------------------------|
| Admin-only screens        | `requiredRoles: ['admin']`                      |
| Feature restrictions      | Hide paid features from free users              |
| Auth state UI             | Show "Login" or "Logout" buttons based on roles|
| Nested permissions        | Show moderator tools for `['moderator', 'admin']` roles |
| Read-only vs edit access  | Conditionally render buttons or fields          |
| Subscription tiers        | Control access with `['free', 'premium', 'pro']` roles |
| Combined logic            | Use roles + permissions + runtime conditions |
| Developer override	      |Skip restrictions in development or test |



## 💬 Contributing

Contributions are welcome!

- <a href="https://github.com/Tanvirul-swe/ui_guard" target="_blank">🌐 GitHub</a>
- <a href="https://github.com/Tanvirul-swe/ui_guard/issues" target="_blank">🐛 Issues</a>



To contribute:

1. Fork the repository
2. Create a new branch
3. Commit your changes
4. Submit a pull request


## 🛠️ Dart SDK Version

This package requires Dart SDK version **>=2.14**.

Please ensure your Flutter and Dart versions meet this requirement.

---

## 👤 Maintainers

- MD. TANVIRUL ISLAM
