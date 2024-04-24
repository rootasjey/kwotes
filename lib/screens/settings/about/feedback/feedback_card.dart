import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class FeedbackCard extends StatelessWidget {
  const FeedbackCard({
    super.key,
    required this.accentColor,
    required this.titleValue,
    this.isMobileSize = false,
    this.selected = false,
    this.onTap,
  });

  /// Whether the screen is mobile.
  final bool isMobileSize;

  /// Whether the card is selected.
  final bool selected;

  /// Card accent color.
  final Color accentColor;

  /// Callback fired when user taps on card.
  final void Function()? onTap;

  /// Card title.
  final String titleValue;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: accentColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: selected
            ? BorderSide(
                color: accentColor,
                width: 2.0,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 100.0,
          height: 100.0,
          padding: const EdgeInsets.all(16.0),
          child: Text(
            titleValue,
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                fontSize: isMobileSize ? 16.0 : 24.0,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                color: accentColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
