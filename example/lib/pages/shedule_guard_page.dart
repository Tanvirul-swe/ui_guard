import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';

class ScheduleGuardTestPage extends StatelessWidget {
  const ScheduleGuardTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScheduleGuard Test')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ScheduleGuard(
                schedule: '* * * * *',
                checkInterval: const Duration(seconds: 10),
                builder:
                    (_) => const Text(
                      'Basic cron: Access Granted',
                      style: TextStyle(color: Colors.green, fontSize: 18),
                    ),
                fallbackBuilder:
                    (_) => const Text(
                      'Basic cron: Access Denied',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ScheduleGuard(
                schedule: '*/1 * * * *',
                useUtc: true,
                checkInterval: const Duration(seconds: 10),
                builder:
                    (_) => const Text(
                      'Advanced cron + UTC: Access Granted',
                      style: TextStyle(color: Colors.green, fontSize: 18),
                    ),
                fallbackBuilder:
                    (_) => const Text(
                      'Advanced cron + UTC: Access Denied',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
