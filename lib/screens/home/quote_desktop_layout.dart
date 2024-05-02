import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_card_swiper/flutter_card_swiper.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/home/quotes_stack.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_home_category.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/topic.dart";

class QuoteDesktopLayout extends StatelessWidget {
  const QuoteDesktopLayout({
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
    } else if (pageState == EnumPageState.idle && quotes.isEmpty) {
      return EmptyView.scaffold(context);
    }
    final Size windowSize = MediaQuery.of(context).size;
    final Size quoteContainerSize = windowSize;
    // final Size quoteContainerSize = computeWindowSize(windowSize);

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    // final Signal<UserFirestore> signalUserFirestore =
    //     context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: quotes.length,
        itemBuilder: (BuildContext context, int index) {
          final Quote quote = quotes.elementAt(index);
          final textWrapSolution = Utils.graphic.getTextSolution(
            quote: quote,
            windowSize: quoteContainerSize,
            style: Utils.calligraphy.title(),
            maxFontSize: windowSize.width < 300 ? 18.0 : null,
          );

          return Padding(
            padding: const EdgeInsets.all(42.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => onTapQuote?.call(quote),
                  child: Text(
                    quote.name,
                    style: textWrapSolution.style,
                  ),
                ),
                if (quote.author.name.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6.0),
                      onTap: () => onTapAuthor?.call(quote.author),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          quote.author.name,
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              color: foregroundColor?.withOpacity(0.6),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (quote.reference.name.isNotEmpty)
                  InkWell(
                    onTap: () => onTapReference?.call(quote.reference),
                    borderRadius: BorderRadius.circular(6.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        quote.reference.name,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            color: foregroundColor?.withOpacity(0.4),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
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
  }

  /// Calculate actual quote container size based on screen size.
  Size computeWindowSize(Size size) {
    const double paddingValue = 54.0;

    if (NavigationStateHelper.isIpad) {
      return Size(
        (size.width * 0.7) - paddingValue,
        (size.height * 0.5) - paddingValue,
      );
    }

    if (size.width < 500 && size.height > 500) {
      return Size(
        (size.width * 0.8) - paddingValue,
        (size.height * 0.8) - paddingValue,
      );
    }

    return Size(
      (size.width * 0.7) - paddingValue,
      (size.height * 0.6) - paddingValue,
    );
  }
}
