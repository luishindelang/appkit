import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'dart:math' as math;

typedef TextMapper = String Function(String numberText);

class CNumberPicker extends StatefulWidget {
  /// Currently selected value
  final double value;

  /// Called when selected value changes
  final Function(double) onChanged;

  /// Step between elements
  final double step;

  /// Min value can be picked
  final double min;

  /// Max value can be picked
  final double max;

  /// width of one item in pixels
  final double itemWidth;

  /// height of one item in pixels
  final double itemHeight;

  /// how many items are visible in total
  final int itemCount;

  /// Direction of scrolling
  final Axis axis;

  /// how many decimal places should be shown
  final int showDezimal;

  /// Style of non-selected numbers. If null, it uses Theme's bodyText2
  final TextStyle? textStyle;

  /// Style of non-selected numbers. If null, it uses Theme's headline5 with accentColor
  final TextStyle? selectedTextStyle;

  /// max can not be null if this is true
  final bool infiniteLoop;

  /// Pads displayed integer values up to the length of maxValue
  final bool zeroPad;

  /// Decoration to apply to central box where the selected value is placed
  final Decoration? decoration;

  /// Whether to trigger haptic pulses or not
  final bool haptics;

  final TextMapper? textMapper;

  const CNumberPicker({
    super.key,
    required this.value,
    required this.onChanged,
    required this.step,
    required this.min,
    required this.max,
    this.itemWidth = 100,
    this.itemHeight = 50,
    this.itemCount = 1,
    this.axis = Axis.vertical,
    this.showDezimal = 2,
    this.textStyle,
    this.selectedTextStyle,
    this.infiniteLoop = false,
    this.zeroPad = false,
    this.decoration,
    this.haptics = false,
    this.textMapper,
  }) : assert(min <= value),
       assert(max >= value);

  @override
  State<CNumberPicker> createState() => _CNumberPickerState();
}

class _CNumberPickerState extends State<CNumberPicker> {
  late ScrollController _scrollController;

  bool get isScrolling => _scrollController.position.isScrollingNotifier.value;

  double get itemExtent =>
      widget.axis == Axis.vertical ? widget.itemHeight : widget.itemWidth;

  int get additionalOnEnd => widget.itemCount.isEven ? 1 : 0;

  int get additionalItemOnBegin => (widget.itemCount - 1) ~/ 2;
  int get additionalItemOnEnd =>
      ((widget.itemCount - 1) ~/ 2) + additionalOnEnd;

  int _pow10(int n) =>
      (n <= 0) ? 1 : List.filled(n, 0).fold(1, (p, _) => p * 10);
  int get _scale => _pow10(widget.showDezimal);

  int _toTicks(double v) => (v * _scale).round();
  double _fromTicks(int t) => t / _scale;

  int get _minT => _toTicks(widget.min);
  int get _maxT => _toTicks(widget.max);
  int get _stepT => math.max(1, _toTicks(widget.step));
  int get _valueT => _toTicks(widget.value);

  int get itemCount {
    final spanT = _maxT - _minT;
    final steps = (spanT / _stepT).floor();
    return steps + 1;
  }

  int get listItemsCount =>
      itemCount + additionalItemOnBegin + additionalItemOnEnd;

  @override
  void initState() {
    super.initState();
    final idx = ((_valueT - _minT) / _stepT).round();
    final initialOffset = idx * itemExtent;
    _scrollController = widget.infiniteLoop
        ? InfiniteScrollController(initialScrollOffset: initialOffset)
        : ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    var indexOfMiddleElement = (_scrollController.offset / itemExtent).round();
    if (widget.infiniteLoop) {
      indexOfMiddleElement %= itemCount;
    } else {
      indexOfMiddleElement = indexOfMiddleElement.clamp(0, itemCount - 1);
    }
    final intValueInTheMiddle = _intValueFromIndex(
      indexOfMiddleElement + additionalItemOnBegin,
    );

    if (widget.value != intValueInTheMiddle) {
      widget.onChanged(intValueInTheMiddle);
      if (widget.haptics) {
        HapticFeedback.selectionClick();
      }
    }
    Future.delayed(Duration(milliseconds: 100), () => _maybeCenterValue());
  }

