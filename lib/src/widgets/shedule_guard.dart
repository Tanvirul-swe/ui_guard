import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';

/// A widget that controls access to its child widget based on a cron-style schedule.
///
/// This widget evaluates a cron expression repeatedly at a configurable interval
/// and shows or hides content depending on whether the current time matches the schedule.
///
/// Example usage:
/// ```dart
/// ScheduleGuard(
///   schedule: "0 9 * * 1-5", // Every weekday at 9:00 AM
///   builder: (_) => Text("Business is open!"),
///   fallbackBuilder: (_) => Text("Closed right now."),
/// )
/// ```
///
/// The `schedule` parameter expects a cron string with five fields:
/// - Minute (0-59)
/// - Hour (0-23)
/// - Day of month (1-31)
/// - Month (1-12)
/// - Day of week (0-7, Sunday=0 or 7)
///
/// If the schedule string is invalid, the widget displays a clear error message
/// instead of the guarded content.
///
/// Parameters:
/// - `schedule` (required): A cron-formatted string specifying when to show the `builder` widget.
/// - `builder` (required): Widget builder function called when the current time matches the schedule.
/// - `fallbackBuilder` (optional): Widget builder function called when outside the scheduled times.
///   If omitted, renders an empty container during fallback.
/// - `checkInterval` (optional): Duration between schedule evaluations (default is 1 minute).
///
/// Use cases include:
/// - Restricting UI to business hours
/// - Showing promotional banners only at specific times
/// - Enabling or disabling features on specific days or times
/// - Implementing blackout windows or maintenance periods
///

class ScheduleGuard extends StatelessWidget {
  final String schedule;
  final WidgetBuilder builder;
  final WidgetBuilder? fallbackBuilder;
  final Duration checkInterval;

  const ScheduleGuard({
    super.key,
    required this.schedule,
    required this.builder,
    this.fallbackBuilder,
    this.checkInterval = const Duration(minutes: 1),
  });

  @override
  Widget build(BuildContext context) {
    if (!GuardUtils.isValidCron(schedule)) {
      return Center(
        child: Text(
          'Invalid schedule format: $schedule',
          style:
              const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    return StreamBuilder<bool>(
      stream: GuardUtils.scheduleStream(schedule, checkInterval),
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
