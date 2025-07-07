
<p align="center">
<img src="https://github.com/user-attachments/assets/c4a6ae9a-0516-4960-9849-bf7a651c245c" height="100" alt="UI Guard Package" />
</p>

<p align="center">
<a href="https://pub.dev/packages/flutter_bloc"><img src="https://img.shields.io/pub/v/flutter_bloc.svg" alt="Pub"></a>
<a href="https://github.com/Tanvirul-swe/ui_guard/actions"><img src="https://github.com/felangel/bloc/actions/workflows/main.yaml/badge.svg" alt="build"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
</p>

---

Widgets that make role-based UI control simple and scalable. Built to keep your Flutter app secure and user-friendly.


_\*Note: All widgets in the ui_guard package work seamlessly with your role management logic._

---

## 🔐 Why use ui_guard?

In many apps, you need to control access to certain parts of your UI:

- Show settings only to admins
- Render upgrade buttons for guests
- Show/hide widgets based on subscription level

`ui_guard` lets you do this easily and declaratively — using only Dart.

---

## ✨ Features

- ✅ Guard widgets or entire screens based on roles
- 🔄 Easily update roles at runtime
- 📦 Stateless and pure Dart — no native dependencies
- 🧪 Testable and platform-agnostic
- 🧩 Works with any state management

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

## 📱 Example App
Here’s a complete usage example. You can also explore the /example folder included with the package.

```dart
      import 'package:flutter/material.dart';
      import 'package:ui_guard/ui_guard.dart'; // Your plugin
      
      void main() {
        runApp(const RoleBasedApp());
      }
      
      class RoleBasedApp extends StatelessWidget {
        const RoleBasedApp({super.key});
      
        @override
        Widget build(BuildContext context) {
          return MaterialApp(
            title: 'UI Guard Plugin Example',
            theme: ThemeData(primarySwatch: Colors.deepPurple),
            home: const RoleHomePage(),
          );
        }
      }
      
      class RoleHomePage extends StatefulWidget {
        const RoleHomePage({super.key});
      
        @override
        State<RoleHomePage> createState() => _RoleHomePageState();
      }
      
      class _RoleHomePageState extends State<RoleHomePage> {
        final Guard guard = Guard();
      
        @override
        void initState() {
          super.initState();
          guard.setUserRoles(['admin']); // Default role
        }
      
        void _toggleRole() {
          final isAdmin = guard.currentRoles.contains('admin');
          final newRole = isAdmin ? 'guest' : 'admin';
          setState(() {
            guard.setUserRoles([newRole]);
          });
        }
      
        @override
        Widget build(BuildContext context) {
          final currentRole = guard.currentRoles.join(', ');
      
          return Scaffold(
            appBar: AppBar(title: const Text('Role-Based UI Example')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Current Role: $currentRole',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 30),
      
                  /// Show different content based on access
                  AccessGuard(
                    guard: guard,
                    requiredRoles: ['admin'],
                    builder: (_) => const AdminPanel(),
                    fallbackBuilder: (_) => const GuestMessage(),
                  ),
      
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _toggleRole,
                    icon: const Icon(Icons.sync_alt),
                    label: Text(
                      guard.currentRoles.contains('admin')
                          ? 'Switch to Guest'
                          : 'Switch to Admin',
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
      
      class AdminPanel extends StatelessWidget {
        const AdminPanel({super.key});
      
        @override
        Widget build(BuildContext context) {
          return Column(
            children: const [
              Icon(Icons.admin_panel_settings, size: 48, color: Colors.green),
              SizedBox(height: 10),
              Text(
                'Welcome, Admin!\nYou have full access to this section.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          );
        }
      }
      
      class GuestMessage extends StatelessWidget {
        const GuestMessage({super.key});
      
        @override
        Widget build(BuildContext context) {
          return Column(
            children: const [
              Icon(Icons.lock_outline, size: 48, color: Colors.redAccent),
              SizedBox(height: 10),
              Text(
                'Restricted Area.\nYou are viewing this as a guest.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ],
          );
        }
      }

```

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


## 💬 Contributing

Contributions are welcome!

- 🌐 GitHub: [https://github.com/your-username/ui_guard](https://github.com/your-username/ui_guard)
- 🐛 Issues: [https://github.com/your-username/ui_guard/issues](https://github.com/your-username/ui_guard/issues)

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
