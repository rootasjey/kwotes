import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.icon,
    this.cardBackgroundColor,
    this.width = 100.0,
    this.height = 100.0,
    this.margin = const EdgeInsets.all(4.0),
    this.onTap,
    this.labelValue = "",
  });

  /// The background color of the card.
  final Color? cardBackgroundColor;

  /// The width of the card.
  final double width;

  /// The height of the card.
  final double height;

  /// The margin of the card.
  final EdgeInsetsGeometry margin;

  /// Callback fired when the card is tapped.
  final void Function()? onTap;

  /// The label value to display.
  final String labelValue;

  /// The icon to display.
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 0.0,
        margin: margin,
        color: cardBackgroundColor,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              if (labelValue.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    labelValue,
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
