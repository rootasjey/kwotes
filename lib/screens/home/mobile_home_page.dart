import "dart:math";

import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:infinite_carousel/infinite_carousel.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/icons/app_icon.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/home/home_page_footer.dart";
import "package:kwotes/screens/home/hero_quote.dart";
import "package:kwotes/screens/home/home_topics.dart";
import "package:kwotes/screens/home/latest_authors.dart";
import "package:kwotes/screens/home/random_quote_text.dart";
import "package:kwotes/screens/home/reference_posters.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/random_quote_document.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/topic.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart";
import "package:loggy/loggy.dart";
import "package:url_launcher/url_launcher.dart";

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({
    super.key,
    this.isMobileSize = true,
  });

  /// Adapt user interface to small screens.
  final bool isMobileSize;

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> with UiLoggy {
  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Quote amount to fetch.
  final int _maxQuoteCount = 5;

  /// Amount of authors to fetch.
  final int _maxAuthorCount = 3;

  /// Amount of references to fetch.
  final int _maxReferenceCount = 8;

  /// Scroll controller for caroussel.
  final InfiniteScrollController _carouselScrollController =
      InfiniteScrollController();

  @override
  void initState() {
    super.initState();
    fetchRandomQuotes();

    if (NavigationStateHelper.latestAddedReferences.isEmpty) {
      fetchLatestAddedReferences();
    }

    if (NavigationStateHelper.latestAddedAuthors.isEmpty) {
      fetchLatestAddedAuthors();
    }
  }

  @override
  void dispose() {
    _carouselScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "loading".tr(),
      );
    }

    if (NavigationStateHelper.randomQuotes.isEmpty) {
      return EmptyView.scaffold(
        context,
        description: "empty_quote.home".tr(),
      );
    }

    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6);

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color topBackgroundColor = isDark
        ? Colors.black.withAlpha(100)
        : Theme.of(context).scaffoldBackgroundColor;

    final Color backgroundColor =
        isDark ? Colors.black26 : Constants.colors.getRandomPastel();

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
                isBig: true,
                backgroundColor: topBackgroundColor,
                quote: NavigationStateHelper.randomQuotes.first,
                textColor: iconColor,
                onTapAuthor: onTapAuthor,
                onTapQuote: onTapQuote,
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
                    final int nextIndex = index + 1;
                    final Quote quote =
                        NavigationStateHelper.randomQuotes[nextIndex];

                    return RandomQuoteText(
                      quote: quote,
                      foregroundColor: iconColor,
                      onTapQuote: onTapQuote,
                      onTapAuthor: onTapAuthor,
                    );
                  },
                  itemCount: _maxQuoteCount - 1,
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
                scrollController: _carouselScrollController,
                onIndexChanged: (int index) => setState(() {}),
              ),
              LatestAuthors(
                authors: NavigationStateHelper.latestAddedAuthors,
                margin: const EdgeInsets.only(
                  top: 42.0,
                  left: 26.0,
                  right: 26.0,
                ),
                onTapAuthor: onTapAuthor,
              ),
              HomePageFooter(
                iconColor: iconColor,
                isMobileSize: widget.isMobileSize,
                margin: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 24.0,
                  bottom: 120.0,
                ),
                onAddQuote: onAddQuote,
                onFetchRandomQuotes: fetchRandomQuotes,
                onTapGitHub: onTapGitHub,
                onTapSettings: onTapSettings,
                onTapOpenRandomQuote: onTapOpenRandomQuote,
                userFirestoreSignal: userFirestoreSignal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Author?> fetchAuthor(String authorId) async {
    if (authorId.isEmpty) {
      return null;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("authors")
          .doc(authorId)
          .get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }

      data["id"] = snapshot.id;
      return Author.fromMap(data);
    } catch (error) {
      loggy.error(error);
      return null;
    }
  }

  /// Fetches latest added authors.
  void fetchLatestAddedAuthors() async {
    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("authors")
          .orderBy("created_at", descending: true)
          .limit(_maxAuthorCount)
          .get();

      if (snapshot.size == 0) {
        return;
      }

      for (final DocumentSnapshotMap doc in snapshot.docs) {
        final Json? data = doc.data();
        if (data == null) {
          continue;
        }

        data["id"] = doc.id;
        NavigationStateHelper.latestAddedAuthors.add(Author.fromMap(data));
      }

      setState(() {});
    } catch (error) {
      loggy.error(error);
    }
  }

  /// Fetches latest added references.
  void fetchLatestAddedReferences() async {
    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("references")
          .orderBy("created_at", descending: true)
          .limit(_maxReferenceCount)
          .get();

      if (snapshot.size == 0) {
        return;
      }

      for (final DocumentSnapshotMap doc in snapshot.docs) {
        final Json? data = doc.data();
        if (data == null) {
          continue;
        }

        data["id"] = doc.id;
        final Reference reference = Reference.fromMap(data);
        NavigationStateHelper.latestAddedReferences.add(reference);
      }

      setState(() {});
    } catch (error) {
      loggy.error(error);
    }
  }

  /// Refetches random quotes.
  Future<void> refetchRandomQuotes() {
    return fetchRandomQuotes(forceRefresh: true);
  }

  /// Fetches random quotes.
  Future<void> fetchRandomQuotes({bool forceRefresh = false}) async {
    final String currentLanguage = await Utils.linguistic.getLanguage();
    final bool hasLanguageChanged =
        NavigationStateHelper.lastRandomQuoteLanguage != currentLanguage;

    if (NavigationStateHelper.randomQuotes.isNotEmpty &&
        !hasLanguageChanged &&
        !forceRefresh) {
      return;
    }

    setState(() {
      _pageState = EnumPageState.loading;
      NavigationStateHelper.randomQuotes.clear();
      NavigationStateHelper.lastRandomQuoteLanguage = currentLanguage;
    });

    try {
      final String language = await Utils.linguistic.getLanguage();
      final QuerySnapMap randomSnapshot = await FirebaseFirestore.instance
          .collection("randoms")
          .where("language", isEqualTo: language)
          .limit(1)
          .get();

      if (randomSnapshot.size == 0) {
        setState(() {
          _pageState = EnumPageState.idle;
        });
        return;
      }

      final QueryDocSnapMap randomDocSnap = randomSnapshot.docs.first;
      final Json map = randomDocSnap.data();
      map["id"] = randomDocSnap.id;

      final RandomQuoteDocument randomQuoteDoc =
          RandomQuoteDocument.fromMap(map);
      randomQuoteDoc.items.shuffle();
      final List<String> items =
          randomQuoteDoc.items.take(_maxQuoteCount).toList();

      for (final String quoteId in items) {
        final DocumentSnapshotMap quoteDoc = await FirebaseFirestore.instance
            .collection("quotes")
            .doc(quoteId)
            .get();

        final Json? data = quoteDoc.data();
        if (data == null) {
          continue;
        }

        data["id"] = quoteDoc.id;
        final Quote quote = Quote.fromMap(data);
        // final Author? author = await fetchAuthor(quote.author.id);
        // final Reference? reference = await fetchReference(quote.reference.id);
        // quotes.add(quote.copyWith(author: author, reference: reference));
        NavigationStateHelper.randomQuotes.add(quote);
      }

      setState(() {
        _pageState = EnumPageState.idle;
      });
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      setState(() {
        _pageState = EnumPageState.idle;
      });
    }
  }

  Future<Reference?> fetchReference(String referenceId) async {
    if (referenceId.isEmpty) {
      return null;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("references")
          .doc(referenceId)
          .get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }

      data["id"] = snapshot.id;
      return Reference.fromMap(data);
    } catch (error) {
      loggy.error(error);
      return null;
    }
  }

  void onAddQuote() {
    NavigationStateHelper.quote = Quote.empty();
    Beamer.of(context).beamToNamed(
      "/dashboard/add-quote",
    );
  }

  void onCopyQuote(Quote quote) {
    QuoteActions.copyQuote(quote);
  }

  void onCopyQuoteUrl(Quote quote) {
    Clipboard.setData(ClipboardData(text: "${Constants.quoteUrl}/${quote.id}"));
  }

  void onTapQuote(Quote quote) {
    NavigationStateHelper.quote = quote;
    context.beamToNamed(
      HomeContentLocation.quoteRoute.replaceFirst(":quoteId", quote.id),
      data: {
        "quoteId": quote.id,
      },
      routeState: {
        "quoteId": quote.id,
      },
    );
  }

  void onTapOpenRandomQuote() {
    final List<Quote> quotes = NavigationStateHelper.randomQuotes;

    onTapQuote(
      quotes.elementAt(Random().nextInt(quotes.length)),
    );
  }

  void onTapSettings() {
    Beamer.of(context).beamToNamed("settings");
  }

  void onTapGitHub() {
    launchUrl(Uri.parse(Constants.githubUrl));
  }

  void onTapAuthor(Author author) {
    Beamer.of(context).beamToNamed(
      HomeContentLocation.authorRoute.replaceFirst(
        ":authorId",
        author.id,
      ),
    );
  }

  void onTapReference(Reference reference) {
    Beamer.of(context).beamToNamed(
      HomeContentLocation.referenceRoute.replaceFirst(
        ":referenceId",
        reference.id,
      ),
    );
  }

  void onTapTopic(Topic topic) {
    Beamer.of(context).beamToNamed(
      HomeContentLocation.topicRoute.replaceFirst(
        ":topicName",
        topic.name,
      ),
    );
  }
}
