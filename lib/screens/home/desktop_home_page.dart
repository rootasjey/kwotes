import "dart:math";

import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:infinite_carousel/infinite_carousel.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/hero_quote.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/author_location.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/reference_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/home/authors_carousel.dart";
import "package:kwotes/screens/home/home_page_footer.dart";
import "package:kwotes/screens/home/quote_posters.dart";
import "package:kwotes/screens/home/reference_grid.dart";
import "package:kwotes/screens/home/topic_carousel.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/random_quote_document.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/topic.dart";
import "package:loggy/loggy.dart";
import "package:super_context_menu/super_context_menu.dart";
import "package:url_launcher/url_launcher.dart";

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({
    super.key,
  });

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> with UiLoggy {
  /// Show author left arrow if true.
  bool _enableAuthorLeftArrow = false;

  /// Show author right arrow if true.
  bool _enableAuthorRightArrow = true;

  /// Show quote left arrow if true.
  bool _enableQuoteLeftArrow = false;

  /// Show quote right arrow if true.
  bool _enableQuoteRightArrow = true;

  /// Show topic left arrow if true.
  bool _enableTopicLeftArrow = false;

  /// Show topic right arrow if true.
  bool _enableTopicRightArrow = true;

  Color? _posterBackgroundColor;

  /// Item size in the caroussel.
  /// Useful to jump between items.
  final double _authorCardExtent = 100.0;

  /// Item size in the caroussel.
  /// Useful to jump between items.
  final double _quoteCardExtent = 260.0;

  /// Item size in the caroussel.
  /// Useful to jump between items.
  final double _topicCardExtent = 100.0;

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Quote amount to fetch.
  final int _maxQuoteCount = 12;

  /// Amount of authors to fetch.
  final int _maxAuthorCount = 8;

  /// Amount of references to fetch.
  final int _maxReferenceCount = 8;

  /// Quote cards scroll controller.
  final InfiniteScrollController _authorScrollController =
      InfiniteScrollController();

  /// Quote cards scroll controller.
  final InfiniteScrollController _quoteScrollController =
      InfiniteScrollController();

  /// Topic scroll controller.
  final InfiniteScrollController _topicScrollController =
      InfiniteScrollController();

  /// Sub-list of random quotes.
  final List<Quote> _subRandomQuotes = [];

  /// Topic name hovered.
  String _hoveredTopicName = "";

  /// Author name hovered.
  String _hoveredAuthorName = "";

  /// Reference's id hovered.bui
  String _hoveredReferenceId = "";

  @override
  void initState() {
    super.initState();

    _posterBackgroundColor = Constants.colors.getRandomPastel();
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
    _authorScrollController.dispose();
    _quoteScrollController.dispose();
    _topicScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "loading".tr(),
      );
    }

    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6);

    // final Signal<UserFirestore> userFirestoreSignal =
    //     context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color topBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    final Quote firstQuote = NavigationStateHelper.randomQuotes.isNotEmpty
        ? NavigationStateHelper.randomQuotes.first
        : Quote.empty();

    return BasicShortcuts(
      child: Scaffold(
        backgroundColor: isDark ? Colors.black26 : Colors.white,
        body: CustomScrollView(
          slivers: [
            const ApplicationBar(
              pinned: false,
            ),
            HeroQuote.desktop(
              loading: _pageState == EnumPageState.loadingRandomQuotes ||
                  _pageState == EnumPageState.loading,
              backgroundColor: topBackgroundColor,
              foregroundColor: foregroundColor,
              quote: firstQuote,
              isDark: isDark,
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
                top: 32.0,
                left: 42.0,
                right: 42.0,
                bottom: 16.0,
              ),
            ),
            SliverToBoxAdapter(
              child: InkWell(
                onTap: fetchRandomQuotes,
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 16.0,
                    left: 48.0,
                    right: 26.0,
                    bottom: 12.0,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Welcome to kwotes. \nHere is a set of random quotes. "
                      "\nYou can fetch new quotes by clicking this text.",
                      style: Utils.calligraphy.body(
                        textStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            QuotePosters(
              isDark: isDark,
              itemExtent: _quoteCardExtent,
              enableLeftArrow: _enableQuoteLeftArrow,
              enableRightArrow: _enableQuoteRightArrow,
              foregroundColor: foregroundColor,
              margin: const EdgeInsets.only(
                top: 6.0,
                left: 36.0,
                bottom: 24.0,
              ),
              quotes: _subRandomQuotes,
              onIndexChanged: onQuoteIndexChanged,
              onTapArrowLeft: onTapQuoteLeftArrow,
              onTapArrowRight: onTapQuoteRightArrow,
              scrollController: _quoteScrollController,
              textColor: iconColor,
            ),
            TopicCarousel(
              enableLeftArrow: _enableTopicLeftArrow,
              enableRightArrow: _enableTopicRightArrow,
              foregroundColor: foregroundColor,
              isDark: isDark,
              itemExtent: _topicCardExtent,
              hoveredTopicName: _hoveredTopicName,
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
              scrollController: _topicScrollController,
              topics: Constants.colors.topics,
            ),
            AuthorCarousel(
              authors: NavigationStateHelper.latestAddedAuthors,
              isDark: isDark,
              foregroundColor: foregroundColor,
              hoveredAuthorName: _hoveredAuthorName,
              itemExtent: _authorCardExtent,
              enableLeftArrow: _enableAuthorLeftArrow,
              enableRightArrow: _enableAuthorRightArrow,
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
              scrollController: _authorScrollController,
            ),
            ReferenceGrid(
              backgroundColor: _posterBackgroundColor,
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
              referenceHoveredId: _hoveredReferenceId,
              references: NavigationStateHelper.latestAddedReferences,
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
      ),
    );
  }

  Future<String> getLanguage() async {
    final EnumLanguageSelection savedLanguage = await Utils.vault.getLanguage();
    if (Utils.linguistic.available().contains(savedLanguage)) {
      return savedLanguage.name;
    }

    return "en";
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
    setState(() => _pageState = EnumPageState.loading);

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

      setState(() => _pageState = EnumPageState.idle);
    } catch (error) {
      loggy.error(error);
    }
  }

  /// Fetches latest added references.
  void fetchLatestAddedReferences() async {
    setState(() => _pageState = EnumPageState.loading);

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

      // setState(() {});
      setState(() => _pageState = EnumPageState.idle);
    } catch (error) {
      loggy.error(error);
    }
  }

  void fetchRandomQuotes() async {
    final String currentLanguage = await getLanguage();
    final bool hasLanguageChanged =
        NavigationStateHelper.lastRandomQuoteLanguage != currentLanguage;

    if (NavigationStateHelper.randomQuotes.isNotEmpty && !hasLanguageChanged) {
      return;
    }

    setState(() {
      _pageState = _pageState != EnumPageState.loading
          ? EnumPageState.loadingRandomQuotes
          : EnumPageState.loading;
      _subRandomQuotes.clear();
      NavigationStateHelper.randomQuotes.clear();
      NavigationStateHelper.lastRandomQuoteLanguage = currentLanguage;
    });

    try {
      final String language = await getLanguage();
      final QuerySnapMap randomSnapshot = await FirebaseFirestore.instance
          .collection("randoms")
          .where("language", isEqualTo: language)
          .limit(1)
          .get();

      if (randomSnapshot.size == 0) {
        setState(() => _pageState = EnumPageState.idle);
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
        if (quote.author.id == Constants.skippingAuthor) {
          continue;
        }

        NavigationStateHelper.randomQuotes.add(quote);
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _subRandomQuotes.addAll(NavigationStateHelper.randomQuotes.sublist(1));
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
    Beamer.of(context).beamToNamed(DashboardContentLocation.addQuoteRoute);
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

  void onTapGitHub() {
    launchUrl(Uri.parse(Constants.githubUrl));
  }

  void onTapAuthor(Author author) {
    Beamer.of(context).beamToNamed(
      AuthorLocation.route.replaceFirst(
        ":authorId",
        author.id,
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

  void onTapReference(Reference reference) {
    Beamer.of(context).beamToNamed(
      ReferenceLocation.route.replaceFirst(
        ":referenceId",
        reference.id,
      ),
    );
  }

  void onHoverTopic(Topic topic, bool isHover) {
    setState(() {
      _hoveredTopicName = isHover ? topic.name : "";
    });
  }

  /// Callback fired when topic arrow right button is pressed.
  void onTapQuoteRightArrow() {
    final double newOffset = min(
      _quoteScrollController.offset + _quoteCardExtent,
      _quoteScrollController.position.maxScrollExtent,
    );

    _quoteScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
    );
  }

  /// Callback fired when quote arrow left button is pressed.
  void onTapQuoteLeftArrow() {
    final double newOffset = max(
      _quoteScrollController.offset - _quoteCardExtent,
      0.0,
    );

    _quoteScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
    );
  }

  /// Callback fired when topic arrow right button is pressed.
  void onTapTopicRightArrow() {
    final double newOffset = min(
      _topicScrollController.offset + _topicCardExtent,
      _topicScrollController.position.maxScrollExtent,
    );

    _topicScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
    );
  }

  /// Callback fired when topic arrow left button is pressed.
  void onTapTopicLeftArrow() {
    final double newOffset = max(
      _topicScrollController.offset - _topicCardExtent,
      0.0,
    );

    _topicScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
    );
  }

  void onTopicIndexChanged(int index) {
    if (index == 0 && _enableTopicLeftArrow) {
      setState(() => _enableTopicLeftArrow = false);
    } else if (index > 0 && !_enableTopicLeftArrow) {
      setState(() => _enableTopicLeftArrow = true);
    }

    final double newOffset = max(_topicScrollController.offset - 100.0, 0.0);
    final bool enableRightArrow =
        newOffset < _topicScrollController.position.viewportDimension;

    if (enableRightArrow != _enableTopicRightArrow) {
      setState(() => _enableTopicRightArrow = enableRightArrow);
    }
  }

  void onQuoteIndexChanged(int index) {
    if (index == 0 && _enableQuoteLeftArrow) {
      setState(() => _enableQuoteLeftArrow = false);
    } else if (index > 0 && !_enableQuoteLeftArrow) {
      setState(() => _enableQuoteLeftArrow = true);
    }

    if (index == _subRandomQuotes.length - 1 && _enableQuoteRightArrow) {
      setState(() => _enableQuoteRightArrow = false);
    } else if (index < _subRandomQuotes.length - 1 && !_enableQuoteRightArrow) {
      setState(() => _enableQuoteRightArrow = true);
    }
  }

  void onHoverAuthor(Author author, bool isHovered) {
    setState(() {
      _hoveredAuthorName = isHovered ? author.name : "";
    });
  }

  void onAuthorIndexChanged(int index) {
    if (index == 0 && _enableAuthorLeftArrow) {
      setState(() => _enableAuthorLeftArrow = false);
    } else if (index > 0 && !_enableAuthorLeftArrow) {
      setState(() => _enableAuthorLeftArrow = true);
    }

    if (index == NavigationStateHelper.latestAddedAuthors.length - 1 &&
        _enableAuthorRightArrow) {
      setState(() => _enableAuthorRightArrow = false);
    } else if (index < NavigationStateHelper.latestAddedAuthors.length - 1 &&
        !_enableAuthorRightArrow) {
      setState(() => _enableAuthorRightArrow = true);
    }
  }

  void onTapAuthorRightArrow() {
    final double newOffset = min(
      _authorScrollController.offset + _authorCardExtent,
      _authorScrollController.position.maxScrollExtent,
    );

    _authorScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
    );
  }

  void onTapAuthorLeftArrow() {
    final double newOffset = max(
      _authorScrollController.offset - _authorCardExtent,
      0.0,
    );

    _authorScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
    );
  }

  void onHoverReference(Reference reference, bool isHovered) {
    setState(() => _hoveredReferenceId = isHovered ? reference.id : "");
  }

  void onChangeLanguage(EnumLanguageSelection locale) {
    fetchRandomQuotes();
  }
}
