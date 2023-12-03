import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:infinite_carousel/infinite_carousel.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/hero_quote.dart";
import "package:kwotes/components/icons/app_icon.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/texts/random_quote_text.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/home/home_topics.dart";
import "package:kwotes/screens/home/latest_added_authors.dart";
import "package:kwotes/screens/home/reference_posters.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/topic.dart";
import "package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart";
import "package:super_context_menu/super_context_menu.dart";

class MobileLayout extends StatelessWidget {
  /// Mobile layout for home page.
  const MobileLayout({
    super.key,
    required this.refetchRandomQuotes,
    required this.carouselScrollController,
    required this.quotes,
    this.pageState = EnumPageState.idle,
    this.onReferenceIndexChanged,
    this.onTapTopic,
    this.onTapAuthor,
    this.onTapQuote,
    this.onTapReference,
    this.onCopyQuote,
    this.onCopyQuoteUrl,
  });

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// Callback when reference carousel index is changed.
  final void Function(int index)? onReferenceIndexChanged;

  /// Callback to refetch new random quotes.
  final Future<void> Function() refetchRandomQuotes;

  /// Callback fired when author is tapped.
  final void Function(Author author)? onTapAuthor;

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

  /// Carousel scroll controller.
  final InfiniteScrollController carouselScrollController;

  /// Quote list.
  final List<Quote> quotes;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "loading".tr(),
      );
    }

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color topBackgroundColor = isDark
        ? Colors.black.withAlpha(100)
        : Theme.of(context).scaffoldBackgroundColor;

    final Color backgroundColor =
        isDark ? Colors.black26 : Constants.colors.pastelPalette.first;

    final List<Quote> subRandomQuotes =
        quotes.isNotEmpty ? quotes.sublist(1) : [];

    final Quote firstQuote = quotes.isNotEmpty ? quotes.first : Quote.empty();

    return BasicShortcuts(
      child: Scaffold(
        backgroundColor: isDark ? Colors.black26 : Colors.white,
        body: LiquidPullToRefresh(
          color: backgroundColor,
          showChildOpacityTransition: false,
          onRefresh: refetchRandomQuotes,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: topBackgroundColor,
                  child: const Align(
                    alignment: Alignment.topLeft,
                    child: AppIcon(
                      margin: EdgeInsets.only(top: 54.0, left: 32.0),
                    ),
                  ),
                ),
              ),
              HeroQuote(
                isMobileSize: true,
                loading: pageState == EnumPageState.loadingRandomQuotes ||
                    pageState == EnumPageState.loading,
                backgroundColor: topBackgroundColor,
                foregroundColor: foregroundColor,
                quote: firstQuote,
                onTapAuthor: onTapAuthor,
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
                  top: 16.0,
                  left: 26.0,
                  right: 26.0,
                  bottom: 16.0,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 26.0,
                  right: 26.0,
                ),
                sliver: SliverList.separated(
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final Quote quote = subRandomQuotes[index];

                    return RandomQuoteText(
                      quote: quote,
                      foregroundColor: foregroundColor,
                      onTapQuote: onTapQuote,
                      onTapAuthor: onTapAuthor,
                      authorMenuProvider: (MenuRequest menuRequest) =>
                          ContextMenuComponents.authorMenuProvider(
                        context,
                        author: quote.author,
                      ),
                      quoteMenuProvider: (MenuRequest menuRequest) =>
                          ContextMenuComponents.quoteMenuProvider(
                        context,
                        quote: quote,
                        onCopyQuote: onCopyQuote,
                        onCopyQuoteUrl: onCopyQuoteUrl,
                      ),
                    );
                  },
                  itemCount: subRandomQuotes.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Row(
                    children: [
                      const Expanded(child: Divider()),
                      IconButton(
                        tooltip: "quote.fetch.random".tr(),
                        onPressed: refetchRandomQuotes,
                        color: iconColor,
                        icon: const Icon(TablerIcons.arrows_shuffle),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                ),
              ),
              HomeTopics(
                isDark: isDark,
                topics: Constants.colors.topics,
                onTapTopic: onTapTopic,
                cardBackgroundColor: backgroundColor,
                margin: const EdgeInsets.only(
                  top: 24.0,
                  bottom: 42.0,
                ),
              ),
              ReferencePosters(
                backgroundColor: backgroundColor,
                isDark: isDark,
                margin: const EdgeInsets.only(
                  top: 42.0,
                  bottom: 24.0,
                ),
                onTapReference: onTapReference,
                references: NavigationStateHelper.latestAddedReferences,
                textColor: iconColor,
                scrollController: carouselScrollController,
                onIndexChanged: onReferenceIndexChanged,
              ),
              LatestAddedAuthors(
                authors: NavigationStateHelper.latestAddedAuthors,
                margin: const EdgeInsets.only(
                  top: 42.0,
                  left: 26.0,
                  right: 26.0,
                ),
                onTapAuthor: onTapAuthor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
