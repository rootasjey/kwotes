import "package:flutter/material.dart";

class BetterActionChip extends StatefulWidget {
  /// An action chip which which visually reacts to hover events with emphasis.
  const BetterActionChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.margin = EdgeInsets.zero,
    this.onPressed,
    this.tooltip,
    this.avatar,
    this.elevation,
  });

  /// Color to be used for the unselected, enabled chip's background.
  final Color? backgroundColor;

  /// Elevation to be applied on the chip relative to its parent.
  /// This controls the size of the shadow below the chip.
  /// Defaults to 0. The value is always non-negative.
  final double? elevation;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback fired when the chip is tapped.
  final void Function()? onPressed;

  /// Tooltip string to be used for the body area
  /// (where the label and avatar are) of the chip.
  final String? tooltip;

  /// A widget to display prior to the chip's label.
  final Widget? avatar;

  /// The primary content of the chip.
  final Widget label;

  @override
  State<BetterActionChip> createState() => _BetterActionChipState();
}

class _BetterActionChipState extends State<BetterActionChip> {
  /// Elevation to be applied on the chip relative to its parent.
  double _elevation = 0.0;

  /// Initial elevation.
  double _startElevation = 0.0;

  @override
  void initState() {
    super.initState();
    _startElevation = widget.elevation ?? 0.0;
    _elevation = _startElevation;
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color? defaultBackgroundColor = brightness == Brightness.light
        ? Colors.white54
        : Theme.of(context).chipTheme.backgroundColor;

    final Color? backgroundColor =
        widget.backgroundColor ?? defaultBackgroundColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _elevation = 4.0;
        });
      },
      onExit: (_) {
        setState(() {
          _elevation = _startElevation;
        });
      },
      child: Padding(
        padding: widget.margin,
        child: ActionChip(
          tooltip: widget.tooltip,
          elevation: _elevation,
          pressElevation: 0.0,
          onPressed: widget.onPressed,
          avatar: widget.avatar,
          label: widget.label,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}
