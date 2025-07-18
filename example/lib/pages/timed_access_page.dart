import 'package:flutter/material.dart';
import 'package:ui_guard/ui_guard.dart';

class TimedAccessPage extends StatefulWidget {
  const TimedAccessPage({super.key});

  @override
  State<TimedAccessPage> createState() => _TimedAccessPageState();
}

class _TimedAccessPageState extends State<TimedAccessPage> {
  late final DateTime promoStart;
  late final DateTime promoEnd;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    promoStart = now;
    promoEnd = now.add(const Duration(minutes: 10)); // 10-second promo
  }

  void _onTimeUpdate(Duration timeLeft) {
    if (mounted) {
      setState(() {
        _timeLeft = timeLeft.isNegative ? Duration.zero : timeLeft;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⏲️ Timed Access Example')),
      body: Center(
        child: TimedAccessGuard(
          start: promoStart,
          end: promoEnd,
          checkInterval: const Duration(seconds: 1),
          onTimeUpdate: _onTimeUpdate,
          builder:
              (_) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_offer, size: 60, color: Colors.green),
                  const SizedBox(height: 20),
                  const Text(
                    '🎉 Limited-Time Offer!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Offer ends in: ${_timeLeft.inMinutes}m ${_timeLeft.inSeconds.remainder(60)}s ',
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ],
              ),
          fallbackBuilder:
              (_) => Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.timer_off, size: 60, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    '⛔ No active promotions right now.',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
