import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:infinite_carousel/infinite_carousel.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/home/quote_poster.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";
import "package:super_context_menu/super_context_menu.dart";

class QuotePosters extends StatelessWidget {
  const QuotePosters({
    super.key,
    required this.scrollController,
    this.enableLeftArrow = false,
    this.enableRightArrow = true,
    this.isDark = false,
    this.backgroundColor,
    this.foregroundColor,
    this.textColor,
    this.itemExtent = 260.0,
    this.margin = EdgeInsets.zero,
    this.onCopyQuoteUrl,
    this.onDoubleTapAuthor,
    this.onDoubleTapQuote,
    this.onIndexChanged,
    this.onTapArrowLeft,
    this.onTapArrowRight,
    this.onTapAuthor,
    this.onTapQuote,
    this.quotes = const [],
  });

  /// Display right arrow if true.
  final bool enableLeftArrow;

  /// Display right arrow if true.
  final bool enableRightArrow;

  /// Whether to use dark theme.
  final bool isDark;

  /// Foreground text color.
  final Color? foregroundColor;

  /// Background color.
  final Color? backgroundColor;

  /// Foreground text color.
  final Color? textColor;

  /// Item extent.
  final double itemExtent;

  /// Margin of the widget.
  final EdgeInsets margin;

  /// Callback fired when author is double tapped.
  final void Function(Author author)? onDoubleTapAuthor;

  /// Callback fired when author is tapped.
  final void Function(Author author)? onTapAuthor;

  /// Callback fired when quote is tapped.
  final void Function(Quote quote)? onTapQuote;

  /// Callback fired when quote is double tapped.
  final void Function(Quote quote)? onDoubleTapQuote;

  /// Callback fired when quote url is copied.
  final void Function(Quote quote)? onCopyQuoteUrl;

  /// Callback fired when index is changed.
  final void Function(int index)? onIndexChanged;

  /// Scroll controller.
  final InfiniteScrollController scrollController;

  /// Callback fired when left arrow is tapped.
  final void Function()? onTapArrowLeft;

  /// Callback fired when right arrow is tapped.
  final void Function()? onTapArrowRight;

  /// List of quotes (main data).
  final List<Quote> quotes;

  @override
  Widget build(BuildContext context) {
    if (quotes.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        padding: margin,
        color: backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 330.0,
              child: InfiniteCarousel.builder(
                center: false,
                loop: false,
                itemCount: quotes.length,
                itemExtent: itemExtent,
                controller: scrollController,
                onIndexChanged: onIndexChanged,
                scrollBehavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.invertedStylus,
                  },
                ),
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  final Quote quote = quotes[index];
                  final Color selectedColor = Constants.colors.topics
                      .firstWhere((Topic x) => x.name == quote.topics.first)
                      .color;

                  return QuotePoster(
                    isDark: isDark,
                    quote: quote,
                    onTap: onTapQuote,
                    onDoubleTap: onDoubleTapQuote,
                    onDoubleTapAuthor: onDoubleTapAuthor,
                    onTapAuthor: onTapAuthor,
                    margin: const EdgeInsets.all(8.0),
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "quote.open_card".tr(),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: foregroundColor?.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  CircleButton(
                    backgroundColor: Colors.transparent,
                    onTap: enableLeftArrow ? onTapArrowLeft : null,
                    icon: Icon(
                      TablerIcons.arrow_left,
                      color: enableLeftArrow
                          ? foregroundColor?.withOpacity(0.8)
                          : foregroundColor?.withOpacity(0.2),
                    ),
                  ),
                  Container(
                    height: 6.0,
                    width: 6.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Constants.colors.primary,
                    ),
                  ),
                  CircleButton(
                    backgroundColor: Colors.transparent,
                    onTap: enableRightArrow ? onTapArrowRight : null,
                    icon: Icon(
                      TablerIcons.arrow_right,
                      color: enableRightArrow
                          ? foregroundColor?.withOpacity(0.8)
                          : foregroundColor?.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
