import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class ThemeChip extends StatelessWidget {
  const ThemeChip({
    super.key,
    required this.textLabel,
    required this.selected,
    required this.accentColor,
    this.foregroundColor,
    this.onTap,
    this.tooltip,
  });

  /// Theme name.
  final String textLabel;

  /// Whether the chip is selected.
  /// This will change the text color.
  final bool selected;

  /// Chip will take this color when selected.
  final Color accentColor;

  /// Theme name foreground color.
  final Color? foregroundColor;

  /// Called when the chip is tapped.
  final void Function()? onTap;

  /// Optional tooltip.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Utils.graphic.tooltip(
      tooltipString: tooltip ?? "",
      child: ActionChip(
        label: Text(textLabel),
        labelStyle: Utils.calligraphy.body(
          textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: foregroundColor,
          ),
        ),
        shape: const StadiumBorder(),
        onPressed: onTap,
        backgroundColor: selected ? accentColor : null,
      ),
    );
  }
}
