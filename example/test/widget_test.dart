import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dartllm_example/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const DartLLMExampleApp());

    expect(find.text('DartLLM Chat'), findsOneWidget);
    expect(find.text('No model loaded'), findsOneWidget);
    expect(find.byIcon(Icons.download), findsWidgets);
  });
}
