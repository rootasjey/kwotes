import "package:flutter/material.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/topic.dart";

class CardColorPalette extends StatefulWidget {
  const CardColorPalette({
    super.key,
    required this.name,
    required this.topic,
    this.onTap,
    this.onLongPress,
  });

  /// Card's topic color.
  final Topic topic;

  /// Callback fired when color card is tapped.
  final void Function(Topic topic)? onTap;

  /// Callback fired when color card is long pressed.
  final void Function(Topic topic)? onLongPress;

  /// Color's name.
  final String name;

  @override
  State<CardColorPalette> createState() => _CardColorPaletteState();
}

class _CardColorPaletteState extends State<CardColorPalette> {
  double _elevation = 0.0;

  @override
  Widget build(BuildContext context) {
    return JustTheTooltip(
      preferredDirection: AxisDirection.up,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      tailBaseWidth: 16.0,
      tailLength: 12.0,
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
        child: Text(
          widget.name,
          style: Utils.calligraphy.body2(
            textStyle: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      child: Hero(
        tag: widget.topic.name,
        child: Card(
          color: widget.topic.color,
          elevation: _elevation,
          child: SizedBox(
            width: 48.0,
            height: 48.0,
            child: InkWell(
              onTap: widget.onTap != null
                  ? () => widget.onTap?.call(widget.topic)
                  : null,
              onHover: (bool isHover) {
                setState(() => _elevation = isHover ? 4.0 : 0.0);
              },
              onTapDown: (details) {
                setState(() => _elevation = 0.0);
              },
              onLongPress: widget.onLongPress != null
                  ? () => widget.onLongPress?.call(widget.topic)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
