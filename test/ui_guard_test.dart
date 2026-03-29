import 'package:flutter_test/flutter_test.dart';
import 'package:ui_guard/ui_guard.dart';

void main() {
  group('GuardUtils Cron Validation', () {
    test('valid cron expressions', () {
      expect(GuardUtils.isValidCron('* * * * *'), isTrue);
      expect(GuardUtils.isValidCron('0 9 * * 1-5'), isTrue);
      expect(GuardUtils.isValidCron('15,30 10-12 * * 0,6'), isTrue);
      expect(GuardUtils.isValidCron('*/5 * * * *'), isTrue);
      expect(GuardUtils.isValidCron('0 9 * * MON-FRI'), isTrue);
      expect(GuardUtils.isValidCron('@daily'), isTrue);
    });

    test('invalid cron expressions', () {
      expect(GuardUtils.isValidCron(''), isFalse);
      expect(GuardUtils.isValidCron('0 9 *'), isFalse);
      expect(GuardUtils.isValidCron('60 24 * * *'), isFalse);
      expect(GuardUtils.isValidCron('abc def ghi jkl mno'), isFalse);
      expect(GuardUtils.isValidCron('*/0 * * * *'), isFalse);
    });

    test('schedule matcher supports steps and aliases', () {
      final date = DateTime(2025, 1, 6, 10, 15); // Monday
      expect(GuardUtils.isInSchedule('*/5 10 * * MON', now: date), isTrue);
      expect(GuardUtils.isInSchedule('*/7 10 * * MON', now: date), isFalse);
      expect(GuardUtils.isInSchedule('@hourly', now: date), isFalse);
    });
  });
}
