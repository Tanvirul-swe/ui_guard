import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('RoleBasedApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RoleBasedApp());
    expect(find.byType(RoleBasedApp), findsOneWidget);
  });
}
