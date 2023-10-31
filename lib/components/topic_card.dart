import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/topic.dart";

/// A topic card color with events.
class TopicCard extends StatefulWidget {
  const TopicCard({
    super.key,
    required this.topic,
    this.foregroundColor,
    this.onTapTopicColor,
    this.isTiny = false,
  });

  /// Card size is reduced if this is true.
  final bool isTiny;

  /// Foreground color.
  final Color? foregroundColor;

  /// Topic color.
  final Topic topic;

  /// Callback fired when a topic color is tapped.
  final void Function(Topic topicColor)? onTapTopicColor;

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

  /// Shake animation value target (to animate on hover).
  double _shakeAnimationTarget = 0.0;

  @override
  void initState() {
    super.initState();
    _iconColor = widget.foregroundColor?.withOpacity(0.6);
    _iconHoverColor = widget.topic.color;
  }

  @override
  Widget build(BuildContext context) {
    final Topic topicColor = widget.topic;
    final Color? foregroundColor = widget.foregroundColor;
    final Brightness brightness = Theme.of(context).brightness;
    final double dimension = widget.isTiny ? 90.0 : 100.0;

    return Card(
      elevation: _cardElevation,
      color: brightness == Brightness.light ? Colors.white38 : null,
      shadowColor: _iconHoverColor?.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        splashColor: _iconHoverColor?.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8.0),
        onTap: widget.onTapTopicColor != null
            ? () => widget.onTapTopicColor?.call(topicColor)
            : null,
        onHover: (bool isHover) {
          if (isHover) {
            setState(() {
              _cardElevation = 4.0;
              _iconColor = _iconHoverColor;
              _shakeAnimationTarget = 1.0;
            });

            return;
          }

          setState(() {
            _cardElevation = 0.0;
            _shakeAnimationTarget = 0.0;
            _iconColor = foregroundColor?.withOpacity(0.6);
          });
        },
        child: Container(
          width: dimension,
          height: dimension,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Utils.graphic.getIconDataFromTopic(topicColor.name),
                color: _iconColor,
              ).animate(target: _shakeAnimationTarget).shake(),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
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
            ],
          ),
        ),
      ),
    );
  }
}