  @override
  void didUpdateWidget(CNumberPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _maybeCenterValue();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.axis == Axis.vertical
          ? widget.itemWidth
          : widget.itemCount * widget.itemWidth,
      height: widget.axis == Axis.vertical
          ? widget.itemCount * widget.itemHeight
          : widget.itemHeight,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (not) {
          if (not.dragDetails?.primaryVelocity == 0) {
            Future.microtask(() => _maybeCenterValue());
          }
          return false;
        },
        child: Stack(
          children: [
            if (widget.infiniteLoop)
              InfiniteListView.builder(
                scrollDirection: widget.axis,
                controller: _scrollController as InfiniteScrollController,
                itemExtent: itemExtent,
                itemBuilder: _itemBuilder,
                padding: EdgeInsets.zero,
              )
            else
              ListView.builder(
                itemCount: listItemsCount,
                scrollDirection: widget.axis,
                controller: _scrollController,
                itemExtent: itemExtent,
                itemBuilder: _itemBuilder,
                padding: EdgeInsets.zero,
              ),
            _NumberPickerSelectedItemDecoration(
              axis: widget.axis,
              itemExtent: itemExtent,
              decoration: widget.decoration,
            ),
          ],
        ),
      ),
    );
  }

  bool _isSelected(double v) => _toTicks(v) == _valueT;

  Widget _itemBuilder(BuildContext context, int index) {
    final themeData = Theme.of(context);
    final defaultStyle = widget.textStyle ?? themeData.textTheme.bodyMedium;
    final selectedStyle =
        widget.selectedTextStyle ??
        themeData.textTheme.headlineSmall?.copyWith(
          color: themeData.colorScheme.secondary,
        );

    final value = _intValueFromIndex(index % itemCount);

    final isExtra =
        !widget.infiniteLoop &&
        (index < additionalItemOnBegin ||
            index >= listItemsCount - additionalItemOnEnd);

    final itemStyle = _isSelected(value) ? selectedStyle : defaultStyle;

    final child = isExtra
        ? SizedBox.shrink()
        : Text(_getDisplayedValue(value), style: itemStyle);

    return Container(
      width: widget.itemWidth,
      height: widget.itemHeight,
      alignment: Alignment.center,
      child: child,
    );
  }

  String _getDisplayedValue(double value) {
    String text = value.toStringAsFixed(widget.showDezimal);
    if (widget.zeroPad) {
      String maxNumber = widget.max.toString().split(".").first;
      if (widget.showDezimal != 0) {
        text = text.padLeft(maxNumber.length + widget.showDezimal + 1, '0');
      } else {
        text = text.padLeft(maxNumber.length, '0');
      }
    }
    if (widget.textMapper != null) return widget.textMapper!(text);

    return text;
  }

  double _intValueFromIndex(int index) {
    index -= additionalItemOnBegin;
    index %= itemCount;
    final t = _minT + index * _stepT;
    return _fromTicks(t);
  }

  void _maybeCenterValue() {
    if (!_scrollController.hasClients || isScrolling) return;

    final rawIndex = ((_valueT - _minT) / _stepT);
    final index = rawIndex.clamp(0, (itemCount - 1).toDouble());
    final target = index * itemExtent;

    final maxExtent = _scrollController.position.maxScrollExtent;
    final clamped = target.clamp(0.0, maxExtent);

    _scrollController.animateTo(
      clamped,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
}

class _NumberPickerSelectedItemDecoration extends StatelessWidget {
  final Axis axis;
  final double itemExtent;
  final Decoration? decoration;
  const _NumberPickerSelectedItemDecoration({
    required this.axis,
    required this.itemExtent,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IgnorePointer(
        child: Container(
          width: isVertical ? double.infinity : itemExtent,
          height: isVertical ? itemExtent : double.infinity,
          decoration: decoration,
        ),
      ),
    );
  }

  bool get isVertical => axis == Axis.vertical;
}
