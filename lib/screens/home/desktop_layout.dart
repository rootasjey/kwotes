import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:infinite_carousel/infinite_carousel.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/hero_quote.dart";
import "package:kwotes/components/icons/app_icon.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/home/authors_carousel.dart";
import "package:kwotes/screens/home/home_page_footer.dart";
import "package:kwotes/screens/home/home_welcome_greetings.dart";
import "package:kwotes/screens/home/quote_posters.dart";
import "package:kwotes/screens/home/reference_grid.dart";
import "package:kwotes/screens/home/topic_carousel.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/topic.dart";
import "package:super_context_menu/super_context_menu.dart";

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({
    super.key,
    required this.quoteScrollController,
    required this.authorScrollController,
    required this.topicScrollController,
    this.enableAuthorLeftArrow = false,
    this.enableAuthorRightArrow = true,
    this.enableQuoteLeftArrow = false,
    this.enableQuoteRightArrow = true,
    this.enableTopicLeftArrow = false,
    this.enableTopicRightArrow = true,
    this.authorCardExtent = 100.0,
    this.quoteCardExtent = 260.0,
    this.topicCardExtent = 100.0,
    this.pageState = EnumPageState.idle,
    this.posterBackgroundColor,
    this.onQuoteIndexChanged,
    this.onAuthorIndexChanged,
    this.onTopicIndexChanged,
    this.refetchRandomQuotes,
    this.onCopyQuote,
    this.onCopyQuoteUrl,
    this.onChangeLanguage,
    this.onDoubleTapAuthor,
    this.onHoverAuthor,
    this.onHoverReference,
    this.onHoverTopic,
    this.onTapAuthor,
    this.onTapAuthorLeftArrow,
    this.onTapAuthorRightArrow,
    this.onTapGitHub,
    this.onTapQuote,
    this.onTapQuoteLeftArrow,
    this.onTapQuoteRightArrow,
    this.onTapReference,
    this.onTapTopic,
    this.onTapTopicLeftArrow,
    this.onTapTopicRightArrow,
    this.authors = const [],
    this.quotes = const [],
    this.subQuotes = const [],
    this.references = const [],
    this.topics = const [],
    this.hoveredAuthorName = "",
    this.hoveredTopicName = "",
    this.hoveredReferenceId = "",
  });

  /// Show author left arrow if true.
  final bool enableAuthorLeftArrow;

  /// Show author right arrow if true.
  final bool enableAuthorRightArrow;

  /// Show quote left arrow if true.
  final bool enableQuoteLeftArrow;

  /// Show quote right arrow if true.
  final bool enableQuoteRightArrow;

  /// Show topic left arrow if true.
  final bool enableTopicLeftArrow;

  /// Show topic right arrow if true.
  final bool enableTopicRightArrow;

  /// Poster's background color.
  final Color? posterBackgroundColor;

  /// Author card's extent.
  final double authorCardExtent;

  /// Quote card's extent.
  final double quoteCardExtent;

  /// Topic card's extent.
  final double topicCardExtent;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// Callback when quote carousel index is changed.
  final void Function(int)? onQuoteIndexChanged;

  /// Callback when author carousel index is changed.
  final void Function(int)? onAuthorIndexChanged;

  /// Callback when topic carousel index is changed.
  final void Function(int)? onTopicIndexChanged;

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

  /// Callback fired to navigate to GitHub project (external link).
  final void Function()? onTapGitHub;

  /// Callback fired when author is hovered.
  final void Function(Author author, bool isHover)? onHoverAuthor;

  /// Callback fired when reference is hovered.
  final void Function(Reference reference, bool isHover)? onHoverReference;

  /// Callback fired when topic is hovered.
  final void Function(Topic topic, bool isHover)? onHoverTopic;

  /// Callback fired when language is changed.
  final void Function(EnumLanguageSelection)? onChangeLanguage;

  /// Callback fired when author arrow left button is pressed.
  final void Function()? onTapAuthorLeftArrow;

  /// Callback fired when author arrow right button is pressed.
  final void Function()? onTapAuthorRightArrow;

  /// Callback fired when quote arrow left button is pressed.
  final void Function()? onTapQuoteLeftArrow;

  /// Callback fired when quote arrow right button is pressed.
  final void Function()? onTapQuoteRightArrow;

  /// Callback fired when topic arrow left button is pressed.
  final void Function()? onTapTopicLeftArrow;

  /// Callback fired when topic arrow right button is pressed.
  final void Function()? onTapTopicRightArrow;

  /// Carousel scroll controller.
  final InfiniteScrollController quoteScrollController;

  /// Carousel scroll controller.
  final InfiniteScrollController authorScrollController;

  /// Carousel scroll controller.
  final InfiniteScrollController topicScrollController;

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

  /// Current hovered author name.
  final String hoveredAuthorName;

  /// Current hovered topic name.
  final String hoveredTopicName;

  /// Current hovered reference id.
  final String hoveredReferenceId;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "loading".tr(),
      );
    }

    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6);

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color topBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    final Quote firstQuote = quotes.isNotEmpty ? quotes.first : Quote.empty();

    return Scaffold(
      backgroundColor: isDark ? Colors.black26 : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 54.0,
                left: 42.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const AppIcon(
                    size: 20.0,
                    margin: EdgeInsets.only(right: 6.0),
                  ),
                  Text(
                    Constants.appName,
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        color: foregroundColor?.withOpacity(0.6),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          HeroQuote.desktop(
            loading: pageState == EnumPageState.loadingRandomQuotes ||
                pageState == EnumPageState.loading,
            backgroundColor: topBackgroundColor,
            foregroundColor: foregroundColor,
            quote: firstQuote,
            isDark: isDark,
            onTapAuthor: onTapAuthor,
            onDoubleTapQuote: onCopyQuote,
            onTapQuote: onTapQuote,
            authorMenuProvider: (MenuRequest menuRequest) =>
                ContextMenuComponents.authorMenuProvider(
              context,
              author: firstQuote.author,
            ),
            quoteMenuProvider: (MenuRequest menuRequest) =>
                ContextMenuComponents.quoteMenuProvider(
              context,
              quote: firstQuote,
              onCopyQuote: onCopyQuote,
              onCopyQuoteUrl: onCopyQuoteUrl,
            ),
            margin: const EdgeInsets.only(
              top: 32.0,
              left: 42.0,
              right: 42.0,
              bottom: 16.0,
            ),
          ),
          HomeWelcomeGreetings(
            foregroundColor: foregroundColor,
            refetchRandomQuotes: refetchRandomQuotes,
            padding: const EdgeInsets.only(
              top: 16.0,
              left: 48.0,
              right: 26.0,
              bottom: 12.0,
            ),
          ),
          QuotePosters(
            isDark: isDark,
            itemExtent: quoteCardExtent,
            enableLeftArrow: enableQuoteLeftArrow,
            enableRightArrow: enableQuoteRightArrow,
            foregroundColor: foregroundColor,
            margin: const EdgeInsets.only(
              top: 6.0,
              left: 36.0,
              bottom: 24.0,
            ),
            quotes: subQuotes,
            onTapAuthor: onTapAuthor,
            onDoubleTapAuthor: onDoubleTapAuthor,
            onCopyQuoteUrl: onCopyQuoteUrl,
            onDoubleTapQuote: onCopyQuote,
            onIndexChanged: onQuoteIndexChanged,
            onTapQuote: onTapQuote,
            onTapArrowLeft: onTapQuoteLeftArrow,
            onTapArrowRight: onTapQuoteRightArrow,
            scrollController: quoteScrollController,
            textColor: iconColor,
          ),
          TopicCarousel(
            enableLeftArrow: enableTopicLeftArrow,
            enableRightArrow: enableTopicRightArrow,
            foregroundColor: foregroundColor,
            isDark: isDark,
            itemExtent: topicCardExtent,
            hoveredTopicName: hoveredTopicName,
            onTapTopic: onTapTopic,
            onHoverTopic: onHoverTopic,
            margin: const EdgeInsets.only(
              left: 36.0,
              top: 24.0,
              bottom: 24.0,
            ),
            onIndexChanged: onTopicIndexChanged,
            onTapArrowRight: onTapTopicRightArrow,
            onTapArrowLeft: onTapTopicLeftArrow,
            scrollController: topicScrollController,
            topics: topics,
          ),
          AuthorCarousel(
            authors: authors,
            isDark: isDark,
            foregroundColor: foregroundColor,
            hoveredAuthorName: hoveredAuthorName,
            itemExtent: authorCardExtent,
            enableLeftArrow: enableAuthorLeftArrow,
            enableRightArrow: enableAuthorRightArrow,
            onTapAuthor: onTapAuthor,
            onHoverAuthor: onHoverAuthor,
            onIndexChanged: onAuthorIndexChanged,
            onTapArrowRight: onTapAuthorRightArrow,
            onTapArrowLeft: onTapAuthorLeftArrow,
            margin: const EdgeInsets.only(
              left: 42.0,
              top: 24.0,
              bottom: 24.0,
            ),
            scrollController: authorScrollController,
          ),
          ReferenceGrid(
            backgroundColor: posterBackgroundColor,
            foregroundColor: foregroundColor,
            isDark: isDark,
            margin: const EdgeInsets.only(
              top: 32.0,
              left: 42.0,
              right: 42.0,
              bottom: 120.0,
            ),
            onTapReference: onTapReference,
            onHoverReference: onHoverReference,
            referenceHoveredId: hoveredReferenceId,
            references: references,
          ),
          HomePageFooter(
            onTapGitHub: onTapGitHub,
            iconColor: iconColor,
            foregroundColor: foregroundColor,
            margin: const EdgeInsets.only(
              top: 32.0,
              left: 42.0,
              right: 42.0,
              bottom: 24.0,
            ),
            onChangeLanguage: onChangeLanguage,
          ),
        ],
      ),
    );
  }
}
