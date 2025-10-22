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
        expectedDisplayValues: ["7"],
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
        expectedDisplayValues: ["3"],
      );
    });

    testWidgets('Integer overscroll up to max value', (
      WidgetTester tester,
    ) async {
      await testNumberPicker(
        tester: tester,
        min: 1,
        max: 5,
        initialValue: 3,
        scrollBy: 10,
        itemCount: 1,
        expectedDisplayValues: ["5"],
      );
    });

    testWidgets('Integer overscroll down to min value', (
      WidgetTester tester,
    ) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 8,
        initialValue: 4,
        scrollBy: -10,
        itemCount: 1,
        expectedDisplayValues: ["0"],
      );
    });

    testWidgets('Integer steps works', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 15,
        initialValue: 4,
        scrollBy: 3,
        itemCount: 1,
        step: 2,
        expectedDisplayValues: ["10"],
      );
    });

    testWidgets('Integer steps cuts max value', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 7,
        initialValue: 0,
        scrollBy: 5,
        itemCount: 1,
        step: 3,
        expectedDisplayValues: ["6"],
      );
    });

    testWidgets('Integer Zero pad works', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 10,
        initialValue: 5,
        scrollBy: 1,
        itemCount: 1,
        zeroPad: true,
        expectedDisplayValues: ["06"],
      );
    });

    testWidgets('Integer decoration works', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 10,
        initialValue: 2,
        scrollBy: 2,
        itemCount: 1,
        expectedDisplayValues: ["4"],
        withDeco: true,
      );
    });

    testWidgets('Integer Text mapper works', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 10,
        initialValue: 2,
        scrollBy: 1,
        itemCount: 1,
        textMapper: (value) => "$value hour",
        expectedDisplayValues: ["3 hour"],
      );
    });
  });
}
