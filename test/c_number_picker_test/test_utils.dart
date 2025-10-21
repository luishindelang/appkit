import 'package:appkit/appkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Decoration decoration = BoxDecoration(
  border: Border(
    top: BorderSide(style: BorderStyle.solid, color: Colors.black26),
    bottom: BorderSide(style: BorderStyle.solid, color: Colors.black26),
  ),
);

Future<CNumberPicker> testNumberPicker({
  required WidgetTester tester,
  required double min,
  required double max,
  required double initialValue,
  required int scrollBy,
  double step = 1,
  bool animateToItself = false,
  Axis axis = Axis.vertical,
  bool zeroPad = false,
  double itemWidth = 100,
  double itemHeight = 50,
  int itemCount = 3,
  int showDezimal = 0,
  required List<double> expectedDisplayValues,
}) async {
  double value = initialValue;
  late CNumberPicker picker;

  await tester.pumpWidget(
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        picker = CNumberPicker(
          axis: axis,
          value: value,
          min: min,
          max: max,
          step: step,
          zeroPad: zeroPad,
          itemWidth: itemWidth,
          itemHeight: itemHeight,
          itemCount: itemCount,
          infiniteLoop: animateToItself,
          showDezimal: showDezimal,
          onChanged: (newValue) => setState(() => value = newValue),
        );
        return MaterialApp(home: Scaffold(body: picker));
      },
    ),
  );
  expect(value, equals(initialValue));
  await tester.pumpAndSettle();
  final pickerFinder = find.byType(CNumberPicker);

  final scrollable = find.descendant(
    of: pickerFinder,
    matching: find.byWidgetPredicate(
      (w) => w is ListView || w.runtimeType.toString() == 'InfiniteListView',
    ),
  );

  expect(scrollable, findsOneWidget);

  final delta = axis == Axis.vertical
      ? Offset(0, -scrollBy * itemHeight)
      : Offset(-scrollBy * itemWidth, 0);
  await tester.drag(scrollable, delta);

  // await scrollNumberPicker(
  //   Offset(0.0, 0.0),
  //   tester,
  //   scrollBy,
  //   axis,
  //   itemWidth,
  //   itemHeight,
  //   itemCount,
  // );

  expect(value, equals(7));
  await tester.pumpAndSettle();

  for (double displayValue in expectedDisplayValues) {
    expect(
      find.text(displayValue.toStringAsFixed(showDezimal)),
      findsOneWidget,
    );
  }

  return picker;
}

Future<void> scrollNumberPicker(
  Offset pickerPosition,
  WidgetTester tester,
  int scrollBy,
  Axis axis,
  double itemWidth,
  double itemHeight,
  int itemCount,
) async {
  double pickerCenterX, pickerCenterY, offsetX, offsetY;
  double pickerCenterMainAxis =
      (axis == Axis.vertical ? itemHeight : itemWidth) * (itemCount / 2);
  double pickerCenterCrossAxis =
      (axis == Axis.vertical ? itemWidth : itemHeight) / 2;
  if (axis == Axis.vertical) {
    pickerCenterX = pickerCenterCrossAxis;
    pickerCenterY = pickerCenterMainAxis;
    offsetX = 0.0;
    offsetY = -scrollBy * itemHeight;
  } else {
    pickerCenterX = pickerCenterMainAxis;
    pickerCenterY = pickerCenterCrossAxis;
    offsetX = -scrollBy * itemWidth;
    offsetY = 0.0;
  }
  Offset pickerCenter = Offset(
    pickerPosition.dx + pickerCenterX,
    pickerPosition.dy + pickerCenterY,
  );
  final TestGesture testGesture = await tester.startGesture(pickerCenter);
  await testGesture.moveBy(Offset(offsetX, offsetY));
  await testGesture.up();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pumpAndSettle();
}
