import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/photo_view_route_wrapper.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/author/author_quotes_page_body.dart";
import "package:kwotes/screens/author/author_quotes_page_header.dart";
import "package:kwotes/screens/published/header_filter_listview.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/firestore/document_change_map.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/firestore/query_snapshot_stream_subscription.dart";
import "package:kwotes/types/quote.dart";
import "package:loggy/loggy.dart";
import "package:screenshot/screenshot.dart";
import "package:text_wrap_auto_size/solution.dart";
import "package:text_wrap_auto_size/text_wrap_auto_size.dart";

class AuthorQuotesPage extends StatefulWidget {
  const AuthorQuotesPage({
    super.key,
    required this.authorId,
  });

  final String authorId;

  @override
  State<AuthorQuotesPage> createState() => _AuthorQuotesPageState();
}

class _AuthorQuotesPageState extends State<AuthorQuotesPage> with UiLoggy {
  Author _author = Author.empty();

  /// Data list order.
  final bool _descending = true;

  /// True if more results can be loaded.
  /// This is true by default.
  bool _hasMoreResults = true;

  /// Page's state (e.g. idle, loading, ...).
  EnumPageState _pageState = EnumPageState.loading;

  /// Language selection.
  EnumLanguageSelection _selectedLanguage = EnumLanguageSelection.all;

  /// List of quotes associated with the author.
  final List<Quote> _quotes = [];

  /// Result count limit.
  final int _limit = 20;

  /// Last document.
  QueryDocSnapMap? _lastDocument;

  /// Page's scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  /// Stream subscription for published quotes.
  QuerySnapshotStreamSubscription? _quoteSub;

