import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';

class AsyncGuardPage extends StatefulWidget {
  const AsyncGuardPage({super.key});

  @override
  State<AsyncGuardPage> createState() => _AsyncGuardPageState();
}

class _AsyncGuardPageState extends State<AsyncGuardPage> {
  late Future<List<String>> _roleFuture;
  String _selectedScenario = 'admin';

  @override
  void initState() {
    super.initState();
    _loadScenario(_selectedScenario);
  }

  void _loadScenario(String scenario) {
    setState(() {
      _selectedScenario = scenario;
      _roleFuture = _fetchRoles(scenario);
    });
  }

  Future<List<String>> _fetchRoles(String scenario) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    switch (scenario) {
      case 'admin':
        return ['admin', 'manager'];
      case 'user':
        return ['user'];
      case 'error':
        throw Exception('Simulated network timeout');
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚡ AsyncGuard Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Async Source Simulation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Simulate fetching roles from secure storage, remote API, or Firebase Auth.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Load Admin Roles'),
                          selected: _selectedScenario == 'admin',
                          onSelected: (_) => _loadScenario('admin'),
                        ),
                        ChoiceChip(
                          label: const Text('Load User Roles'),
                          selected: _selectedScenario == 'user',
                          onSelected: (_) => _loadScenario('user'),
                        ),
                        ChoiceChip(
                          label: const Text('Simulate Error'),
                          selected: _selectedScenario == 'error',
                          onSelected: (_) => _loadScenario('error'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'AsyncGuard (Issue #5 Planned API)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            AsyncGuard(
              roleFuture: _roleFuture,
              loadingBuilder: (_) => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircularProgressIndicator.adaptive(),
                      SizedBox(height: 12),
                      Text('Fetching user roles from remote API...'),
                    ],
                  ),
                ),
              ),
              errorBuilder: (context, error, _) => Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Error loading roles: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => _loadScenario(_selectedScenario),
                      ),
                    ],
                  ),
                ),
              ),
              builder: (context, roles) => AccessGuard(
                guard: Guard()..setUserRoles(roles),
                requiredRoles: const ['admin'],
                builder: (_) => Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.admin_panel_settings, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Admin Dashboard',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Resolved roles: ${roles.join(', ')}'),
                      ],
                    ),
                  ),
                ),
                fallbackBuilder: (_) => Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lock_outline, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              'Access Denied',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your roles (${roles.join(', ')}) do not include [admin].',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
