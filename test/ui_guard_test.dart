import 'package:flutter_test/flutter_test.dart';
import 'package:ui_guard/ui_guard.dart';

void main() {
  group('GuardUtils Cron Validation', () {
    test('valid cron expressions', () {
      expect(GuardUtils.isValidCron('* * * * *'), isTrue);
      expect(GuardUtils.isValidCron('0 9 * * 1-5'), isTrue);
      expect(GuardUtils.isValidCron('15,30 10-12 * * 0,6'), isTrue);
    });

    test('invalid cron expressions', () {
      expect(GuardUtils.isValidCron(''), isFalse);
      expect(GuardUtils.isValidCron('0 9 *'), isFalse);
      expect(GuardUtils.isValidCron('60 24 * * *'), isFalse);
      expect(GuardUtils.isValidCron('abc def ghi jkl mno'), isFalse);
    });
  });

  
}
