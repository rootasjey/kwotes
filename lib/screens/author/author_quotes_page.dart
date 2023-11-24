import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_image_viewer/easy_image_viewer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/loading_view.dart";
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
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:loggy/loggy.dart";

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

  @override
  void initState() {
    super.initState();
    initProps();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (_pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "${"loading".tr()}...",
      );
    }

    final bool isMobileSize = Utils.measurements.isMobileSize(context);

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
                onTapName: onTapAuthorName,
                onTapAvatar: onTapAuthorAvatar,
              ),
              HeaderFilterListView(
                margin: const EdgeInsets.only(
                  left: 24.0,
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
                isMobileSize: isMobileSize,
                pageState: _pageState,
                quotes: _quotes,
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

  /// Initialize props.
  void initProps() {
    _selectedLanguage = Utils.linguistic.getLanguageSelection();
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

    showImageViewer(
      context,
      doubleTapZoomable: true,
      imageProvider,
      immersive: false,
      swipeDismissible: true,
      useSafeArea: false,
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