  @override
  void initState() {
    super.initState();
    initProps();
    fetch();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    _quoteSub?.cancel();
    _quoteSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "${"loading".tr()}...",
      );
    }

    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: ImprovedScrolling(
        onScroll: onScroll,
        scrollController: _pageScrollController,
        child: ScrollConfiguration(
          behavior: const CustomScrollBehavior(),
          child: CustomScrollView(
            controller: _pageScrollController,
            slivers: [
              AuthorQuotesPageHeader(
                author: _author,
                isMobileSize: isMobileSize,
                onDoubleTapName: onDoubleTapAuthorName,
                onTapName: onTapAuthorName,
                onTapAvatar: onTapAuthorAvatar,
              ),
              HeaderFilterListView(
                margin: EdgeInsets.only(
                  left: isMobileSize ? 24.0 : 48.0,
                  top: 12.0,
                  right: 12.0,
                ),
                showAllLanguage: false,
                showLanguageSelector: true,
                showOwnershipSelector: false,
                onSelectLanguage: onSelectQuoteLanguage,
                selectedLanguage: _selectedLanguage,
                useSliver: true,
              ),
              AuthorQuotesPageBody(
                accentColor: Constants.colors.getRandomFromPalette(
                  withGoodContrast: true,
                ),
                isDark: isDark,
                isMobileSize: isMobileSize,
                pageState: _pageState,
                quotes: _quotes,
                onCopyQuoteUrl: onCopyQuoteUrl,
                onDoubleTapQuote: onDoubleTapQuote,
                onShareImage: onShareImage,
                onShareLink: (Quote quote) => QuoteActions.shareQuoteLink(
                  context,
                  quote,
                ),
                onShareText: (Quote quote) => QuoteActions.shareQuoteText(
                  context,
                  quote,
                ),
                onTapQuote: onTapQuote,
                onTapBackButton: Beamer.of(context).beamBack,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fetch page's data.
  void fetch() async {
    if (widget.authorId == NavigationStateHelper.author.id) {
      _author = NavigationStateHelper.author;
      fetchQuotes();
      return;
    }

    await Future.any([
      fetchAuthor(),
      fetchQuotes(),
    ]);
  }

  /// Fetch author's data if not in cache.
  Future<void> fetchAuthor() async {
    if (widget.authorId.isEmpty) {
      return;
    }

    try {
      setState(() => _pageState = EnumPageState.loading);
      final DocumentSnapshotMap doc = await FirebaseFirestore.instance
          .collection("authors")
          .doc(widget.authorId)
          .get();

      if (!doc.exists) {
        return;
      }

      setState(() => _author = Author.fromMap(doc.data()));
    } catch (error) {
      loggy.error(error);
      // setState(() => _pageState = EnumPageState.idle);
    }
  }

  /// Fetch author's quotes.
  Future<void> fetchQuotes() async {
    if (widget.authorId.isEmpty) {
      return;
    }

    try {
      setState(() => _pageState = EnumPageState.loadingQuotes);

      final String language = _selectedLanguage.name;
      final QueryMap query = getQuotesQuery(language: language);
      final QuerySnapMap snapshot = await query.get();
      listenToQuoteChanges(query);

      if (snapshot.docs.isEmpty) {
        setState(() => _pageState = EnumPageState.idle);
        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;
        _quotes.add(Quote.fromMap(data));
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _lastDocument = snapshot.docs.last;
        _hasMoreResults = _limit == snapshot.docs.length;
      });
    } catch (error) {
      loggy.error(error);
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  /// Return quote's query (according the current language).
  QueryMap getQuotesQuery({String language = "en"}) {
    final QueryMap query = FirebaseFirestore.instance
        .collection("quotes")
        .where("author.id", isEqualTo: widget.authorId)
        .where("language", isEqualTo: language)
        .orderBy("created_at", descending: _descending)
        .limit(_limit);

    final QueryDocSnapMap? lastDocument = _lastDocument;
    if (lastDocument != null) {
      return query.startAfterDocument(lastDocument);
    }

    return query;
  }

  /// Callback fired when a quote is added to the Firestore collection.
  void handleAddedQuote(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) {
      return;
    }

    data["id"] = doc.id;
    final Quote draft = Quote.fromMap(data);
    setState(() => _quotes.add(draft));
  }

  /// Callback fired when a quote is modified to the Firestore collection.
  void handleModifiedQuote(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) {
      return;
    }

    final int index = _quotes.indexWhere(
      (Quote x) => x.id == doc.id,
    );

    if (index == -1) {
      return;
    }

    data["id"] = doc.id;
    final Quote draft = Quote.fromMap(data);
    setState(() => _quotes[index] = draft);
  }

  /// Callback fired when a quote is removed from the Firestore collection.
  void handleRemovedQuote(DocumentSnapshotMap doc) {
    final int index = _quotes.indexWhere((Quote x) => x.id == doc.id);
    if (index == -1) {
      return;
    }

    setState(() => _quotes.removeAt(index));
  }

  /// Initialize props.
  void initProps() {
    _selectedLanguage = Utils.linguistic.getLanguageSelection();
  }

  /// Listen to document changes.
  void listenToQuoteChanges(QueryMap query) {
    _quoteSub?.cancel();
    _quoteSub = query.snapshots().skip(1).listen((QuerySnapMap snapshot) {
      for (final DocumentChangeMap docChange in snapshot.docChanges) {
        switch (docChange.type) {
          case DocumentChangeType.added:
            handleAddedQuote(docChange.doc);
            break;
          case DocumentChangeType.modified:
            handleModifiedQuote(docChange.doc);
            break;
          case DocumentChangeType.removed:
            handleRemovedQuote(docChange.doc);
            break;
          default:
            break;
        }
      }
    }, onDone: () {
      _quoteSub?.cancel();
      _quoteSub = null;
    });
  }

  /// Callback to copy quote url.
  void onCopyQuoteUrl(Quote quote) {
    QuoteActions.copyQuoteUrl(quote);
    Utils.graphic.showSnackbar(
      context,
      message: "quote.copy.success.link".tr(),
    );
  }

  /// Callback fired when author name is double tapped.
  /// Copy name to clipboard.
  void onDoubleTapAuthorName() {
    Clipboard.setData(ClipboardData(text: _author.name));
    Utils.graphic.showSnackbar(
      context,
      message: "author.copy.success.name".tr(),
    );
  }

  /// Callback fired when a quote is double tapped.
  /// Copy quote to clipboard.
  void onDoubleTapQuote(Quote quote) {
    QuoteActions.copyQuote(quote);
    Utils.graphic.showSnackbar(
      context,
      message: "quote.copy.success.name".tr(),
    );
  }

  /// Callback fired when the user scrolls.
  void onScroll(double offset) {
    if (!_hasMoreResults) {
      return;
    }

    if (_pageState == EnumPageState.searching ||
        _pageState == EnumPageState.searchingMore ||
        _pageState == EnumPageState.loading ||
        _pageState == EnumPageState.loadingMore) {
      return;
    }

    if (_pageScrollController.position.maxScrollExtent - offset <= 200) {
      fetchQuotes();
    }
  }

  /// Callback fired when a new quote's language is selected.
  void onSelectQuoteLanguage(EnumLanguageSelection language) {
    setState(() {
      _lastDocument = null;
      _quotes.clear();
      _selectedLanguage = language;
    });

    fetchQuotes();
  }

  /// Callback to share quote image.
  void onShareImage(Quote quote) {
    /// Screenshot controller (to share quote image).
    final ScreenshotController screenshotController = ScreenshotController();

    final Size windowSize = MediaQuery.of(context).size;
    double widthPadding = 192.0;
    final double heightPadding = QuoteActions.getShareHeightPadding(quote);

    Solution textWrapSolution = TextWrapAutoSize.solution(
      Size(windowSize.width - widthPadding, windowSize.height - heightPadding),
      Text(quote.name, style: Utils.calligraphy.body()),
    );

    QuoteActions.shareQuoteImage(
      context,
      borderColor: Constants.colors.getColorFromTopicName(
        context,
        topicName: quote.topics.first,
      ),
      quote: quote,
      onCaptureImage: ({bool pop = false}) => QuoteActions.captureImage(
        context,
        screenshotController: screenshotController,
        filename: QuoteActions.generateFileName(quote),
        pop: pop,
        loggy: loggy,
      ),
      screenshotController: screenshotController,
      textWrapSolution: textWrapSolution,
    );
  }

  /// Callback fired when the author avatar is tapped.
  /// Open author's avatar in the image viewer.
  void onTapAuthorAvatar() {
    if (_author.urls.image.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "author.error.no_image".tr(),
      );
      return;
    }

    final ImageProvider imageProvider = Image.network(_author.urls.image).image;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => HeroPhotoViewRouteWrapper(
          imageProvider: imageProvider,
          heroTag: "${_author.id}-avatar",
        ),
      ),
    );
  }

  /// Callback fired when the author name is tapped.
  /// Scrolls to the top of the page.
  void onTapAuthorName() {
    _pageScrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  /// Callback fired when a quote is tapped.
  void onTapQuote(Quote quote) {
    Beamer.of(context).beamToNamed(
      HomeContentLocation.authorQuoteRoute.replaceFirst(
        ":quoteId",
        quote.id,
      ),
    );
  }
}
