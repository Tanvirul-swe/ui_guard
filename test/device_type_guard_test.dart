import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_guard/ui_guard.dart';

void main() {
  group('DeviceType enum & parser tests', () {
    test('tryParse handles standard names and case-insensitivity', () {
      expect(DeviceType.tryParse('mobile'), equals(DeviceType.mobile));
      expect(DeviceType.tryParse('Mobile'), equals(DeviceType.mobile));
      expect(DeviceType.tryParse('  MOBILE  '), equals(DeviceType.mobile));
      expect(DeviceType.tryParse('tablet'), equals(DeviceType.tablet));
      expect(DeviceType.tryParse('Tablet'), equals(DeviceType.tablet));
      expect(DeviceType.tryParse('desktop'), equals(DeviceType.desktop));
      expect(DeviceType.tryParse('web'), equals(DeviceType.web));
      expect(DeviceType.tryParse('android'), equals(DeviceType.android));
      expect(DeviceType.tryParse('ios'), equals(DeviceType.ios));
      expect(DeviceType.tryParse('macos'), equals(DeviceType.macos));
      expect(DeviceType.tryParse('windows'), equals(DeviceType.windows));
      expect(DeviceType.tryParse('linux'), equals(DeviceType.linux));
      expect(DeviceType.tryParse('fuchsia'), equals(DeviceType.fuchsia));
    });

    test('tryParse handles common aliases', () {
      expect(DeviceType.tryParse('phone'), equals(DeviceType.mobile));
      expect(DeviceType.tryParse('cellphone'), equals(DeviceType.mobile));
      expect(DeviceType.tryParse('handset'), equals(DeviceType.mobile));
      expect(DeviceType.tryParse('tab'), equals(DeviceType.tablet));
      expect(DeviceType.tryParse('ipad'), equals(DeviceType.tablet));
      expect(DeviceType.tryParse('pc'), equals(DeviceType.desktop));
      expect(DeviceType.tryParse('laptop'), equals(DeviceType.desktop));
      expect(DeviceType.tryParse('mac'), equals(DeviceType.desktop));
      expect(DeviceType.tryParse('computer'), equals(DeviceType.desktop));
      expect(DeviceType.tryParse('browser'), equals(DeviceType.web));
      expect(DeviceType.tryParse('webpage'), equals(DeviceType.web));
      expect(DeviceType.tryParse('iphone'), equals(DeviceType.ios));
      expect(DeviceType.tryParse('osx'), equals(DeviceType.macos));
      expect(DeviceType.tryParse('win'), equals(DeviceType.windows));
    });

    test('tryParse returns null for invalid strings', () {
      expect(DeviceType.tryParse(''), isNull);
      expect(DeviceType.tryParse('unknown_device'), isNull);
      expect(DeviceType.tryParse('smartwatch'), isNull);
    });

    test('fromString parses valid string and throws on invalid', () {
      expect(DeviceType.fromString('mobile'), equals(DeviceType.mobile));
      expect(DeviceType.fromString('desktop'), equals(DeviceType.desktop));
      expect(
        () => DeviceType.fromString('invalid_device'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('from handles DeviceType, String, and invalid types', () {
      expect(DeviceType.from(DeviceType.tablet), equals(DeviceType.tablet));
      expect(DeviceType.from('tablet'), equals(DeviceType.tablet));
      expect(DeviceType.from(123), isNull);
      expect(DeviceType.from(null), isNull);
      expect(DeviceType.from('invalid'), isNull);
    });

    test('fromWidth determines device type from width', () {
      expect(DeviceType.fromWidth(320), equals(DeviceType.mobile));
      expect(DeviceType.fromWidth(599), equals(DeviceType.mobile));
      expect(DeviceType.fromWidth(600), equals(DeviceType.tablet));
      expect(DeviceType.fromWidth(1023), equals(DeviceType.tablet));
      expect(DeviceType.fromWidth(1024), equals(DeviceType.desktop));
      expect(DeviceType.fromWidth(1920), equals(DeviceType.desktop));
    });

    test('boolean helper getters return correct values', () {
      expect(DeviceType.mobile.isMobile, isTrue);
      expect(DeviceType.mobile.isTablet, isFalse);
      expect(DeviceType.tablet.isTablet, isTrue);
      expect(DeviceType.desktop.isDesktop, isTrue);
      expect(DeviceType.web.isWeb, isTrue);
      expect(DeviceType.android.isMobilePlatform, isTrue);
      expect(DeviceType.ios.isMobilePlatform, isTrue);
      expect(DeviceType.macos.isDesktopPlatform, isTrue);
      expect(DeviceType.windows.isDesktopPlatform, isTrue);
      expect(DeviceType.linux.isDesktopPlatform, isTrue);
    });
  });

  group('DeviceBreakpoints tests', () {
    test('default breakpoints', () {
      const bp = DeviceBreakpoints();
      expect(bp.mobileBreakpoint, equals(600.0));
      expect(bp.tabletBreakpoint, equals(1024.0));
    });

    test('custom breakpoints validation', () {
      const bp = DeviceBreakpoints(
        mobileBreakpoint: 500.0,
        tabletBreakpoint: 800.0,
      );
      expect(bp.mobileBreakpoint, equals(500.0));
      expect(bp.tabletBreakpoint, equals(800.0));

      expect(
        () => DeviceBreakpoints(
          mobileBreakpoint: 900.0,
          tabletBreakpoint: 800.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('equality and hashCode', () {
      const bp1 = DeviceBreakpoints(mobileBreakpoint: 600, tabletBreakpoint: 1024);
      const bp2 = DeviceBreakpoints(mobileBreakpoint: 600, tabletBreakpoint: 1024);
      const bp3 = DeviceBreakpoints(mobileBreakpoint: 500, tabletBreakpoint: 900);

      expect(bp1, equals(bp2));
      expect(bp1.hashCode, equals(bp2.hashCode));
      expect(bp1, isNot(equals(bp3)));
    });
  });

  group('DeviceTypeGuard Widget Tests', () {
    tearDown(() {
      GuardConfig.developerOverrideEnabled = false;
      GuardConfig.deviceBreakpoints = const DeviceBreakpoints();
    });

    testWidgets(
      'Issue #9 Planned API: renders builder when allowedDevices matches mobile screen',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: DeviceTypeGuard(
              allowedDevices: const ['mobile', 'tablet'],
              builder: (_) => const Text('MobileView'),
              fallbackBuilder: (_) => const Text('DesktopView'),
            ),
          ),
        );

        expect(find.text('MobileView'), findsOneWidget);
        expect(find.text('DesktopView'), findsNothing);
      },
    );

    testWidgets(
      'renders fallbackBuilder when allowedDevices does not match desktop screen',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: DeviceTypeGuard(
              allowedDevices: const ['mobile', 'tablet'],
              builder: (_) => const Text('MobileView'),
              fallbackBuilder: (_) => const Text('DesktopView'),
            ),
          ),
        );

        expect(find.text('DesktopView'), findsOneWidget);
        expect(find.text('MobileView'), findsNothing);
      },
    );

    testWidgets('renders builder using enum values in allowedDevices', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: DeviceTypeGuard(
            allowedDevices: const [DeviceType.desktop],
            builder: (_) => const Text('Desktop Content'),
            fallbackBuilder: (_) => const Text('Fallback Content'),
          ),
        ),
      );

      expect(find.text('Desktop Content'), findsOneWidget);
      expect(find.text('Fallback Content'), findsNothing);
    });

    testWidgets('renders empty container if fallbackBuilder is null and access is denied', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: DeviceTypeGuard(
            allowedDevices: const ['mobile'],
            builder: (_) => const Text('Mobile Only'),
          ),
        ),
      );

      expect(find.text('Mobile Only'), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('supports child and fallback parameters', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: DeviceTypeGuard(
            allowedDevices: ['mobile'],
            fallback: Text('Fallback View'),
            child: Text('Child View'),
          ),
        ),
      );

      expect(find.text('Child View'), findsOneWidget);
      expect(find.text('Fallback View'), findsNothing);
    });

    testWidgets('supports explicit currentDevice override', (tester) async {
      // Regardless of tester screen size, currentDevice forces tablet
      await tester.pumpWidget(
        MaterialApp(
          home: DeviceTypeGuard(
            allowedDevices: const ['tablet'],
            currentDevice: DeviceType.tablet,
            builder: (_) => const Text('Tablet Layout'),
            fallbackBuilder: (_) => const Text('Other Layout'),
          ),
        ),
      );

      expect(find.text('Tablet Layout'), findsOneWidget);
      expect(find.text('Other Layout'), findsNothing);
    });

    testWidgets('supports explicit currentDevices set override', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DeviceTypeGuard(
            allowedDevices: const ['web'],
            currentDevices: const {DeviceType.web, DeviceType.desktop},
            builder: (_) => const Text('Web Feature'),
            fallbackBuilder: (_) => const Text('Native Feature'),
          ),
        ),
      );

      expect(find.text('Web Feature'), findsOneWidget);
      expect(find.text('Native Feature'), findsNothing);
    });

    testWidgets('adapts responsively to window resizing across breakpoints', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final widget = MaterialApp(
        home: DeviceTypeGuard(
          allowedDevices: const ['tablet'],
          builder: (_) => const Text('Tablet Only'),
          fallbackBuilder: (_) => const Text('Not Tablet'),
        ),
      );

      // 1. Phone width (400) -> not tablet
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpWidget(widget);
      expect(find.text('Not Tablet'), findsOneWidget);
      expect(find.text('Tablet Only'), findsNothing);

      // 2. Tablet width (768) -> tablet
      tester.view.physicalSize = const Size(768, 1024);
      await tester.pumpWidget(widget);
      expect(find.text('Tablet Only'), findsOneWidget);
      expect(find.text('Not Tablet'), findsNothing);

      // 3. Desktop width (1200) -> not tablet
      tester.view.physicalSize = const Size(1200, 900);
      await tester.pumpWidget(widget);
      expect(find.text('Not Tablet'), findsOneWidget);
      expect(find.text('Tablet Only'), findsNothing);
    });

    testWidgets('respects custom breakpoints', (tester) async {
      tester.view.physicalSize = const Size(550, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // With default breakpoints (mobile < 600), 550 is mobile.
      // With custom mobileBreakpoint: 500, 550 is tablet.
      await tester.pumpWidget(
        MaterialApp(
          home: DeviceTypeGuard(
            allowedDevices: const ['tablet'],
            breakpoints: const DeviceBreakpoints(
              mobileBreakpoint: 500,
              tabletBreakpoint: 900,
            ),
            builder: (_) => const Text('Custom Tablet View'),
            fallbackBuilder: (_) => const Text('Custom Fallback'),
          ),
        ),
      );

      expect(find.text('Custom Tablet View'), findsOneWidget);
      expect(find.text('Custom Fallback'), findsNothing);
    });

    testWidgets('invokes onDecision callback with detailed decision', (tester) async {
      AccessDecision? capturedDecision;

      await tester.pumpWidget(
        MaterialApp(
          home: DeviceTypeGuard(
            allowedDevices: const ['desktop'],
            currentDevice: DeviceType.mobile,
            onDecision: (decision) => capturedDecision = decision,
            builder: (_) => const Text('Desktop View'),
            fallbackBuilder: (_) => const Text('Denied View'),
          ),
        ),
      );

      expect(capturedDecision, isNotNull);
      expect(capturedDecision!.allowed, isFalse);
      expect(capturedDecision!.failedCondition, isTrue);
      expect(capturedDecision!.reasonCode, equals('device_type_guard_denied'));
      expect(find.text('Denied View'), findsOneWidget);
    });

    testWidgets('custom deviceEvaluator overrides default matching logic', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DeviceTypeGuard(
            allowedDevices: const ['mobile'],
            currentDevice: DeviceType.mobile,
            deviceEvaluator: (currentTypes, allowedTypes) => false, // explicitly disallow
            builder: (_) => const Text('Allowed View'),
            fallbackBuilder: (_) => const Text('Disallowed View'),
          ),
        ),
      );

      expect(find.text('Disallowed View'), findsOneWidget);
      expect(find.text('Allowed View'), findsNothing);
    });

    testWidgets('GuardConfig.developerOverrideEnabled bypasses device check', (tester) async {
      GuardConfig.developerOverrideEnabled = true;

      await tester.pumpWidget(
        MaterialApp(
          home: DeviceTypeGuard(
            allowedDevices: const ['desktop'],
            currentDevice: DeviceType.mobile,
            builder: (_) => const Text('Developer Override Allowed'),
            fallbackBuilder: (_) => const Text('Denied'),
          ),
        ),
      );

      expect(find.text('Developer Override Allowed'), findsOneWidget);
      expect(find.text('Denied'), findsNothing);
    });

    testWidgets('rebuilds when rebuildListenable updates', (tester) async {
      final notifier = ValueNotifier<DeviceType>(DeviceType.mobile);
      addTearDown(notifier.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<DeviceType>(
            valueListenable: notifier,
            builder: (context, current, _) {
              return DeviceTypeGuard(
                allowedDevices: const ['desktop'],
                currentDevice: current,
                rebuildListenable: notifier,
                builder: (_) => const Text('Desktop Content'),
                fallbackBuilder: (_) => const Text('Mobile Fallback'),
              );
            },
          ),
        ),
      );

      expect(find.text('Mobile Fallback'), findsOneWidget);

      notifier.value = DeviceType.desktop;
      await tester.pump();

      expect(find.text('Desktop Content'), findsOneWidget);
    });
  });

  group('GuardUtils Device Methods Tests', () {
    test('isDeviceTypeAllowed checks single device correctly', () {
      expect(
        GuardUtils.isDeviceTypeAllowed(
          currentDevice: DeviceType.mobile,
          allowedDevices: ['mobile', 'tablet'],
        ),
        isTrue,
      );
      expect(
        GuardUtils.isDeviceTypeAllowed(
          currentDevice: DeviceType.desktop,
          allowedDevices: ['mobile', 'tablet'],
        ),
        isFalse,
      );
      expect(
        GuardUtils.isDeviceTypeAllowed(
          currentDevice: DeviceType.desktop,
          allowedDevices: [DeviceType.desktop],
        ),
        isTrue,
      );
    });
  });
}
