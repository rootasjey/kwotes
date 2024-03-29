import "dart:math";

import "package:flutter/material.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";

class RandomHeroQuote extends StatelessWidget {
  /// Pick a random quote in the list to display as a big quote.
  const RandomHeroQuote({
    super.key,
    this.isDark = false,
    this.isBig = false,
    this.randomQuotes = const [],
    this.textColor,
    this.onTapAuthor,
    this.onTapQuote,
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
  });

  /// Whether to use dark theme.
  final bool isDark;

  /// Whether to display a big quote.
  final bool isBig;

  /// Widget background color.
  final Color? backgroundColor;

  /// Foreground text color.
  final Color? textColor;

  /// Margin of the widget.
  final EdgeInsets margin;

  /// Callback fired when author's name is tapped.
  final void Function(Author author)? onTapAuthor;

  /// Callback fired when author's avatar is tapped.
  final void Function(Quote quote)? onTapQuote;

  /// Random quotes list.
  final List<Quote> randomQuotes;

  @override
  Widget build(BuildContext context) {
    if (randomQuotes.isEmpty) {
      return const SliverToBoxAdapter();
    }

    final Quote quote = randomQuotes.elementAt(
      Random().nextInt(randomQuotes.length),
    );

    final Author author = quote.author;
    final Topic topic = Constants.colors.topics.firstWhere(
      (Topic x) => x.name == quote.topics.first,
      orElse: () => Topic.empty(),
    );

    final Color accentColor = Constants.colors.getRandomFromPalette(
      onlyDarkerColors: !isDark,
    );

    return SliverToBoxAdapter(
      child: Container(
        color: backgroundColor,
        padding: margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (author.urls.image.isNotEmpty)
                  BetterAvatar(
                    onTap: () => onTapAuthor?.call(author),
                    imageProvider: NetworkImage(author.urls.image),
                    radius: 24.0,
                  ),
                InkWell(
                  onTap: () => onTapAuthor?.call(author),
                  splashColor: accentColor,
                  hoverColor: accentColor,
                  highlightColor: accentColor,
                  child: Text(
                    "— ${quote.author.name}",
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => onTapQuote?.call(quote),
              style: TextButton.styleFrom(
                foregroundColor: topic.color,
                surfaceTintColor: topic.color,
              ),
              child: Text(
                quote.name,
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: isBig ? 28.0 : 18.0,
                    fontWeight: isBig ? FontWeight.w200 : FontWeight.w400,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
