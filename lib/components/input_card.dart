import 'package:flutter/material.dart';

/// Show the purpose and current data on a card.
/// Perform an action on tap. Usually show a form to edit data.
class InputCard extends StatelessWidget {
  /// Value's purpose (e.g. 'Name', 'Job', 'Age', ...).
  final String titleString;

  /// Current value (e.g. 'Tap to edit', 'Marie', '42', ...).
  final String subtitleString;

  /// Show an icon on the right side, if provided.
  final Widget icon;

  /// Action performed on tap.
  final VoidCallback onTap;

  /// Padding surronding this widget.
  final EdgeInsets padding;

  /// Card's width.
  final double width;

  /// Card's elevation.
  final double elevation;

  const InputCard({
    Key key,
    @required this.titleString,
    this.icon,
    this.onTap,
    this.subtitleString = "Tap to edit",
    this.padding = const EdgeInsets.only(
      top: 40.0,
      bottom: 20.0,
    ),
    this.width = 250.0,
    this.elevation = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      child: Card(
        elevation: elevation,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 0.4,
                      child: Text(
                        titleString,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    Text(
                      subtitleString,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Opacity(
                opacity: 0.6,
                child: icon,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
