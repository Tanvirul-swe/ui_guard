import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart'; // import your GuardUtils

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
