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
  bool withDeco = false,
  String Function(String)? textMapper,
  required List<String> expectedDisplayValues,
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
          decoration: withDeco ? decoration : null,
          textMapper: textMapper,
          onChanged: (newValue) => setState(() => value = newValue),
        );
        return MaterialApp(home: Scaffold(body: picker));
      },
    ),
  );
  expect(value, equals(initialValue));

  await scrollNumberPicker(
    Offset(0.0, 0.0),
    tester,
    scrollBy,
    axis,
    itemWidth,
    itemHeight,
    itemCount,
  );

  await tester.pumpAndSettle();

  for (String displayValue in expectedDisplayValues) {
    expect(find.text(displayValue), findsOneWidget);
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
}
