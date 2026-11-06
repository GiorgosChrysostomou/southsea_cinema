import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

void main() {
  testWidgets('PrimaryButton displays label and responds to tap',
      (WidgetTester tester) async {
    bool buttonPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'BOOK NOW',
            onPressed: () {
              buttonPressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('BOOK NOW'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));

    expect(buttonPressed, isTrue);
  });
}
