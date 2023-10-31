import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";

/// A tiny card showing the first letter of a quote
/// (displayed on home page).
class TinyCard extends StatefulWidget {
  const TinyCard({
    super.key,
    required this.quote,
    this.screenSize = Size.infinite,
    this.onTap,
    this.entranceDelay,
  });

  /// Animation entrance delay.
  final Duration? entranceDelay;

  /// Quote to display.
  final Quote quote;

  /// Callback fired when card is tapped.
  final void Function(Quote quote)? onTap;

  final Size screenSize;

  @override
  State<TinyCard> createState() => _TinyCardState();
}

class _TinyCardState extends State<TinyCard> {
  /// Card's elevation.
  double _elevation = 0.0;

  /// Card's initial elevation.
  final double _initialElevation = 0.0;

  /// Card's end elevation.
  final double _endElevation = 4.0;

  @override
  Widget build(BuildContext context) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(4.0));
    final Color textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    final String quoteName = widget.quote.name;
    final String firstChar = quoteName.characters.first;

    final Widget squareLetter = Hero(
      tag: widget.quote.id,
      child: Material(
        elevation: _elevation,
        borderRadius: borderRadius,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: InkWell(
          onTap: () => widget.onTap?.call(widget.quote),
          onHover: (isHover) {
            setState(() {
              _elevation = isHover ? _endElevation : _initialElevation;
            });
          },
          borderRadius: borderRadius,
          child: Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(
                width: _elevation == _initialElevation ? 0.0 : 3.0,
                color: _elevation == _initialElevation
                    ? Colors.transparent
                    : getTopicColor(),
              ),
            ),
            child: Center(
              child: Text(
                firstChar,
                style: Utils.calligraphy.body4(
                  textStyle: const TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate(
          delay: widget.entranceDelay,
        )
        .fadeIn()
        .slideY(begin: -0.1, end: 0.0)
        .scaleXY(begin: 1.6, end: 1.0);

    if (widget.screenSize.width < 700.0) {
      return squareLetter;
    }

    return JustTheTooltip(
      content: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(
            getSizeConstraints(widget.screenSize),
          ),
          child: Text(
            quoteName,
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
      child: squareLetter,
    );
  }

  Color getTopicColor() {
    final String firstTopic = widget.quote.topics.first;
    final Topic topic = Constants.colors.topics.firstWhere(
      (element) => element.name == firstTopic,
      orElse: () {
        return Topic.empty();
      },
    );

    if (topic.name.isEmpty) {
      return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    }

    return topic.color;
  }

  Size getSizeConstraints(Size screenSize) {
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    if (screenWidth > 700.0) {
      return Size(300.0, screenHeight);
    }

    return Size(screenWidth * 0.54, screenHeight);
  }
}
