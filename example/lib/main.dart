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
