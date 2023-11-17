import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/intents/previous_intent.dart";

class ExpandInputChip extends StatefulWidget {
  /// A chip which expand its content on tap to show a text input.
  const ExpandInputChip({
    super.key,
    this.backgroundColor,
    this.onPressed,
    this.tooltip,
    this.avatar,
    this.elevation,
    this.onTextChanged,
    this.textEditingController,
    this.hintText,
    this.open,
    this.hideCloseIcon = false,
    this.autofocus = false,
    this.margin = EdgeInsets.zero,
    this.width,
    this.borderSide,
    this.onFocusChanged,
    this.onSubmitted,
    this.initialValue,
  });

  /// Request focus on chip's input if true.
  final bool autofocus;

  /// Hide close icon if true.
  final bool hideCloseIcon;

  /// Control input visibility externally
  final bool? open;

  /// Chip's border side.
  final BorderSide? borderSide;

  /// Color to be used for chip's background color.
  final Color? backgroundColor;

  /// Elevation to be applied on the chip relative to its parent.
  /// This controls the size of the shadow below the chip.
  /// Defaults to 0. The value is always non-negative.
  final double? elevation;

  /// Specific width for the chip in opened state.
  final double? width;

  /// Outside space to be applied on the chip relative to its parent.
  final EdgeInsets margin;

  /// Callback fired when the chip is tapped.
  final void Function()? onPressed;

  /// Callback fired when the input text changes.
  final void Function(String value)? onTextChanged;

  /// Callback fired when the input focus has changed.
  final void Function(bool hasFocus)? onFocusChanged;

  /// Callback fired when the input text is submitted.
  final void Function(String value)? onSubmitted;

  /// Hint text for the text input.
  final String? hintText;

  /// Initial value for the text input.
  final String? initialValue;

  /// Tooltip string to be used for the body area
  /// (where the label and avatar are) of the chip.
  final String? tooltip;

  /// Text input controller.
  final TextEditingController? textEditingController;

  /// A widget to display prior to the chip's label.
  final Widget? avatar;

  @override
  State<ExpandInputChip> createState() => _ExpandInputChipState();
}

class _ExpandInputChipState extends State<ExpandInputChip> {
  /// Show text input if this is true.
  bool _open = false;

  /// Block auto focus from chip to text input if true.
  /// Useful for SHIFT + TAB shortcut (to go back to previous focus node).
  /// (We can't go back to previous focus node without this).
  bool _blockInputAutoFocus = false;

  /// Elevation to be applied on the chip relative to its parent.
  double _elevation = 0.0;

  /// Initial elevation.
  double _startElevation = 0.0;

  /// Focus node for input.
  final FocusNode _inputFocusNode = FocusNode();

  /// Focus node for chip (container).
  final FocusNode _chipFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _open = widget.open ?? false;
    _startElevation = widget.elevation ?? 0.0;
    _elevation = _startElevation;
    _inputFocusNode.addListener(onInputFocusChanged);
    _chipFocusNode.addListener(onChipFocusChanged);
  }

  @override
  void dispose() {
    _inputFocusNode.removeListener(onInputFocusChanged);
    _chipFocusNode.removeListener(onChipFocusChanged);
    _inputFocusNode.dispose();
    _chipFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: onMouseEnter,
      onExit: onMouseExit,
      child: Padding(
        padding: widget.margin,
        child: Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
                const PreviousIntent(),
          },
          child: Actions(
            actions: {
              PreviousIntent: CallbackAction<PreviousIntent>(
                onInvoke: onInvokePreviousShortcut,
              ),
            },
            child: ActionChip(
              tooltip: widget.tooltip,
              elevation: _elevation,
              pressElevation: 0.0,
              focusNode: _chipFocusNode,
              onPressed: onActionChipPressed,
              avatar: widget.avatar,
              label: textField(),
              labelPadding: EdgeInsets.zero,
              side: widget.borderSide,
              backgroundColor: getBackgroundColor(),
            ),
          ),
        ),
      ),
    );
  }

  /// Returns the chip's background color according to its open state.
  Color? getBackgroundColor() {
    if (widget.backgroundColor != null) {
      return widget.backgroundColor;
    }

    final Brightness brightness = Theme.of(context).brightness;
    final Color? defaultActiveBackgroundColor = brightness == Brightness.light
        ? Colors.white54
        : Theme.of(context).chipTheme.backgroundColor;

    final Color defaultInactiveBgColor =
        Theme.of(context).scaffoldBackgroundColor;

    if (widget.open == null) {
      return _open ? defaultActiveBackgroundColor : defaultInactiveBgColor;
    }

    return widget.open == true
        ? defaultActiveBackgroundColor
        : defaultInactiveBgColor;
  }

  /// Returns the width of the input text field according to its open state.
  double getInputWidth() {
    final double baseWidth = widget.width ?? 260.0;

    if (widget.open == null) {
      return _open ? baseWidth : 0.0;
    }

    return widget.open == true ? baseWidth : 0.0;
  }

  /// Returns the input text field.
  Widget textField() {
    final double inputWidth = getInputWidth();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.decelerate,
      width: inputWidth,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: max(inputWidth - 24.0, 0.0),
              child: TextFormField(
                autofocus: widget.autofocus,
                focusNode: _inputFocusNode,
                initialValue: widget.initialValue,
                textInputAction: TextInputAction.next,
                controller: widget.textEditingController,
                onChanged: widget.onTextChanged,
                onFieldSubmitted: widget.onSubmitted,
                style: Utils.calligraphy.body(
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.only(
                    left: 6.0,
                    top: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                  ),
                  hintText: widget.hintText,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (!widget.hideCloseIcon)
              CircleButton(
                radius: 12.0,
                backgroundColor: Colors.transparent,
                icon: Icon(
                  TablerIcons.circle_x,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Callback fired when the focus has changed.
  void onInputFocusChanged() {
    widget.onFocusChanged?.call(_inputFocusNode.hasFocus);
  }

  void onActionChipPressed() {
    if (widget.open == null) {
      setState(() {
        _open = !_open;
      });
    }

    _inputFocusNode.requestFocus();
    widget.onPressed?.call();
  }

  void onChipFocusChanged() {
    if (_blockInputAutoFocus) {
      return;
    }

    if (_chipFocusNode.hasFocus) {
      _inputFocusNode.requestFocus();
      return;
    }
  }

  void onMouseEnter(PointerEnterEvent event) {
    setState(() {
      _elevation = 4.0;
    });
  }

  void onMouseExit(PointerExitEvent event) {
    setState(() {
      _elevation = _startElevation;
    });
  }

  Object? onInvokePreviousShortcut(PreviousIntent intent) {
    // 1. We temporarily block text input auto focus.
    _blockInputAutoFocus = true;
    // 2. To allow chip to be focused again
    // and going back to the previous focus node.
    _chipFocusNode.previousFocus();
    // 3. We do it 2 times because there's a focus node on text input AND chip.
    _chipFocusNode.previousFocus();
    // 4. We unblock text input auto focus.
    _blockInputAutoFocus = false;
    return null;
  }
}
