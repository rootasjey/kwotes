import "package:flutter/material.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/globals/utils.dart";

class BetterTooltip extends StatelessWidget {
  /// Better tooltip with more customization options.
  const BetterTooltip({
    super.key,
    required this.child,
    required this.tooltipString,
    this.backgroundColor,
  });

  final Widget child;
  final String tooltipString;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (tooltipString.isEmpty) {
      return child;
    }

    return JustTheTooltip(
      tailLength: 4.0,
      tailBaseWidth: 12.0,
      backgroundColor: backgroundColor,
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
      child: child,
    );
  }
}
