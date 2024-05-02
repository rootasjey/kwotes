import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_card_swiper/flutter_card_swiper.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/home/quote_poster.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";
import "package:super_context_menu/super_context_menu.dart";

class QuotesStack extends StatelessWidget {
  const QuotesStack({
    super.key,
    this.isDark = false,
    this.swiperController,
    this.maxHeight = 800.0,
    this.maxWidth = 800.0,
    this.widthFactor = 1.0,
    this.heightFactor = 1.0,
    this.foregroundColor,
    this.onTapQuote,
    this.onDoubleTapQuote,
    this.onDoubleTapAuthor,
    this.onTapAuthor,
    this.onCopyQuoteUrl,
    this.quotes = const [],
    this.subQuotes = const [],
  });

  /// Whether to use dark theme.
  final bool isDark;

  /// Card swiper controller.
  final CardSwiperController? swiperController;

  /// Text foreground color.
  final Color? foregroundColor;

  /// Width factor to limit this widget.
  final double widthFactor;

  /// Height factor to limit this widget.
  final double heightFactor;

  /// Max height for this widget.
  final double maxHeight;

  /// Max width for this widget.
  final double maxWidth;

  /// Callback fired when card is tapped.
  final void Function(Quote)? onTapQuote;

  /// Callback fired when card is double tapped.
  final void Function(Quote)? onDoubleTapQuote;

  /// Callback fired when author's name is double tapped.
  final void Function(Author author)? onDoubleTapAuthor;

  /// Callback fired when author's name is tapped.
  final void Function(Author author)? onTapAuthor;

  /// Callback fired to copy quote's url.
  final void Function(Quote quote)? onCopyQuoteUrl;

  /// List of quotes (may be unnecessary).
  final List<Quote> quotes;

  /// List of quotes inside the stack.
  final List<Quote> subQuotes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          heightFactor: heightFactor,
          child: CardSwiper(
            isLoop: false,
            controller: swiperController,
            numberOfCardsDisplayed: min(3, subQuotes.length),
            backCardOffset: const Offset(-38.0, 32.0),
            cardBuilder: (
              BuildContext context,
              int index,
              percenTresholdX,
              percenTresholdY,
            ) {
              final Quote quote = quotes[index];
              final Color selectedColor = Constants.colors.topics
                  .firstWhere((Topic x) => x.name == quote.topics.first)
                  .color;

              return QuotePoster(
                isDark: isDark,
                quote: quote,
                useAdaptiveTextStyle: true,
                onTap: onTapQuote,
                onDoubleTap: onDoubleTapQuote,
                onDoubleTapAuthor: onDoubleTapAuthor,
                onTapAuthor: onTapAuthor,
                padding: const EdgeInsets.all(32.0),
                textStyle: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: foregroundColor?.withOpacity(0.8),
                  ),
                ),
                quoteMenuProvider: (MenuRequest menuRequest) {
                  return ContextMenuComponents.quoteMenuProvider(
                    context,
                    quote: quote,
                    onCopyQuote: onDoubleTapQuote,
                    onCopyQuoteUrl: onCopyQuoteUrl,
                    selectedColor: selectedColor,
                  );
                },
              );
            },
            cardsCount: subQuotes.length,
          ),
        ),
      ),
    );
  }
}
