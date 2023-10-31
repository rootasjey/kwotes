import "dart:math";

import "package:flutter/material.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";

class HomePageHeroQuote extends StatelessWidget {
  const HomePageHeroQuote({
    super.key,
    this.randomQuotes = const [],
    this.textColor,
    this.onTapAuthor,
    this.onTapQuote,
  });

  /// Foreground text color.
  final Color? textColor;

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

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 54.0,
        right: 54.0,
      ),
      sliver: SliverToBoxAdapter(
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
                TextButton(
                  onPressed: () => onTapAuthor?.call(author),
                  child: Text("— ${quote.author.name}"),
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
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
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
