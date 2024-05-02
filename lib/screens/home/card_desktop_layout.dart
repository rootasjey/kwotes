import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_card_swiper/flutter_card_swiper.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/components/dot_indicator.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/screens/home/authors_wrap.dart";
import "package:kwotes/screens/home/quotes_stack.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_home_category.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/topic.dart";

class CardDesktopLayout extends StatelessWidget {
  const CardDesktopLayout({
    super.key,
    this.isDark = false,
    this.isMobileSize = false,
    this.swiperController,
    this.pageState = EnumPageState.idle,
    this.refetchRandomQuotes,
    this.onTapAuthor,
    this.onDoubleTapAuthor,
    this.onTapQuote,
    this.onTapReference,
    this.onCopyQuote,
    this.onCopyQuoteUrl,
    this.onTapTopic,
    this.onChangeLanguage,
    this.onDoubleTapQuote,
    this.onFetchRandomQuotes,
    this.authors = const [],
    this.quotes = const [],
    this.subQuotes = const [],
    this.references = const [],
    this.topics = const [],
    this.selectedCategory = EnumHomeCategory.quotes,
    this.onCategoryChanged,
  });

  /// Whether to use dark theme.
  final bool isDark;

  /// Adapt UI to mobile size if true.
  final bool isMobileSize;

  /// Card swiper controller.
  final CardSwiperController? swiperController;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// Selected home category.
  final EnumHomeCategory selectedCategory;

  /// Callback to refetch new random quotes.
  final Future<void> Function()? refetchRandomQuotes;

  /// Callback fired when author is tapped.
  final void Function(Author author)? onTapAuthor;

  /// Callback fired when author is double tapped.
  final void Function(Author author)? onDoubleTapAuthor;

  /// Callback fired when quote is tapped.
  final void Function(Quote quote)? onTapQuote;

  /// Callback fired when reference is tapped.
  final void Function(Reference reference)? onTapReference;

  /// Callback to copy quote's name.
  final void Function(Quote quote)? onCopyQuote;

  /// Callback to copy quotes'url.
  final void Function(Quote quote)? onCopyQuoteUrl;

  /// Callback fired when topic is tapped.
  final void Function(Topic topic)? onTapTopic;

  /// Callback fired when language is changed.
  final void Function(EnumLanguageSelection)? onChangeLanguage;

  /// Callback fired when home category is changed.
  final void Function(EnumHomeCategory newCategory)? onCategoryChanged;

  /// Callback fired when a quote is double tapped.
  final void Function(Quote quote)? onDoubleTapQuote;

  /// Fetch new random quotes.
  final void Function()? onFetchRandomQuotes;

  /// Author list.
  final List<Author> authors;

  /// Quote list.
  final List<Quote> quotes;

  /// Subset of quote list.
  final List<Quote> subQuotes;

  /// Reference list.
  final List<Reference> references;

