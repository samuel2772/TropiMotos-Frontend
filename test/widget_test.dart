import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tropimotos_app/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const TropiMotosApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
