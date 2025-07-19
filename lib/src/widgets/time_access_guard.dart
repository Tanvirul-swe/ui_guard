import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart'; // import your GuardUtils

/// A widget that conditionally renders its child based on a specified time window.
///
/// `TimedAccessGuard` allows you to control access to a portion of the UI based on
/// a fixed time range (`start` to `end`). This is useful for features that should only
/// be visible or active during a specific period—such as flash sales, scheduled promotions,
/// live events, or timed maintenance windows.
///
/// The widget evaluates access periodically using a configurable [checkInterval]
/// (default is 1 second), making it reactive to time updates in real-time.
///
/// ### Example:
/// ```dart
/// TimedAccessGuard(
///   start: DateTime(2025, 7, 19, 10, 0),
///   end: DateTime(2025, 7, 19, 18, 0),
///   builder: (_) => Text("Access allowed"),
///   fallbackBuilder: (_) => Text("Access denied"),
/// )
/// ```
///
/// ### Parameters:
/// - [start]: The beginning of the access window (inclusive).
/// - [end]: The end of the access window (exclusive).
/// - [builder]: The widget to render if current time is within [start] and [end].
/// - [fallbackBuilder]: An optional widget to show outside the time window. If not provided, an empty box is shown.
/// - [checkInterval]: Time interval to evaluate whether current time is still within the range. Defaults to 1 second.
/// - [onTimeUpdate]: Optional callback that receives the remaining time (until `end`) on each evaluation.
///
/// ### Behavior:
/// - If current time is within the window: [builder] is rendered.
/// - If current time is before or after the window: [fallbackBuilder] or `SizedBox.shrink()` is shown.
/// - [onTimeUpdate] is invoked after each tick with remaining time (zero if expired).
///
/// ### Notes:
/// - Time comparisons use `.isAfter(start)` and `.isBefore(end)` — i.e., the range is `(start, end)`.
/// - If `now == start`, the builder will **not** be shown until the clock ticks forward.
/// - `fallbackBuilder` can be used to indicate expired or inactive state.
///
/// ### Use Cases:
/// - Temporarily enable/disable sections of UI based on time
/// - Maintenance banners or blackouts
/// - Scheduled releases or countdowns
/// - Time-limited access to premium features or rewards
///

class TimedAccessGuard extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final WidgetBuilder builder;
  final WidgetBuilder? fallbackBuilder;
  final Duration checkInterval;

  /// Optional callback to send the remaining time on each update.
  final void Function(Duration timeLeft)? onTimeUpdate;

  const TimedAccessGuard({
    super.key,
    required this.start,
    required this.end,
    required this.builder,
    this.fallbackBuilder,
    this.checkInterval = const Duration(seconds: 1),
    this.onTimeUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: GuardUtils.periodicTimeStream(interval: checkInterval),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final isVisible = now.isAfter(start) && now.isBefore(end);

        // Calculate remaining time and call callback if provided
        final timeLeft = end.difference(now).isNegative
            ? Duration.zero
            : end.difference(now);
        if (onTimeUpdate != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onTimeUpdate!(timeLeft);
          });
        }

        if (isVisible) {
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
