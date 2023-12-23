import "dart:async";

import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";

class QuotePoster extends StatefulWidget {
  const QuotePoster({
    super.key,
    required this.quote,
    required this.quoteMenuProvider,
    this.isDark = false,
    this.onTap,
    this.onTapAuthor,
    this.margin = EdgeInsets.zero,
    this.onDoubleTap,
    this.onDoubleTapAuthor,
  });

  /// Whether to use dark theme.
  final bool isDark;

  /// Quote card menu provider.
  final FutureOr<Menu?> Function(MenuRequest) quoteMenuProvider;

  /// Margin of the widget.
  final EdgeInsets margin;

  /// Callback fired when card is tapped.
  final void Function(Quote quote)? onTap;

  /// Callback fired when card is double tapped.
  final void Function(Quote quote)? onDoubleTap;

  /// Callback fired when author's name is tapped.
  final void Function(Author author)? onTapAuthor;

  /// Callback fired when author's name is double tapped.
  final void Function(Author author)? onDoubleTapAuthor;

  /// Quote to display.
  final Quote quote;

  @override
  State<QuotePoster> createState() => _QuotePosterState();
}

class _QuotePosterState extends State<QuotePoster> {
  /// Current elevation of the card.
  double _elevation = 4.0;

  /// Start elevation of the card (e.g. idle).
  final double _startElevation = 6.0;

  /// End elevation of the card (e.g. on hover or tapped down).
  final double _endElevation = 0.0;

  @override
  void initState() {
    super.initState();
    _elevation = _startElevation;
  }

  @override
  Widget build(BuildContext context) {
    final Quote quote = widget.quote;
    final Color cardColor = Constants.colors.getColorFromTopicName(
      context,
      topicName: quote.topics.first,
    );

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: widget.margin,
      child: ContextMenuWidget(
        menuProvider: widget.quoteMenuProvider,
        child: SizedBox(
          width: 200.0,
          height: 260.0,
          child: Card(
            color: cardColor.withOpacity(0.1),
            elevation: _elevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: cardColor,
                width: 6.0,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor:
                  widget.isDark ? cardColor.withOpacity(0.5) : cardColor,
              onDoubleTap: widget.onDoubleTap == null
                  ? null
                  : () => widget.onDoubleTap?.call(quote),
              onTap: () => widget.onTap?.call(quote),
              onTapDown: onTapDown,
              onTapUp: onTapUp,
              onHover: onHover,
              borderRadius: BorderRadius.circular(8.0),
              child: Stack(
                children: [
                  Container(
                    color: widget.isDark
                        ? Colors.black.withOpacity(0.1)
                        : Colors.white.withOpacity(0.8),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      quote.name,
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                      style: Utils.calligraphy.body(
                        textStyle: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12.0,
                    bottom: 16.0,
                    child: InkWell(
                      onDoubleTap: widget.onDoubleTapAuthor == null
                          ? null
                          : () => widget.onDoubleTapAuthor?.call(quote.author),
                      onTap: () => widget.onTapAuthor?.call(quote.author),
                      borderRadius: BorderRadius.circular(2.0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                        child: Text(
                          "— ${quote.author.name}",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              color: foregroundColor?.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onHover(bool value) {
    setState(() {
      _elevation = value ? _startElevation / 2 : _startElevation;
    });
  }

  void onTapDown(TapDownDetails details) {
    setState(() {
      _elevation = _endElevation;
    });
  }

  void onTapUp(TapUpDetails details) {
    setState(() {
      _elevation = _startElevation;
    });
  }
}
