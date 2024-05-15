import "package:flutter/material.dart";
import "package:kwotes/components/better_tooltip.dart";

class SuffixButton extends StatelessWidget {
  /// Textfield suffix button.
  /// e.g. show/hide password toggle button.
  const SuffixButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltipString = "",
  });

  /// Callback called when this button is pressed.
  final void Function()? onPressed;

  /// Tooltip text value.
  final String tooltipString;

  /// Icon of this button.
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: BetterTooltip(
        tooltipString: tooltipString,
        child: IconButton(
          icon: icon,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
