import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';

class ScheduleGuardTestPage extends StatelessWidget {
  const ScheduleGuardTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example: schedule every minute at second 0 (simulate running every minute)
    // Since we only have minute precision, let's set schedule to always true for testing
    // e.g., every minute and hour (* * * * *)
    const schedule = '* * * * *';

    return Scaffold(
      appBar: AppBar(title: const Text('ScheduleGuard Test')),
      body: Center(
        child: ScheduleGuard(
          schedule: schedule,
          checkInterval: const Duration(
            seconds: 10,
          ), // Check every 10 seconds for quick feedback
          builder:
              (_) => const Text(
                'Access Granted: Within schedule',
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
          fallbackBuilder:
              (_) => const Text(
                'Access Denied: Outside schedule',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
        ),
      ),
    );
  }
}
