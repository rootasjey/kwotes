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

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(textLabel),
      labelStyle: Utils.calligraphy.body(
        textStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: foregroundColor,
        ),
      ),
      onPressed: onTap,
      backgroundColor: selected ? accentColor : null,
    );
  }
}
