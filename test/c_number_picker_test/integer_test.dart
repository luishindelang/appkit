import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  group("integer Tests", () {
    testWidgets('Integer small scroll up works', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 1,
        max: 10,
        initialValue: 5,
        scrollBy: 2,
        itemCount: 1,
        expectedDisplayValues: [7],
      );
    });

    testWidgets('Integer small scroll down works', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 1,
        max: 10,
        initialValue: 5,
        scrollBy: -2,
        itemCount: 1,
        expectedDisplayValues: [3],
      );
    });
  });
}
