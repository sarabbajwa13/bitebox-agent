// Basic smoke test for the BiteBox Agent app.
import 'package:flutter_test/flutter_test.dart';

import 'package:bitebox_agent/main.dart';

void main() {
  testWidgets('App boots and shows the agent login', (tester) async {
    await tester.pumpWidget(const BiteBoxAgentApp());
    await tester.pump();

    // Login screen shows the business name.
    expect(find.text('BiteBox Agent'), findsWidgets);
  });
}
