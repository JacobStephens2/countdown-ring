import 'package:countdown_ring/countdown_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('shows the clock label while time remains', (tester) async {
    await tester.pumpWidget(_host(
      const CountdownRing(remaining: Duration(seconds: 84), fraction: 0.7),
    ));
    expect(find.text('01:24'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('shows the completed icon at zero', (tester) async {
    await tester.pumpWidget(_host(
      const CountdownRing(remaining: Duration.zero, fraction: 0.0),
    ));
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.textContaining(':'), findsNothing);
  });

  testWidgets('honors the size argument', (tester) async {
    await tester.pumpWidget(_host(
      const CountdownRing(
        remaining: Duration(seconds: 30),
        fraction: 0.5,
        size: 120,
      ),
    ));
    final box = tester.getSize(find.byType(CountdownRing));
    expect(box, const Size(120, 120));
  });
}
