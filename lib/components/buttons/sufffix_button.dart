import "package:flutter/material.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/globals/utils.dart";

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
      child: JustTheTooltip(
        tailLength: 4.0,
        tailBaseWidth: 12.0,
        waitDuration: const Duration(seconds: 1),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            tooltipString,
            style: Utils.calligraphy.body(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        child: IconButton(
          icon: icon,
          onPressed: onPressed,
          // onPressed: () => onHidePasswordChanged?.call(!hidePassword),
        ),
      ),
    );
  }
}
