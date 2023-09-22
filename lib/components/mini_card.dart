import "dart:math";

import "package:flutter/material.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";
import "package:random_text_reveal/random_text_reveal.dart";

/// A tiny card showing the first letter of a quote
/// (displayed on home page).
class TinyCard extends StatefulWidget {
  const TinyCard({
    super.key,
    required this.quote,
    this.onTap,
  });

  /// Quote to display.
  final Quote quote;

  /// Callback fired when card is tapped.
  final void Function(Quote quote)? onTap;

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

  ///  If true, explicitly cancel letter animation.
  bool _animationFinished = false;

  @override
  Widget build(BuildContext context) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(4.0));
    final Color textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    final quoteName = widget.quote.name;
    final String firstChar = quoteName.characters.first;

    return JustTheTooltip(
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(
            Size(screenWidth * 0.75, screenHeight),
          ),
          child: Text(
            quoteName,
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
      child: Hero(
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
                child: RandomTextReveal(
                  shouldPlayOnStart: _animationFinished ? false : true,
                  initialText: _animationFinished ? firstChar : null,
                  text: firstChar,
                  duration: Duration(milliseconds: Random().nextInt(900) + 100),
                  // duration: const Duration(milliseconds: 500),
                  onFinished: () {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      setState(() {
                        _animationFinished = true;
                      });
                    });
                  },
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
      ),
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
}
