import 'package:flutter_test/flutter_test.dart';

import 'package:herbaapp/main.dart';

void main() {
  testWidgets('App boots to splash', (WidgetTester tester) async {
    await tester.pumpWidget(const HerbaApp());
    // The router shows a CircularProgressIndicator while bootstrapping.
    expect(find.byType(HerbaApp), findsOneWidget);
  });
}
