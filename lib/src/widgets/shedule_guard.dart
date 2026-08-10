import 'package:flutter/material.dart';

import '../core/guard_utils.dart';

/// A widget that controls access to its child widget based on a cron-style schedule.
class ScheduleGuard extends StatelessWidget {
  final String schedule;
  final WidgetBuilder builder;
  final WidgetBuilder? fallbackBuilder;
  final Duration checkInterval;

  /// If true, evaluates schedule against UTC time.
  final bool useUtc;

  const ScheduleGuard({
    super.key,
    required this.schedule,
    required this.builder,
    this.fallbackBuilder,
    this.checkInterval = const Duration(minutes: 1),
    this.useUtc = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!GuardUtils.isValidCron(schedule)) {
      final error = GuardUtils.cronValidationError(schedule) ?? 'Unknown cron error';
      return Center(
        child: Text(
          'Invalid schedule format: $error',
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    return StreamBuilder<bool>(
      stream: GuardUtils.scheduleStream(schedule, checkInterval, useUtc: useUtc),
      initialData: false,
      builder: (context, snapshot) {
        final hasAccess = snapshot.data ?? false;
        if (hasAccess) {
          return builder(context);
        } else if (fallbackBuilder != null) {
          return fallbackBuilder!(context);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