  /// Topic list.
  final List<Topic> topics;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "loading".tr(),
      );
    } else if (pageState == EnumPageState.idle && subQuotes.isEmpty) {
      return EmptyView.scaffold(context);
    }

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color? iconColor = foregroundColor?.withOpacity(0.8);

    const double iconSize = 18.0;
    const double iconRadius = 16.0;
    const double maxWidth = 800.0;
    const double maxHeight = 800.0;
    double widthFactor = 0.6;
    double heightFactor = 0.6;

    if (!isMobileSize) {
      widthFactor = 0.8;
    }

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getMainWidget(
                  foregroundColor: foregroundColor,
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                  widthFactor: widthFactor,
                  heightFactor: heightFactor,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: maxWidth * 0.85,
                    maxHeight: 50.0,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: widthFactor,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          spacing: 12.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            CircleButton(
                              onTap: () {
                                onCategoryChanged
                                    ?.call(EnumHomeCategory.quotes);
                              },
                              radius: iconRadius,
                              backgroundColor:
                                  selectedCategory == EnumHomeCategory.quotes
                                      ? Constants.colors.quotes
                                      : Colors.transparent,
                              icon: Icon(
                                TablerIcons.quote,
                                size: iconSize,
                                color:
                                    selectedCategory == EnumHomeCategory.quotes
                                        ? Colors.black
                                        : iconColor,
                              ),
                            ),
                            CircleButton(
                              onTap: () {
                                onCategoryChanged
                                    ?.call(EnumHomeCategory.authors);
                              },
                              radius: iconRadius,
                              backgroundColor:
                                  selectedCategory == EnumHomeCategory.authors
                                      ? Constants.colors.lists
                                      : Colors.transparent,
                              icon: Icon(
                                TablerIcons.users,
                                size: iconSize,
                                color: iconColor,
                              ),
                            ),
                            CircleButton(
                              onTap: () {
                                onCategoryChanged
                                    ?.call(EnumHomeCategory.references);
                              },
                              radius: iconRadius,
                              backgroundColor: selectedCategory ==
                                      EnumHomeCategory.references
                                  ? Constants.colors.references
                                  : Colors.transparent,
                              icon: Icon(
                                TablerIcons.books,
                                size: iconSize,
                                color: iconColor,
                              ),
                            ),
                            CircleButton(
                              onTap: () {
                                onCategoryChanged
                                    ?.call(EnumHomeCategory.topics);
                              },
                              radius: iconRadius,
                              backgroundColor:
                                  selectedCategory == EnumHomeCategory.topics
                                      ? Constants.colors.topicColor
                                      : Colors.transparent,
                              icon: Icon(
                                TablerIcons.category,
                                size: iconSize,
                                color: iconColor,
                              ),
                            ),
                            DotIndicator(color: Colors.pink.shade200),
                            CircleButton(
                              onTap: onFetchRandomQuotes,
                              radius: iconRadius,
                              backgroundColor: Colors.transparent,
                              icon: Icon(
                                TablerIcons.arrows_shuffle,
                                size: iconSize,
                                color: iconColor,
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            CircleButton(
                              onTap: () {
                                swiperController?.undo();
                              },
                              radius: iconRadius,
                              tooltip: "previous".tr(),
                              backgroundColor: Colors.transparent,
                              icon: Icon(
                                TablerIcons.arrow_left,
                                color: foregroundColor?.withOpacity(0.6),
                              ),
                            ),
                            DotIndicator(color: Colors.pink.shade200),
                            CircleButton(
                              onTap: () {
                                swiperController
                                    ?.swipe(CardSwiperDirection.left);
                              },
                              radius: iconRadius,
                              tooltip: "next".tr(),
                              backgroundColor: Colors.transparent,
                              icon: Icon(
                                TablerIcons.arrow_right,
                                color: foregroundColor?.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getMainWidget({
    Color? foregroundColor,
    double widthFactor = 1.0,
    double heightFactor = 1.0,
    double maxWidth = 800.0,
    double maxHeight = 800.0,
  }) {
    if (selectedCategory == EnumHomeCategory.quotes) {
      return QuotesStack(
        isDark: isDark,
        foregroundColor: foregroundColor,
        heightFactor: heightFactor,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        onCopyQuoteUrl: onCopyQuoteUrl,
        onDoubleTapQuote: onDoubleTapQuote,
        onDoubleTapAuthor: onDoubleTapAuthor,
        onTapAuthor: onTapAuthor,
        onTapQuote: onTapQuote,
        quotes: quotes,
        subQuotes: subQuotes,
        swiperController: swiperController,
        widthFactor: widthFactor,
      );
    }

    return AuthorsWrap(
      isDark: isDark,
      foregroundColor: foregroundColor,
      heightFactor: heightFactor,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      onTapAuthor: onTapAuthor,
      authors: authors,
      widthFactor: widthFactor,
    );
  }
}
