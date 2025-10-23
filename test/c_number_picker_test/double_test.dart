import 'package:flutter_test/flutter_test.dart';
import 'test_utils.dart';

void main() {
  group("Double Tests", () {
    testWidgets('Double small scroll up works', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 1,
        initialValue: 0.5,
        step: 0.1,
        scrollBy: 2,
        itemCount: 1,
        showDezimal: 1,
        expectedDisplayValues: ["0.7"],
      );
    });

    testWidgets('Double small scroll down works', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0.1,
        max: 0.6,
        initialValue: 0.3,
        step: 0.1,
        scrollBy: -2,
        itemCount: 1,
        showDezimal: 1,
        expectedDisplayValues: ["0.1"],
      );
    });

    testWidgets('Double overscroll up to max value', (
      WidgetTester tester,
    ) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 0.5,
        initialValue: 0.3,
        step: 0.1,
        scrollBy: 10,
        itemCount: 1,
        showDezimal: 1,
        expectedDisplayValues: ["0.5"],
      );
    });

    testWidgets('Double overscroll down to min value', (
      WidgetTester tester,
    ) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 0.8,
        initialValue: 0.4,
        step: 0.1,
        scrollBy: -10,
        itemCount: 1,
        showDezimal: 1,
        expectedDisplayValues: ["0.0"],
      );
    });

    testWidgets('Double steps works', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 1.5,
        initialValue: 0.4,
        step: 0.2,
        scrollBy: 2,
        itemCount: 1,
        showDezimal: 1,
        expectedDisplayValues: ["0.8"],
      );
    });

    testWidgets('Double steps cuts max value', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 0.7,
        initialValue: 0,
        step: 0.3,
        scrollBy: 5,
        itemCount: 1,
        showDezimal: 1,
        expectedDisplayValues: ["0.6"],
      );
    });

    testWidgets('Double zero pad works', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 10,
        initialValue: 0.5,
        step: 0.5,
        scrollBy: 1,
        itemCount: 1,
        zeroPad: true,
        showDezimal: 1,
        expectedDisplayValues: ["01.0"],
      );
    });

    testWidgets('Double more dezimal works', (WidgetTester tester) async {
      await testNumberPicker(
        tester: tester,
        min: 0,
        max: 1,
        initialValue: 0.5,
        step: 0.125,
        scrollBy: 1,
        itemCount: 1,
        showDezimal: 3,
        expectedDisplayValues: ["0.625"],
      );
    });
  });
}
