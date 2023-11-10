import "dart:async";

import "package:algolia/algolia.dart";
import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/search_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/search/search_category_selector.dart";
import "package:kwotes/screens/search/search_input.dart";
import "package:kwotes/screens/search/search_page_body.dart";
import "package:kwotes/screens/search/search_result_meta.dart";
import "package:kwotes/screens/search/showcase.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_app_bar_mode.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_search_category.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/topic.dart";
import "package:loggy/loggy.dart";

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.query = "",
    this.subjectName = "",
  });

  /// Search query.
  /// If this is filled, on initialization this widget will automatically
  /// try to search for data.
  final String query;

  /// Complete name of the subject.
  /// This is for convenience purpose.
  /// We won't use this for searching but we will fill the text field with it.
  /// (So we'll avoid showing some like this : "quotes:author:aBFROdeo0E").
  final String subjectName;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with UiLoggy {
  /// True if more results can be loaded.
  bool _hasMoreResults = true;

  /// [Mobile] Show entity selector if true.
  bool _showEntitySelector = true;

  /// [Mobile] Save previous offset on scroll to show/hide entity selector.
  double _prevOffset = 0.0;

  /// List of quotes results for a specific search (algolia).
  final List<Quote> _quoteResults = [];

  /// List of authors results for a specific search (algolia).
  final List<Author> _authorResults = [];

  /// List of authors in alphabetical order (from Firestore).
  final List<Author> _authorList = [];

  /// List of references results for a specific search (algolia).
  final List<Reference> _referenceResults = [];

  /// List of references in alphabetical order (from Firestore).
  final List<Reference> _referenceList = [];

  /// Search result count limit (algolia).
  final int _searchLimit = 20;

  /// Count limit for fetching authors in alphabetically order from firestore.
  final int _limitFetchAuthors = 60;

  /// Count limit for fetching references in alphabetically order from firestore.
  final int _limitFetchReferences = 60;

  /// Current search results page.
  int _searchPage = 0;

  /// Last author document for pagination.
  DocumentSnapshot? _lastAuthorDocument;
  // QueryDocSnapMap? _lastAuthorDocument;

  /// Last reference document for pagination.
  QueryDocSnapMap? _lastReferenceDocument;

  /// Result count for a specific search.
  int _resultCount = 0;

  /// Search focus node.
  final FocusNode _searchFocusNode = FocusNode();

  /// Page's state.
  EnumPageState _pageState = EnumPageState.idle;

  /// What type of category we are searching.
  EnumSearchCategory _searchCategory = EnumSearchCategory.quote;

  /// Scroll controller.
  final ScrollController _scrollController = ScrollController();

  /// Previous search text value.
  String _prevSearchTextValue = "";

  /// Search input controller.
  final TextEditingController _searchInputController = TextEditingController();

  /// Search timer to automatically fired search after a delay.
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    checkRouteParams();
  }

  @override
  void dispose() {
    _searchInputController.dispose();
    _searchTimer?.cancel();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final EdgeInsets padding = EdgeInsets.only(
      top: 0.0,
      left: isMobileSize ? 28.0 : 48.0,
      right: 24,
    );

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final bool showResultCount =
        removeSpecialKeywords(_searchInputController.text).isNotEmpty;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BasicShortcuts(
      autofocus: false,
      onCancel: context.beamBack,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              ImprovedScrolling(
                onScroll: onScroll,
                scrollController: _scrollController,
                child: ScrollConfiguration(
                  behavior: const CustomScrollBehavior(),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      if (!isMobileSize)
                        ApplicationBar(
                          elevation: 0.0,
                          isMobileSize: isMobileSize,
                          mode: EnumAppBarMode.search,
                          searchCategorySelected: _searchCategory,
                          onSelectSearchEntity: onSelectSearchEntity,
                          onTapTitle: onScrollToTop,
                          onTapIcon: onScrollToTop,
                          toolbarHeight: 42.0,
                          title: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (showResultCount) ...[
                                Text(
                                  "• ${"search.result_count".plural(_resultCount)} •",
                                  style: Utils.calligraphy.body(
                                    textStyle: TextStyle(
                                      color: foregroundColor?.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: onClearInput,
                                  tooltip: "search.clear".tr(),
                                  color: foregroundColor?.withOpacity(0.6),
                                  icon:
                                      const Icon(TablerIcons.square_rounded_x),
                                ),
                              ],
                            ],
                          ),
                        ),
                      SearchInput(
                        inputController: _searchInputController,
                        onChangedTextField: onSearchInputChanged,
                        focusNode: _searchFocusNode,
                        padding: padding,
                        searchCategory: _searchCategory,
                        isMobileSize: isMobileSize,
                        bottom: SearchResultMeta(
                          isMobileSize: isMobileSize,
                          foregroundColor: foregroundColor,
                          onClearInput: onClearInput,
                          padding: padding,
                          pageState: _pageState,
                          resultCount: _resultCount,
                          show: showResultCount,
                        ),
                      ),
                      SearchPageBody(
                        authorResults: _authorResults,
                        isMobileSize: isMobileSize,
                        isQueryEmpty: _searchInputController.text.isEmpty,
                        margin: padding,
                        onReinitSearch: onClearInput,
                        onTapQuote: onTapQuote,
                        onTapAuthor: onTapAuthor,
                        onTapReference: onTapReference,
                        pageState: _pageState,
                        quoteResults: _quoteResults,
                        referenceResults: _referenceResults,
                        searchCategory: _searchCategory,
                      ),
                      Showcase(
                        authors: _authorList,
                        isDark: isDark,
                        isMobileSize: isMobileSize,
                        margin: EdgeInsets.only(
                          top: isMobileSize ? 0.0 : 24.0,
                          bottom: 54.0,
                          left: isMobileSize ? 24.0 : 24.0,
                          right: isMobileSize ? 24.0 : 24.0,
                        ),
                        pageState: _pageState,
                        onTapTopicColor: onTapTopicColor,
                        onTapAuthor: onTapAuthor,
                        onTapReference: onTapReference,
                        references: _referenceList,
                        searchCategory: _searchCategory,
                        show: _searchInputController.text.isEmpty,
                        topicColors: Constants.colors.topics,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showEntitySelector)
                Positioned(
                  bottom: 12.0,
                  left: 0.0,
                  right: 0.0,
                  child: Center(
                    child: SearchCategorySelector(
                      categorySelected: _searchCategory,
                      isDark: isDark,
                      onSelectCategory: onSelectSearchEntity,
                    ),
                  )
                      .animate()
                      .slideY(
                        begin: 0.4,
                        end: 0.0,
                        duration: 150.ms,
                        curve: Curves.decelerate,
                      )
                      .fadeIn(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Selective search (according to entity category).
  void search() async {
    _prevSearchTextValue = _searchInputController.text;

    final String text = removeSpecialKeywords(_searchInputController.text);

    switch (_searchCategory) {
      case EnumSearchCategory.quote:
        preSearchQuotes(text);
        break;
      case EnumSearchCategory.author:
        preSearchAuthors(text);
        break;
      case EnumSearchCategory.reference:
        preSearchReferences(text);
        break;
      default:
    }
  }

  /// Selective search (according to entity category).
  void searchMore() async {
    _prevSearchTextValue = _searchInputController.text;

    final String text = removeSpecialKeywords(_searchInputController.text);

    switch (_searchCategory) {
      case EnumSearchCategory.quote:
        preSearchMoreQuotes(text);
        break;
      case EnumSearchCategory.author:
        preSearchMoreAuthors(text);
        break;
      case EnumSearchCategory.reference:
        preSearchMoreReferences(text);
        break;
      default:
    }
  }

  /// Build the query to search authors.
  Future<void> preSearchAuthors(String text) async {
    if (text.isEmpty) {
      setState(() {
        _searchPage = 0;
        _authorResults.clear();
      });
      return;
    }

    setState(() {
      _searchPage = 0;
      _pageState = EnumPageState.searching;
      _authorResults.clear();
    });

    trySearchAuthors(text);
  }

  /// Build the query to search more authors.
  Future<void> preSearchMoreAuthors(String text) async {
    if (text.isEmpty || !_hasMoreResults) {
      return;
    }

    _pageState = EnumPageState.searchingMore;
    trySearchAuthors(text);
  }

  /// Find authors according to the passed text.
  void trySearchAuthors(String text) async {
    try {
      final AlgoliaQuery query = Utils.search.algolia
          .index("authors")
          .query(text)
          .setHitsPerPage(_searchLimit)
          .setPage(_searchPage);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        setState(() {
          _hasMoreResults = false;
          _pageState = EnumPageState.idle;
        });
        return;
      }

      for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
        final Json data = hit.data;
        data["id"] = hit.objectID;

        final Author author = Author.fromMap(data);
        _authorResults.add(author);
      }

      setState(() {
        _searchPage = _searchPage + 1;
        _resultCount = snapshot.nbHits;
        _pageState = EnumPageState.idle;
        _hasMoreResults = snapshot.page < snapshot.nbPages - 1;
      });
    } catch (error) {
      loggy.error(error.toString());
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  /// Build the query to search quotes.
  Future<void> preSearchQuotes(String text) async {
    if (text.isEmpty) {
      setState(() {
        _searchPage = 0;
        _quoteResults.clear();
      });
      return;
    }

    setState(() {
      _searchPage = 0;
      _pageState = EnumPageState.searching;
      _quoteResults.clear();
    });

    trySearchQuotes(text);
  }

  /// Build the query to search more quotes.
  Future<void> preSearchMoreQuotes(String text) async {
    if (text.isEmpty || !_hasMoreResults) {
      return;
    }

    _pageState = EnumPageState.searchingMore;
    trySearchQuotes(text);
  }

  /// Find quotes according to the passed text.
  void trySearchQuotes(String text) async {
    try {
      final AlgoliaQuery query = Utils.search.algolia
          .index("quotes")
          .query(text)
          .setHitsPerPage(_searchLimit)
          .setPage(_searchPage);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        setState(() {
          _hasMoreResults = false;
          _pageState = EnumPageState.idle;
        });
        return;
      }

      for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
        final Json data = hit.data;
        data["id"] = hit.objectID;

        final Quote quote = Quote.fromMap(data);
        _quoteResults.add(quote);
      }

      setState(() {
        _searchPage = _searchPage + 1;
        _resultCount = snapshot.nbHits;
        _pageState = EnumPageState.idle;
        _hasMoreResults = snapshot.page < snapshot.nbPages - 1;
      });
    } catch (error) {
      loggy.error(error.toString());
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  /// Build the query to search references.
  Future<void> preSearchReferences(String text) async {
    if (text.isEmpty) {
      setState(() => _referenceResults.clear());
      return;
    }

    setState(() {
      _pageState = EnumPageState.searching;
      _referenceResults.clear();
    });

    trySearchReferences(text);
  }

  /// Build the query to search more references.
  Future<void> preSearchMoreReferences(String text) async {
    if (text.isEmpty || !_hasMoreResults) {
      return;
    }

    _pageState = EnumPageState.searchingMore;
    trySearchReferences(text);
  }

  /// Find references according to the passed text.
  void trySearchReferences(String text) async {
    try {
      final AlgoliaQuery query = Utils.search.algolia
          .index("references")
          .query(text)
          .setHitsPerPage(_searchLimit)
          .setPage(0);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        setState(() => _pageState = EnumPageState.idle);
        return;
      }

      for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
        final Json data = hit.data;
        data["id"] = hit.objectID;

        final Reference reference = Reference.fromMap(data);
        _referenceResults.add(reference);
      }

      setState(() {
        _searchPage++;
        _pageState = EnumPageState.idle;
        _resultCount = snapshot.nbHits;
        _hasMoreResults = snapshot.page < snapshot.nbPages - 1;
      });
    } catch (error) {
      loggy.error(error.toString());
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  void tryFetchShowcaseData({
    bool reinit = false,
    bool fetchMore = false,
  }) async {
    if (_searchCategory == EnumSearchCategory.author) {
      tryFetchAuthors(
        reinit: reinit,
        fetchMore: fetchMore,
      );
      return;
    }

    if (_searchCategory == EnumSearchCategory.reference) {
      tryFetchReferences(
        reinit: reinit,
        fetchMore: fetchMore,
      );
      return;
    }
  }

  /// Try to fetch authors alphabetically in Firestore.
  void tryFetchAuthors({
    bool reinit = false,
    bool fetchMore = false,
  }) async {
    if (!reinit && _authorList.isNotEmpty && !fetchMore) {
      return;
    }

    if (reinit) {
      _authorList.clear();
      _hasMoreResults = true;
      _pageState = EnumPageState.loading;
    }

    if (fetchMore) {
      _pageState = EnumPageState.loadingMore;
    }

    try {
      QueryMap query = FirebaseFirestore.instance
          .collection("authors")
          .orderBy("name")
          .limit(_limitFetchAuthors);

      final DocumentSnapshot? lastDocument = _lastAuthorDocument;
      if (!reinit && lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
        _pageState = EnumPageState.loadingMore;
      }

      final QuerySnapMap snapshot = await query.get();
      if (snapshot.size == 0) {
        _pageState = EnumPageState.idle;
        _hasMoreResults = false;
        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;
        _authorList.add(Author.fromMap(data));
      }

      setState(() {
        _lastAuthorDocument = snapshot.docs.last;
        _pageState = EnumPageState.idle;
        _hasMoreResults = snapshot.size == _limitFetchAuthors;
      });
    } catch (error) {
      loggy.error(error);
      setState(() {
        _pageState = EnumPageState.idle;
      });
    }
  }

  /// Try to fetch references alphabetically in Firestore.
  void tryFetchReferences({
    bool reinit = false,
    bool fetchMore = false,
  }) async {
    if (!reinit && _referenceList.isNotEmpty && !fetchMore) {
      return;
    }

    if (reinit) {
      _referenceList.clear();
      _hasMoreResults = true;
      _pageState = EnumPageState.loading;
    }

    if (fetchMore) {
      _pageState = EnumPageState.loadingMore;
    }

    try {
      QueryMap query = FirebaseFirestore.instance
          .collection("references")
          .orderBy("name")
          .limit(_limitFetchReferences);

      final DocumentSnapshot? lastDocument = _lastReferenceDocument;
      if (!reinit && lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
        _pageState = EnumPageState.loadingMore;
      }

      final QuerySnapMap snapshot = await query.get();
      if (snapshot.size == 0) {
        _hasMoreResults = false;
        _pageState = EnumPageState.idle;
        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;
        _referenceList.add(Reference.fromMap(data));
      }

      setState(() {
        _lastReferenceDocument = snapshot.docs.last;
        _pageState = EnumPageState.idle;
        _hasMoreResults = snapshot.size == _limitFetchReferences;
      });
    } catch (error) {
      loggy.error(error);
      setState(() {
        _pageState = EnumPageState.idle;
      });
    }
  }

  /// Callback fired when search input has changed.
  void onSearchInputChanged(
    String value, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    if (value.trim() == _prevSearchTextValue) {
      return;
    }

    NavigationStateHelper.searchValue = value;

    if (value.isEmpty) {
      setState(() {
        _quoteResults.clear();
        _authorResults.clear();
        _referenceResults.clear();
        _prevSearchTextValue = value;
      });

      tryFetchShowcaseData();
      return;
    }

    _searchTimer?.cancel();
    _searchTimer = Timer(
      delay,
      search,
    );
  }

  void onSelectSearchEntity(EnumSearchCategory searchEntity) {
    Utils.vault.saveLastSearchCategory(searchEntity);

    setState(() {
      _searchCategory = searchEntity;
      _resultCount = 0;
    });

    // _searchFocusNode.requestFocus();
    search();
    tryFetchShowcaseData(reinit: true);
  }

  /// Callback fired when quote is tapped.
  void onTapQuote(Quote quote) {
    NavigationStateHelper.quote = quote;

    final String route = SearchContentLocation.quoteRoute.replaceFirst(
      ":quoteId",
      quote.id,
    );

    Beamer.of(context).beamToNamed(route);
  }

  /// Callback fired when author is tapped.
  void onTapAuthor(Author author) {
    NavigationStateHelper.author = author;

    final String route = SearchContentLocation.authorRoute.replaceFirst(
      ":authorId",
      author.id,
    );

    Beamer.of(context).beamToNamed(route);
  }

  /// Callback fired when reference is tapped.
  void onTapReference(Reference reference) {
    NavigationStateHelper.reference = reference;

    final String route = SearchContentLocation.referenceRoute.replaceFirst(
      ":referenceId",
      reference.id,
    );

    Beamer.of(context).beamToNamed(route);
  }

  /// Check text input to automatically adjust search settings.
  void checkForKeywords() {
    final String text = _searchInputController.text;
    if (text.isEmpty) {
      return;
    }

    if (text.startsWith("quote:") || text.startsWith("q:")) {
      onSelectSearchEntity(EnumSearchCategory.quote);
    }
    if (text.startsWith("author:") || text.startsWith("a:")) {
      onSelectSearchEntity(EnumSearchCategory.author);
    }
    if (text.startsWith("reference:") || text.startsWith("r:")) {
      onSelectSearchEntity(EnumSearchCategory.reference);
    }
  }

  String removeSpecialKeywords(String initialText) {
    return initialText
        .replaceFirst("quote:", "")
        .replaceFirst("author:", "")
        .replaceFirst("reference:", "")
        .replaceFirst("q:", "")
        .replaceFirst("a:", "")
        .replaceFirst("r:", "")
        .trim();
  }

  Future<void> initializeData() async {
    _searchCategory = await Utils.vault.getLastSearchCategory();
    setState(() {});
  }

  /// Check route parameters to automatically search for data
  /// with the right settings.
  void checkRouteParams() async {
    final String query = widget.query;

    if (query.isNotEmpty) {
      _searchInputController.text = widget.subjectName;

      final String searchType = query.split(":").first;
      manualSelectSearchEntity(searchType);

      if (query.indexOf(":") != query.lastIndexOf(":")) {
        findDirectResults(query);
        return;
      }

      search();
    }

    if (NavigationStateHelper.searchValue.isNotEmpty) {
      _searchInputController.text = NavigationStateHelper.searchValue;
      await initializeData();
      search();
      return;
    }

    await initializeData();
    tryFetchShowcaseData(reinit: true);
  }

  void manualSelectSearchEntity(String value) {
    switch (value) {
      case "quote":
        onSelectSearchEntity(EnumSearchCategory.quote);
        break;
      case "author":
        onSelectSearchEntity(EnumSearchCategory.author);
        break;
      case "reference":
        onSelectSearchEntity(EnumSearchCategory.reference);
        break;
      default:
    }
  }

  /// Directly fetch data from Firestore.
  void findDirectResults(String query) async {
    final List<String> strings = query.split(":");
    final String collectionName = strings[0];
    final String subjectCategory = strings[1];
    final String id = strings[2];

    try {
      setState(() => _pageState = EnumPageState.searching);

      final QueryMap query = FirebaseFirestore.instance
          .collection(collectionName)
          .where("$subjectCategory.id", isEqualTo: id);

      final QuerySnapMap snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;
        _quoteResults.add(Quote.fromMap(data));
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _resultCount = _quoteResults.length;
      });
    } catch (error) {
      loggy.error(error);
    }
  }

  void autoHideEntitySelector(double offset) {
    if (_scrollController.position.atEdge && offset == 0.0) {
      _showEntitySelector ? null : setState(() => _showEntitySelector = true);
      return;
    }

    if (_scrollController.position.atEdge && offset > 0.0) {
      _showEntitySelector ? setState(() => _showEntitySelector = false) : null;
      return;
    }

    if (_prevOffset < offset) {
      _prevOffset = offset;
      _showEntitySelector ? setState(() => _showEntitySelector = false) : null;
      return;
    }

    _prevOffset = offset;
    _showEntitySelector ? null : setState(() => _showEntitySelector = true);
  }

  void onScroll(double offset) {
    autoHideEntitySelector(offset);

    if (!_hasMoreResults) {
      return;
    }

    if (_pageState == EnumPageState.searching ||
        _pageState == EnumPageState.searchingMore ||
        _pageState == EnumPageState.loading ||
        _pageState == EnumPageState.loadingMore) {
      return;
    }

    if (_scrollController.position.maxScrollExtent - offset > 200) {
      return;
    }

    if (_searchInputController.text.isEmpty) {
      tryFetchShowcaseData(
        fetchMore: true,
      );
      return;
    }

    if (_scrollController.position.maxScrollExtent - offset <= 200) {
      searchMore();
    }
  }

  void onScrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceInOut,
    );
    _searchFocusNode.requestFocus();
  }

  void onTapTopicColor(Topic topicColor) {
    _searchInputController.text = topicColor.name;

    onSearchInputChanged(
      topicColor.name,
      delay: const Duration(milliseconds: 0),
    );
  }

  void onClearInput() {
    _searchInputController.text = "";
    Beamer.of(context).updateRouteInformation(
      RouteInformation(uri: Uri(path: SearchLocation.route)),
    );

    setState(() {
      _resultCount = 0;
      _prevSearchTextValue = "";
      NavigationStateHelper.searchValue = "";
      _hasMoreResults = true;
      _pageState = EnumPageState.idle;
      _quoteResults.clear();
      _authorResults.clear();
      _referenceResults.clear();
      _searchFocusNode.requestFocus();
    });

    tryFetchShowcaseData();
  }
}
