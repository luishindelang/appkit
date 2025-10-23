import 'package:flutter_test/flutter_test.dart';
import 'test_utils.dart';

void main() {
  group("itemCount Tests", () {
    testWidgets('Two items', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 10,
        initialValue: 0,
        scrollBy: 3,
        itemCount: 2,
        step: 2,
        expectedDisplayValues: ["6", "8"],
      );
    });

    testWidgets('Tree items', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 10,
        initialValue: 1,
        scrollBy: 5,
        itemCount: 3,
        step: 1,
        expectedDisplayValues: ["5", "6", "7"],
      );
    });

    testWidgets('Four items', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 10,
        initialValue: 1,
        scrollBy: 5,
        itemCount: 4,
        step: 1,
        expectedDisplayValues: ["5", "6", "7", "8"],
      );
    });

    testWidgets('five items', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 10,
        initialValue: 1,
        scrollBy: 4,
        itemCount: 5,
        step: 1,
        expectedDisplayValues: ["3", "4", "5", "6", "7"],
      );
    });
  });
}
