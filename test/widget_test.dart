// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:project_prm393_nhom6/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // This is intentionally minimal. The real app uses providers + Hive init in main().
    await tester.pumpWidget(const FinanceApp());
    expect(find.byType(FinanceApp), findsOneWidget);
  });
}
