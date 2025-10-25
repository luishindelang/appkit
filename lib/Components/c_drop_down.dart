import 'package:flutter/material.dart';

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
  final EdgeInsets? padding;

  /// Decoration to apply to the dropDown box where the options are placed
  final Decoration? dropDownDecoration;
  final EdgeInsets? dropDownItemPadding;

  /// Style of the shown text
  final TextStyle? textStyle;
  final TextStyle? textStyleDropdown;

  /// Offset of the dropdown menu
  final double dropdownOffset;

  /// Icon configuration for the dropdown button
  final IconData? iconOpen;
  final IconData? iconClosed;
  final Color iconColor;
  final double iconSize;

  /// Show icon next to the selected item
  final Icon? selectedIcon;

  /// Background color of the selected item
  final Color? selectedBackgroundColor;

  /// Trigger size
  final double? maxWidth;
  final double? minWidth;

  /// Max height of the dropdown panel (content area)
  final double maxDropdownHeight;

  /// Wenn true, wird der Trigger auf die breiteste Option (inkl. Icon/Padding) fest gesetzt
  final bool sizeToWidestItem;

  /// Can press dropdown button
  final bool enabled;

  const CDropDown({
    super.key,
    required this.options,
    required this.textMapper,
    this.onChangedItem,
    this.selectedItem,
    this.selectedItemPlaceholder,
    this.decoration,
    this.padding,
    this.dropDownDecoration,
    this.dropDownItemPadding,
    this.textStyle,
    this.textStyleDropdown,
    this.dropdownOffset = 8,
    this.iconClosed = Icons.keyboard_arrow_down,
    this.iconOpen,
    this.iconColor = Colors.black,
    this.iconSize = 10,
    this.selectedIcon,
    this.selectedBackgroundColor,
    this.maxWidth,
    this.minWidth,
    this.maxDropdownHeight = 300,
    this.sizeToWidestItem = true,
    this.enabled = true,
  }) : assert((selectedItem == null) != (selectedItemPlaceholder == null));

  @override
  State<CDropDown<T>> createState() => _CDropDownState<T>();
}

class _CDropDownState<T> extends State<CDropDown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  TextStyle? _dropDownTextStyle;

  T? _current;
  String get _displayText {
    final v = _current ?? widget.selectedItem;
    if (v != null) return widget.textMapper(v);
    return widget.selectedItemPlaceholder ?? "";
  }

  @override
  void initState() {
    _current = widget.selectedItem;
    _dropDownTextStyle = widget.textStyleDropdown ?? widget.textStyle;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isDropdownOpen) {
      _overlayEntry?.markNeedsBuild();
    }
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
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  void deactivate() {
    if (_isDropdownOpen) _closeDropdown();
    super.deactivate();
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
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final targetTopLeft = renderBox.localToGlobal(Offset.zero);
    final mq = MediaQuery.of(context);
    final keyboard = mq.viewInsets.bottom;
    final screen = mq.size;

    final spaceBelow =
        screen.height - keyboard - (targetTopLeft.dy + size.height);
    final spaceAbove = targetTopLeft.dy;

    final wantsBelow =
        spaceBelow >= widget.maxDropdownHeight || spaceBelow >= spaceAbove;
    final maxHeight = widget.maxDropdownHeight;
    final available = wantsBelow ? spaceBelow : spaceAbove;
    final actualHeight = available.clamp(0.0, maxHeight).toDouble();

    final triggerWidth = size.width;

    BorderRadiusGeometry? radius;
    final box = widget.dropDownDecoration;
    if (box != null && box is BoxDecoration) radius = box.borderRadius;

    return OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Stack(
          children: [
            GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.opaque,
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
                child: Container(
                  width: triggerWidth,
                  constraints: BoxConstraints(maxHeight: actualHeight),
                  decoration: widget.dropDownDecoration,
                  child: _buildOptionsList(),
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
            child: Container(
              color: selected ? widget.selectedBackgroundColor : null,
              padding: widget.dropDownItemPadding,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.textMapper(option),
                      style: _dropDownTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selected && widget.selectedIcon != null)
                    widget.selectedIcon!,
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
    final trigger = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: widget.minWidth ?? 0,
        maxWidth: widget.maxWidth ?? double.infinity,
      ),
      child: Container(
        padding: widget.padding,
        decoration: widget.decoration,
        child: Row(
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
                  color: widget.iconColor,
                  size: widget.iconSize,
                ),
              ),
          ],
        ),
      ),
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.enabled ? _toggleDropdown : null,
          child: trigger,
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
