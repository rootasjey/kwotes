import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/dot_indicator.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/topic.dart";

/// A topic card color with events.
class TopicCard extends StatefulWidget {
  const TopicCard({
    super.key,
    required this.topic,
    this.isDark = false,
    this.showDot = false,
    this.showLockIcon = false,
    this.showName = true,
    this.startElevation = 0.0,
    this.backgroundColor,
    this.foregroundColor,
    this.iconSize = 24.0,
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.size = const Size(100.0, 100.0),
    this.shape,
    this.heroTag,
    this.onHover,
    this.badge,
  });

  /// Whether to use dark theme.
  final bool isDark;

  /// Show dot indicator if true.
  /// Default: false.
  final bool showDot;

  /// Show lock icon if true.
  final bool showLockIcon;

  /// Show topic name below icon if true.
  /// Default: true.
  final bool showName;

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

  /// Callback fired when a topic color is hovered.
  final void Function(Topic topicColor, bool isHover)? onHover;

  /// Badge widget.
  final Widget? badge;

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  /// Icon color.
  Color? _iconColor = Colors.black;

  /// Icon color on hover.
  Color? _iconHoverColor = Colors.black;

  /// Card's elevation on start.
  double _cardElevation = 0.0;

  /// Card's elevation on hover.
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
    final Topic topic = widget.topic;

    return Card(
      margin: widget.margin,
      elevation: _cardElevation,
      color: widget.backgroundColor,
      shadowColor: _iconHoverColor?.withOpacity(0.2),
      surfaceTintColor: _iconHoverColor,
      shape: widget.shape,
      child: InkWell(
        customBorder: widget.shape,
        splashColor: _iconHoverColor?.withOpacity(0.6),
        onTap: widget.onTap != null ? () => widget.onTap?.call(topic) : null,
        onHover: (bool isHover) {
          widget.onHover?.call(topic, isHover);

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
            _iconColor = _iconHoverColor?.withOpacity(0.6);
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    widget.showLockIcon
                        ? TablerIcons.lock
                        : Utils.graphic.getIconDataFromTopic(topic.name),
                    color: widget.isDark ? _iconColor : null,
                    size: widget.iconSize,
                  ).animate(target: _shakeAnimationTarget).shake(),
                  if (widget.showName)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Hero(
                        tag: widget.heroTag ?? topic.name,
                        child: Text(
                          topic.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 12.0,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: widget.isDark
                                      ? topic.color.withOpacity(0.8)
                                      : topic.color.withOpacity(0.8),
                                  offset: widget.isDark
                                      ? const Offset(1, 1)
                                      : const Offset(2, 2),
                                  blurRadius: widget.isDark ? 1.0 : 4.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (widget.showDot)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: DotIndicator(color: topic.color, size: 4.0),
                    ),
                ],
              ),
              if (widget.badge != null)
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: widget.badge ?? const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
