import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/topic.dart";

/// A topic card color with events.
class TopicCard extends StatefulWidget {
  const TopicCard({
    super.key,
    required this.topic,
    this.startElevation = 0.0,
    this.backgroundColor,
    this.foregroundColor,
    this.iconSize = 24.0,
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.size = const Size(100.0, 100.0),
    this.shape,
    this.heroTag,
  });

  /// Background color.
  final Color? backgroundColor;

  /// Foreground color.
  final Color? foregroundColor;

  /// Icon's size.
  final double iconSize;

  /// Start elevation value.
  final double startElevation;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Hero tag.
  final Object? heroTag;

  /// Card shape.
  final ShapeBorder? shape;

  /// Card size.
  final Size size;

  /// Topic color.
  final Topic topic;

  /// Callback fired when a topic color is tapped.
  final void Function(Topic topicColor)? onTap;

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  /// Icon color.
  Color? _iconColor = Colors.transparent;

  /// Icon color on hover.
  Color? _iconHoverColor = Colors.transparent;

  /// card's elevation.
  double _cardElevation = 0.0;
  final double _endElevation = 0.0;

  /// Shake animation value target (to animate on hover).
  double _shakeAnimationTarget = 0.0;

  @override
  void initState() {
    super.initState();
    _iconColor = widget.foregroundColor?.withOpacity(0.6);
    _iconHoverColor = widget.topic.color;
    _cardElevation = widget.startElevation;
  }

  @override
  Widget build(BuildContext context) {
    final Topic topicColor = widget.topic;
    final Color? foregroundColor = widget.foregroundColor;

    return Card(
      margin: widget.margin,
      elevation: _cardElevation,
      color: widget.backgroundColor,
      shadowColor: _iconHoverColor?.withOpacity(0.2),
      shape: widget.shape,
      child: InkWell(
        customBorder: widget.shape,
        splashColor: _iconHoverColor?.withOpacity(0.6),
        onTap:
            widget.onTap != null ? () => widget.onTap?.call(topicColor) : null,
        onHover: (bool isHover) {
          if (isHover) {
            setState(() {
              _cardElevation = widget.startElevation / 2.0;
              _iconColor = _iconHoverColor;
              _shakeAnimationTarget = 1.0;
            });

            return;
          }

          setState(() {
            _cardElevation = widget.startElevation;
            _shakeAnimationTarget = 0.0;
            _iconColor = foregroundColor?.withOpacity(0.6);
          });
        },
        onTapDown: (details) {
          setState(() => _cardElevation = _endElevation);
        },
        onTapUp: (details) {
          setState(() => _cardElevation = widget.startElevation);
        },
        child: Container(
          width: widget.size.width,
          height: widget.size.height,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Utils.graphic.getIconDataFromTopic(topicColor.name),
                color: _iconColor,
                size: widget.iconSize,
              ).animate(target: _shakeAnimationTarget).shake(),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Hero(
                  tag: widget.heroTag ?? topicColor.name,
                  child: Text(
                    topicColor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: 12.0,
                        color: foregroundColor?.withOpacity(0.4),
                        fontWeight: FontWeight.w500,
                      ),
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
