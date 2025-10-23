import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CDropDown<T> extends StatefulWidget {
  /// List with all selectable options
  final List<T> options;

  /// Mapper for the selected Item
  final String Function(T) textMapper;

  /// Called when selected item changes
  final ValueChanged<T>? onChangedItem;

  /// Currently selected item (must be in the options list)
  final T? selectedItem;

  /// is shown when no selectedItem is set
  final String? selectedItemPlaceholder;

  /// Decoration to apply to central box where the selected item is placed
  final Decoration? decoration;

  /// Decoration to apply to the dropDown box where the options are placed
  final Decoration? dropDownDecoration;

  final TextStyle textStyle;
  final Color selectedIconColor;
  final double dropdownIconSize;
  final double paddingHor;
  final double paddingVert;
  final double dropdownOffset;

  final IconData? iconOpen;
  final IconData? iconClosed;

  final bool enabled;
  final double? maxDropdownHeight;

  final bool sizeToWidestItem;

  const CDropDown({
    super.key,
    required this.options,
    required this.textMapper,
    this.onChangedItem,
    this.selectedItem,
    this.selectedItemPlaceholder,
    this.decoration,
    this.dropDownDecoration,
    this.textStyle = const TextStyle(),
    this.selectedIconColor = Colors.black,
    this.dropdownIconSize = 10,
    this.paddingHor = 6,
    this.paddingVert = 2,
    this.dropdownOffset = 8,
    this.iconClosed = Icons.keyboard_arrow_down,
    this.iconOpen,
    this.enabled = true,
    this.maxDropdownHeight,
    this.sizeToWidestItem = true,
  }) : assert((selectedItem == null) != (selectedItemPlaceholder == null));

  @override
  State<CDropDown<T>> createState() => _CDropDownState<T>();
}

class _CDropDownState<T> extends State<CDropDown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  double? _fixedWidth;

  T? _current;
  String get _displayText {
    final v = _current ?? widget.selectedItem;
    if (v != null) return widget.textMapper(v);
    return widget.selectedItemPlaceholder ?? "";
  }

  @override
  void initState() {
    _current = widget.selectedItem;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recomputeFixedWidth();
  }

  @override
  void didUpdateWidget(covariant CDropDown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.selectedItem, widget.selectedItem)) {
      _current = widget.selectedItem;
      _overlayEntry?.markNeedsBuild();
    }

    if (!identical(oldWidget.options, widget.options) &&
        _current != null &&
        !widget.options.contains(_current)) {
      _current = null;
      _overlayEntry?.markNeedsBuild();
    }
    if (oldWidget.options != widget.options ||
        oldWidget.textStyle != widget.textStyle ||
        oldWidget.selectedItemPlaceholder != widget.selectedItemPlaceholder ||
        oldWidget.paddingHor != widget.paddingHor ||
        oldWidget.dropdownIconSize != widget.dropdownIconSize ||
        oldWidget.iconClosed != widget.iconClosed ||
        oldWidget.iconOpen != widget.iconOpen) {
      _recomputeFixedWidth();
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _recomputeFixedWidth() {
    if (!widget.sizeToWidestItem || !mounted) return;

    final textDirection = Directionality.of(context);
    final candidates = <String>[
      if (widget.selectedItemPlaceholder != null)
        widget.selectedItemPlaceholder!,
      ...widget.options.map(widget.textMapper),
    ];

    double maxText = 0;
    for (final s in candidates) {
      final tp = TextPainter(
        text: TextSpan(text: s, style: widget.textStyle),
        maxLines: 1,
        ellipsis: '…',
        textDirection: textDirection,
      )..layout();
      if (tp.width > maxText) maxText = tp.width;
    }

    final iconSpace = (widget.iconClosed != null)
        ? (8 + widget.dropdownIconSize)
        : 0;
    final padding = widget.paddingHor * 2;
    final minTapWidth = 48.0;

    final screenWidth = MediaQuery.of(context).size.width;
    final target = (maxText + iconSpace + padding).clamp(
      minTapWidth,
      screenWidth * 0.95,
    );

    setState(() => _fixedWidth = target);
  }

  void _toggleDropdown() =>
      _isDropdownOpen ? _closeDropdown() : _openDropdown();

  void _openDropdown() {
    if (_overlayEntry != null || widget.options.isEmpty) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isDropdownOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final targetTopLeft = renderBox.localToGlobal(Offset.zero);
    final mq = MediaQuery.of(context);
    final keyboard = mq.viewInsets.bottom;
    final screen = mq.size;

    final spaceBelow =
        screen.height - keyboard - (targetTopLeft.dy + size.height);
    final spaceAbove = targetTopLeft.dy;

    final wantsBelow = spaceBelow >= 200 || spaceBelow >= spaceAbove;
    final maxHeight = widget.maxDropdownHeight ?? 300;
    final available = wantsBelow ? spaceBelow : spaceAbove;
    final actualHeight = available.clamp(120, maxHeight).toDouble();

    BorderRadiusGeometry? radius;
    final box = widget.dropDownDecoration;
    if (box != null && box is BoxDecoration) radius = box.borderRadius;

    return OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeDropdown,
                behavior: HitTestBehavior.opaque,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(
                0,
                wantsBelow
                    ? (size.height + widget.dropdownOffset)
                    : -(actualHeight + widget.dropdownOffset),
              ),
              child: Material(
                elevation: 14.0,
                borderRadius: radius,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: (widget.sizeToWidestItem && _fixedWidth != null)
                        ? _fixedWidth!
                        : size.width,
                    maxHeight: actualHeight,
                  ),
                  child: Container(
                    decoration: widget.dropDownDecoration,
                    child: _buildOptionsList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsList() {
    return ScrollConfiguration(
      behavior: const _NoGlowScroll(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: widget.options.length,
        itemBuilder: (context, index) {
          final option = widget.options[index];
          final selected = option == _current;
          return InkWell(
            onTap: () {
              setState(() => _current = option);
              widget.onChangedItem?.call(option);
              _closeDropdown();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.textMapper(option),
                      style: widget.textStyle,
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check,
                      size: 16,
                      color: widget.selectedIconColor,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            _displayText,
            style: widget.textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.iconClosed != null)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              _isDropdownOpen
                  ? (widget.iconOpen ?? widget.iconClosed)
                  : widget.iconClosed,
              color: widget.selectedIconColor,
              size: widget.dropdownIconSize,
            ),
          ),
      ],
    );

    final trigger = Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.paddingHor,
        vertical: widget.paddingVert,
      ),
      decoration: widget.decoration,
      child: content,
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: Semantics(
        button: true,
        label: 'Dropdown',
        value: _displayText.isEmpty ? 'Keine Auswahl' : _displayText,
        enabled: widget.enabled,
        child: Focus(
          canRequestFocus: widget.enabled,
          onKeyEvent: (node, event) {
            if (event.logicalKey == LogicalKeyboardKey.escape &&
                _isDropdownOpen) {
              _closeDropdown();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: MouseRegion(
            cursor: widget.enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: widget.enabled ? _toggleDropdown : null,
              child: widget.sizeToWidestItem && _fixedWidth != null
                  ? SizedBox(width: _fixedWidth, child: trigger)
                  : trigger,
            ),
          ),
        ),
      ),
    );
  }
}

class _NoGlowScroll extends ScrollBehavior {
  const _NoGlowScroll();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
