import "dart:math";

import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:infinite_carousel/infinite_carousel.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/home/desktop_layout.dart";
import "package:kwotes/screens/home/mobile_layout.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_frame_border_style.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/random_quote_document.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/topic.dart";
import "package:loggy/loggy.dart";
import "package:url_launcher/url_launcher.dart";

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with UiLoggy {
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

  /// Background color of the reference posters section.
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

  /// Reference scroll controller.
  final InfiniteScrollController _referenceScrollController =
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
    _referenceScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final List<Quote> quotes = NavigationStateHelper.randomQuotes;

    if (isMobileSize) {
      return MobileLayout(
        authors: NavigationStateHelper.latestAddedAuthors.isEmpty
            ? []
            : NavigationStateHelper.latestAddedAuthors.sublist(0, 3),
        carouselScrollController: _referenceScrollController,
        onCopyQuote: onCopyQuote,
        onCopyQuoteUrl: onCopyQuoteUrl,
        onReferenceIndexChanged: onReferenceIndexChanged,
        onTapAuthor: onTapAuthor,
        onTapQuote: onTapQuote,
        onTapReference: onTapReference,
        onTapTopic: onTapTopic,
        pageState: _pageState,
        quotes: quotes,
        refetchRandomQuotes: refetchRandomQuotes,
        references: NavigationStateHelper.latestAddedReferences,
      );
    }

    return DesktopLayout(
      authors: NavigationStateHelper.latestAddedAuthors,
      authorCardExtent: _authorCardExtent,
      authorScrollController: _authorScrollController,
      enableAuthorLeftArrow: _enableAuthorLeftArrow,
      enableAuthorRightArrow: _enableAuthorRightArrow,
      enableQuoteLeftArrow: _enableQuoteLeftArrow,
      enableQuoteRightArrow: _enableQuoteRightArrow,
      enableTopicLeftArrow: _enableTopicLeftArrow,
      enableTopicRightArrow: _enableTopicRightArrow,
      hoveredAuthorName: _hoveredAuthorName,
      hoveredReferenceId: _hoveredReferenceId,
      hoveredTopicName: _hoveredTopicName,
      onAuthorIndexChanged: onAuthorIndexChanged,
      onChangeLanguage: onChangeLanguage,
      onCopyQuote: onCopyQuote,
      onCopyQuoteUrl: onCopyQuoteUrl,
      onDoubleTapAuthor: onCopyAuthorName,
      onHoverAuthor: onHoverAuthor,
      onHoverReference: onHoverReference,
      onHoverTopic: onHoverTopic,
      onQuoteIndexChanged: onQuoteIndexChanged,
      onTapAuthor: onTapAuthor,
      onTapAuthorLeftArrow: onTapAuthorLeftArrow,
      onTapAuthorRightArrow: onTapAuthorRightArrow,
      onTapGitHub: onTapGitHub,
      onTapQuote: onTapQuote,
      onTapQuoteLeftArrow: onTapQuoteLeftArrow,
      onTapQuoteRightArrow: onTapQuoteRightArrow,
      onTapTopicLeftArrow: onTapTopicLeftArrow,
      onTapTopicRightArrow: onTapTopicRightArrow,
      onTapReference: onTapReference,
      onTapTopic: onTapTopic,
      onTopicIndexChanged: onTopicIndexChanged,
      pageState: _pageState,
      quoteScrollController: _quoteScrollController,
      posterBackgroundColor: _posterBackgroundColor,
      quotes: quotes,
      quoteCardExtent: _quoteCardExtent,
      references: NavigationStateHelper.latestAddedReferences,
      topicCardExtent: _topicCardExtent,
      refetchRandomQuotes: refetchRandomQuotes,
      subQuotes: _subRandomQuotes,
      topics: Constants.colors.topics,
      topicScrollController: _topicScrollController,
    );
  }

  /// Gets current language.
  Future<String> getLanguage() async {
    final EnumLanguageSelection savedLanguage = await Utils.vault.getLanguage();
    if (Utils.linguistic.available().contains(savedLanguage)) {
      return savedLanguage.name;
    }

    return "en";
  }

  /// Fetches a specific author from their id.
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

  /// Refetches random quotes.
  Future<void> refetchRandomQuotes() {
    return fetchRandomQuotes(forceRefresh: true);
  }

  /// Fetches random quotes.
  Future<void> fetchRandomQuotes({bool forceRefresh = false}) async {
    if (await shouldSkipFetch(forceRefresh: forceRefresh)) {
      _subRandomQuotes.isEmpty
          ? setState(
              () => _subRandomQuotes.addAll(
                NavigationStateHelper.randomQuotes.sublist(1),
              ),
            )
          : null;
      updateAppFrameColor(NavigationStateHelper.randomQuotes.first);
      return;
    }

    final String currentLanguage = await getLanguage();

    setState(() {
      _pageState = _pageState != EnumPageState.loading
          ? EnumPageState.loadingRandomQuotes
          : EnumPageState.loading;

      _subRandomQuotes.clear();
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

      _subRandomQuotes.addAll(NavigationStateHelper.randomQuotes.sublist(1));
      updateAppFrameColor(NavigationStateHelper.randomQuotes.first);

      if (!mounted) return;
      setState(() => _pageState = EnumPageState.idle);
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  /// Fetches a specific reference from its id.
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

  void onCopyAuthorName(Author author) {
    Clipboard.setData(ClipboardData(text: author.name));
    Utils.graphic.showSnackbar(
      context,
      message: "author.copy.success.name".tr(),
    );
  }

  /// Copy a specific quote's name to the clipboard.
  void onCopyQuote(Quote quote) {
    QuoteActions.copyQuote(quote);
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyQuoteSnackbar(context, isMobileSize: isMobileSize);
  }

  /// Copy a specific quote's url to the clipboard.
  void onCopyQuoteUrl(Quote quote) {
    QuoteActions.copyQuoteUrl(quote);
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyQuoteLinkSnackbar(
      context,
      isMobileSize: isMobileSize,
    );
  }

  /// Navigate to the quote page.
  void onTapQuote(Quote quote) {
    NavigationStateHelper.quote = quote;
    Beamer.of(context).beamToNamed(
      HomeContentLocation.quoteRoute.replaceFirst(":quoteId", quote.id),
      routeState: {
        "quoteName": quote.name,
      },
    );
  }

  /// Open projcet's GitHub page.
  void onTapGitHub() {
    launchUrl(Uri.parse(Constants.githubUrl));
  }

  /// Navigate to the author page.
  void onTapAuthor(Author author) {
    Beamer.of(context).beamToNamed(
      HomeContentLocation.authorRoute.replaceFirst(
        ":authorId",
        author.id,
      ),
      routeState: {
        "authorName": author.name,
      },
    );
  }

  /// Navigate to the reference page.
  void onTapReference(Reference reference) {
    Beamer.of(context).beamToNamed(
      HomeContentLocation.referenceRoute.replaceFirst(
        ":referenceId",
        reference.id,
      ),
      routeState: {
        "referenceName": reference.name,
      },
    );
  }

  /// Navigate to the topic page.
  void onTapTopic(Topic topic) {
    Beamer.of(context).beamToNamed(
      HomeContentLocation.topicRoute.replaceFirst(
        ":topicName",
        topic.name,
      ),
      routeState: {
        "topicName": topic.name,
      },
    );
  }

  /// Display hovered topic name.
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

  /// Callback fired to show/hide topic arrow buttons.
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

  /// Callback fired to show/hide quote arrow buttons.
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

  /// Display hovered author name.
  void onHoverAuthor(Author author, bool isHovered) {
    setState(() {
      _hoveredAuthorName = isHovered ? author.name : "";
    });
  }

  /// Callback fired to show/hide author arrow buttons.
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

  /// Callback fired when author arrow right button is pressed.
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

  /// Callback fired when author arrow left button is pressed.
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

  /// Display hovered author name.
  void onHoverReference(Reference reference, bool isHovered) {
    setState(() => _hoveredReferenceId = isHovered ? reference.id : "");
  }

  /// Update application's language.
  void onChangeLanguage(EnumLanguageSelection locale) {
    fetchRandomQuotes();
  }

  /// Callback fired to show/hide reference arrow buttons.
  void onReferenceIndexChanged(int index) {
    setState(() {});
  }

  /// Checks if should skip fetching random quotes.
  Future<bool> shouldSkipFetch({bool forceRefresh = false}) async {
    final String currentLanguage = await getLanguage();
    final bool hasLanguageChanged =
        NavigationStateHelper.lastRandomQuoteLanguage != currentLanguage;

    return NavigationStateHelper.randomQuotes.isNotEmpty &&
        !hasLanguageChanged &&
        !forceRefresh;
  }

  /// Update application's frame color.
  void updateAppFrameColor(Quote quote) {
    if (NavigationStateHelper.frameBorderStyle !=
        EnumFrameBorderStyle.colored) {
      return;
    }

    if (quote.topics.isEmpty) {
      return;
    }

    final Topic topic = Constants.colors.topics.firstWhere(
      (Topic x) => x.name == quote.topics.first,
      orElse: () => Topic.empty(),
    );

    final Signal<Color> appColorFrameSignal = context.get<Signal<Color>>(
      EnumSignalId.frameBorderColor,
    );

    appColorFrameSignal.update((value) => topic.color);
    Constants.colors.lastBorderColor = topic.color;
  }
}
