import "dart:async";

import "package:algolia/algolia.dart";
import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/globals/utils/linguistic.dart";
import "package:kwotes/router/locations/search_location.dart";
import "package:kwotes/router/locations/settings_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/search/chip_category_selector.dart";
import "package:kwotes/screens/search/search_input.dart";
import "package:kwotes/screens/search/search_page_body.dart";
import "package:kwotes/screens/search/search_result_meta.dart";
import "package:kwotes/screens/search/show_more_button.dart";
import "package:kwotes/screens/search/showcase.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_search_category.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/document_change_map.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/firestore/query_snapshot_stream_subscription.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/topic.dart";
import "package:kwotes/types/user/user_firestore.dart";
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
  /// True if we already handled the quick action
  /// (e.g. pull/push to trigger).
  bool _handleQuickAction = false;

  /// True if more results can be loaded.
  bool _hasMoreResults = true;

  /// Show more button if true.
  bool _showMoreButton = false;

  /// Last author document for pagination.
  DocumentSnapshot? _lastAuthorDocument;

  /// Trigger offset for pull to action.
  final double _pullTriggerOffset = -110.0;

  /// Page's state.
  EnumPageState _pageState = EnumPageState.idle;

  /// What type of category we are searching.
  EnumSearchCategory _searchCategory = EnumSearchCategory.quotes;

  /// Search focus node.
  final FocusNode _searchFocusNode = FocusNode();

  /// Count limit for fetching authors in alphabetically order from firestore.
  final int _limitFetchAuthors = 60;

  /// Count limit for fetching references in alphabetically order from firestore.
  final int _limitFetchReferences = 60;

  /// Result count for a specific search.
  int _resultCount = 0;

  /// Search result count limit (algolia).
  final int _searchLimit = 20;

  /// Current search results page.
  int _searchPage = 0;

  /// List of quotes results for a specific search (algolia).
  final List<Quote> _quoteResults = [];

  /// List of authors results for a specific search (algolia).
  final List<Author> _authorResults = [];

  /// List of authors in alphabetical order (for showcase).
  final List<Author> _authorList = [];

  /// List of references results for a specific search (algolia).
  final List<Reference> _referenceResults = [];

  /// List of references in alphabetical order (for showcase).
  final List<Reference> _referenceList = [];

  /// Last fetched quote document.
  QueryDocSnapMap? _lastQuoteDocument;

  /// Last reference document for pagination.
  QueryDocSnapMap? _lastReferenceDocument;

  /// Stream subscription for query snapshot.
  QuerySnapshotStreamSubscription? _streamSnapshot;

  /// Scroll controller.
  final ScrollController _scrollController = ScrollController();

  /// Previous search text value.
  String _prevSearchTextValue = "";

  /// Search input controller.
  final TextEditingController _searchInputController = TextEditingController();

  /// Page state timer to automatically fired page state after a delay.
  Timer? _pageSateTimer;

  /// Search timer to automatically fired search after a delay.
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    checkRouteParams();
    _searchFocusNode.addListener(onSearchFocusChanged);
    NavigationStateHelper.searchRouterDelegate.addListener(onRouteChanged);

    if (NavigationStateHelper.searchValue.isEmpty) {
      fetchShowcaseData();
    }
  }

  @override
  void dispose() {
    _searchInputController.dispose();
    _searchTimer?.cancel();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _streamSnapshot?.cancel();
    _streamSnapshot = null;
    _pageSateTimer?.cancel();
    _searchFocusNode.removeListener(onSearchFocusChanged);
    NavigationStateHelper.searchRouterDelegate.removeListener(onRouteChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final EdgeInsets padding = EdgeInsets.only(
      left: isMobileSize ? 28.0 : 48.0,
      right: 24,
    );

    final EdgeInsets marginBoddy = padding.copyWith(top: 24.0);

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final bool showResultCount =
        removeSpecialKeywords(_searchInputController.text).isNotEmpty &&
            _resultCount > 0;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    return SafeArea(
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
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SearchInput(
                      inputController: _searchInputController,
                      onChangedTextField: onSearchInputChanged,
                      focusNode: _searchFocusNode,
                      onTapCancelButton: onTapCancelButton,
                      onTapClearIconButton: onClearInput,
                      onTapUserAvatar: onTapUserAvatar,
                      searchCategory: _searchCategory,
                      isMobileSize: isMobileSize,
                      bottom: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ChipCategorySelector(
                            isDark: isDark,
                            categorySelected: _searchCategory,
                            onSelectCategory: onSelectSearchCategory,
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SearchResultMeta(
                        margin: const EdgeInsets.only(left: 24.0),
                        isMobileSize: isMobileSize,
                        foregroundColor: foregroundColor,
                        pageState: _pageState,
                        resultCount: _resultCount,
                        show: showResultCount,
                      ),
                    ),
                    SignalBuilder(
                      signal: signalUserFirestore,
                      builder: (
                        BuildContext context,
                        UserFirestore userFirestore,
                        Widget? child,
                      ) {
                        return SearchPageBody(
                          authorResults: _authorResults,
                          isDark: isDark,
                          isMobileSize: isMobileSize,
                          isQueryEmpty: _searchInputController.text.isEmpty,
                          margin: marginBoddy,
                          onOpenAddQuoteToList: onOpenAddQuoteToList,
                          onRefreshSearch: search,
                          onReinitializeSearch: onClearInput,
                          onTapQuote: onTapQuote,
                          onTapAuthor: onTapAuthor,
                          onTapReference: onTapReference,
                          onToggleLike: onToggleLike,
                          pageState: _pageState,
                          quoteResults: _quoteResults,
                          referenceResults: _referenceResults,
                          searchCategory: _searchCategory,
                          userId: userFirestore.id,
                        );
                      },
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
                      onTapTopicColor: onTapTopic,
                      onTapAuthor: onTapAuthor,
                      onTapReference: onTapReference,
                      references: _referenceList,
                      searchCategory: _searchCategory,
                      show: _searchInputController.text.isEmpty,
                      topicColors: Constants.colors.topics,
                    ),
                    ShowMoreButton(
                      searchCategory: _searchCategory,
                      show: _searchInputController.text.isEmpty &&
                          _searchCategory != EnumSearchCategory.quotes &&
                          _showMoreButton,
                      onPressed: () => fetchShowcaseData(fetchMore: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Set the target variable to the new value.
  /// Then set the value back to its original value after 1 second.
  void boomerangQuickActionValue(bool newValue) {
    _handleQuickAction = newValue;
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _handleQuickAction = !newValue,
    );
  }

  /// Check text input to automatically adjust search settings.
  void checkForKeywords() {
    final String text = _searchInputController.text;
    if (text.isEmpty) {
      return;
    }

    if (text.startsWith("quote:") || text.startsWith("q:")) {
      onSelectSearchCategory(EnumSearchCategory.quotes);
    }
    if (text.startsWith("author:") || text.startsWith("a:")) {
      onSelectSearchCategory(EnumSearchCategory.authors);
    }
    if (text.startsWith("reference:") || text.startsWith("r:")) {
      onSelectSearchCategory(EnumSearchCategory.references);
    }
  }

  /// Check route parameters to automatically search for data
  /// with the right settings.
  void checkRouteParams() async {
    final String query = extractQuery();

    if (query.isNotEmpty) {
      _searchInputController.text = extractSubjectName();

      final String searchType = query.split(":").first;
      manualSelectSearchCategory(searchType);

      if (query.indexOf(":") != query.lastIndexOf(":")) {
        // findDirectResults(query);
        return;
      }

      search();
    }

    if (NavigationStateHelper.searchValue.isNotEmpty) {
      _searchInputController.text = NavigationStateHelper.searchValue;
      await initProps();
      search();
      return;
    }

    if (handleSearchByTopic()) {
      return;
    }

    if (handleSearchQueryParam()) {
      search();
      return;
    }

    await initProps();
    fetchShowcaseData(reinit: true);
  }

  /// Set the new page state with a delay of 2 seconds.
  void deferPageState({
    EnumPageState newPageState = EnumPageState.idle,
    void Function()? fct,
  }) {
    _pageSateTimer?.cancel();
    _pageSateTimer = Timer(const Duration(seconds: 2), () {
      setState(() => _pageState = newPageState);
      fct?.call();
      _pageSateTimer = null;
    });
  }

  /// Extract search query from route state.
  String extractQuery() {
    final String query = widget.query;
    if (query.isNotEmpty) {
      return query;
    }

    final Object? routeState =
        NavigationStateHelper.searchRouterDelegate.configuration.state;
    if (routeState is Map) {
      return routeState["query"] ?? "";
    }

    return "";
  }

  /// Extract subject name (to search) from route state.
  String extractSubjectName() {
    if (widget.subjectName.isNotEmpty) {
      return widget.subjectName;
    }

    final Object? routeState = Beamer.of(context).configuration.state;
    if (routeState is Map) {
      return routeState["subjectName"] ?? "";
    }

    return "";
  }

  /// Try to fetch authors alphabetically in Firestore.
  void fetchAuthors({
    bool reinit = false,
    bool fetchMore = false,
  }) async {
    if (!reinit && _authorList.isNotEmpty && !fetchMore) {
      return;
    }

    if (reinit) {
      _showMoreButton = false;
      _hasMoreResults = true;
      deferPageState(
        newPageState: EnumPageState.loading,
        fct: () {
          _authorList.clear();
        },
      );
    }

    if (fetchMore) {
      setImmediatePageState(newPageState: EnumPageState.loadingMore);
    }

    try {
      QueryMap query = FirebaseFirestore.instance
          .collection("authors")
          .orderBy("name")
          .limit(_limitFetchAuthors);

      final DocumentSnapshot? lastDocument = _lastAuthorDocument;
      if (!reinit && lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
        setImmediatePageState(newPageState: EnumPageState.loadingMore);
      }

      final QuerySnapMap snapshot = await query.get();
      listenToDocumentChanges(query);

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

      // setState(() {
      //   _showMoreButton = true;
      //   _lastAuthorDocument = snapshot.docs.last;
      //   setImmediatePageState(newPageState: EnumPageState.idle);
      //   _hasMoreResults = snapshot.size == _limitFetchAuthors;
      // });
      setImmediatePageState(
        newPageState: EnumPageState.idle,
        fct: () {
          _showMoreButton = true;
          _lastAuthorDocument = snapshot.docs.last;
          setImmediatePageState(newPageState: EnumPageState.idle);
          _hasMoreResults = snapshot.size == _limitFetchAuthors;
        },
      );
    } catch (error) {
      loggy.error(error);
      setImmediatePageState();
    }
  }

  Future<bool> fetchLikeForUser(String quoteId) async {
    try {
      final Signal<UserFirestore> currentUser =
          context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

      if (currentUser.value.id.isEmpty) {
        return Future.value(false);
      }

      final DocumentSnapshotMap doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.value.id)
          .collection("favourites")
          .doc(quoteId)
          .get();

      return doc.exists;
    } catch (error) {
      loggy.error(error.toString());
      return Future.value(false);
    }
  }

  /// Try to fetch references alphabetically in Firestore.
  void fetchReferences({
    bool reinit = false,
    bool fetchMore = false,
  }) async {
    if (!reinit && _referenceList.isNotEmpty && !fetchMore) {
      return;
    }

    if (reinit) {
      _showMoreButton = false;
      _hasMoreResults = true;
      // _referenceList.clear();
      deferPageState(
        newPageState: EnumPageState.loading,
        fct: () {
          _referenceList.clear();
        },
      );
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
      listenToDocumentChanges(query);

      if (snapshot.size == 0) {
        _hasMoreResults = false;
        setImmediatePageState();
        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;
        _referenceList.add(Reference.fromMap(data));
      }

      // setState(() {
      //   _showMoreButton = true;
      //   _lastReferenceDocument = snapshot.docs.last;
      //   setImmediatePageState(EnumPageState.idle);
      //   _hasMoreResults = snapshot.size == _limitFetchReferences;
      // });
      setImmediatePageState(fct: () {
        _showMoreButton = true;
        _lastReferenceDocument = snapshot.docs.last;
        _hasMoreResults = snapshot.size == _limitFetchReferences;
      });
    } catch (error) {
      loggy.error(error);
      setImmediatePageState();
    }
  }

  /// Try to fetch showcase data.
  void fetchShowcaseData({
    bool reinit = false,
    bool fetchMore = false,
  }) async {
    if (_searchCategory == EnumSearchCategory.authors) {
      fetchAuthors(
        reinit: reinit,
        fetchMore: fetchMore,
      );
      return;
    }

    if (_searchCategory == EnumSearchCategory.references) {
      fetchReferences(
        reinit: reinit,
        fetchMore: fetchMore,
      );
      return;
    }
  }

  /// Fetch quotes from a specific topic.
  void fetchTopic(String topicName) async {
    setState(() {
      _pageState = _lastQuoteDocument != null
          ? EnumPageState.loadingMore
          : EnumPageState.loading;
    });

    try {
      final String language = Linguistic.currentLanguage;
      final QueryMap query = getTopicQuery(
        topicName: topicName,
        language: language,
      );

      final QuerySnapMap snapshot = await query.get();
      if (snapshot.size == 0) return;

      for (final DocumentSnapshotMap doc in snapshot.docs) {
        final Json? data = doc.data();
        if (data == null) continue;

        data["id"] = doc.id;
        final bool starred = await fetchLikeForUser(data["id"]);
        data["starred"] = starred;
        final Quote quote = Quote.fromMap(data);
        _quoteResults.add(quote);
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _hasMoreResults = snapshot.size == _searchLimit;
        _lastQuoteDocument = snapshot.docs.last;
        _resultCount = _quoteResults.length;
      });
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      setState(() => _pageState = EnumPageState.idle);
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

  /// Return query string category.
  String getCategoryQueryString() {
    return "?category=${_searchCategory.name}";
  }

  /// Return firebase query to fetch quotes from a specific topic.
  QueryMap getTopicQuery({required String topicName, String language = "en"}) {
    final QueryDocSnapMap? lastDocument = _lastQuoteDocument;

    final QueryMap query = FirebaseFirestore.instance
        .collection("quotes")
        .where("topics.$topicName", isEqualTo: true)
        .where("language", isEqualTo: language)
        .orderBy("created_at", descending: true)
        .limit(_searchLimit);

    if (lastDocument == null) {
      return query;
    }

    return query.startAfterDocument(lastDocument);
  }

  /// Handle added author.
  void handleAddedAuthor(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) return;

    data["id"] = doc.id;
    setState(() => _authorList.add(Author.fromMap(data)));
  }

  /// Handle added document.
  void handleAddedDocument(DocumentSnapshotMap doc) {
    if (_searchCategory == EnumSearchCategory.authors) {
      handleAddedAuthor(doc);
      return;
    }

    if (_searchCategory == EnumSearchCategory.references) {
      handleAddedReference(doc);
      return;
    }
  }

  /// Handle added reference.
  void handleAddedReference(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) return;

    data["id"] = doc.id;
    setState(() => _referenceList.add(Reference.fromMap(data)));
  }

  /// Handle modified author.
  void handleModifiedAuthor(DocumentSnapshotMap doc) {
    final int index = _authorList.indexWhere((Author x) => x.id == doc.id);
    if (index == -1) return;

    final Json? data = doc.data();
    if (data == null) return;

    data["id"] = doc.id;
    setState(() => _authorList[index] = Author.fromMap(data));
  }

  /// Handle modified document.
  void handleModifiedDocument(DocumentSnapshotMap doc) {
    if (_searchCategory == EnumSearchCategory.authors) {
      handleModifiedAuthor(doc);
      return;
    }

    if (_searchCategory == EnumSearchCategory.references) {
      handleModifiedReference(doc);
      return;
    }
  }

  /// Handle modified reference.
  void handleModifiedReference(DocumentSnapshotMap doc) {
    final int index =
        _referenceList.indexWhere((Reference x) => x.id == doc.id);
    if (index == -1) return;

    final Json? data = doc.data();
    if (data == null) return;

    data["id"] = doc.id;
    setState(() => _referenceList[index] = Reference.fromMap(data));
  }

  void handlePullQuickAction() {
    final double pixelsPosition = _scrollController.position.pixels;

    if (pixelsPosition < _scrollController.position.minScrollExtent) {
      if (pixelsPosition < _pullTriggerOffset && !_handleQuickAction) {
        boomerangQuickActionValue(true);
        _searchFocusNode.requestFocus();
      }
      return;
    }
  }

  /// Handle removed author.
  void handleRemovedAuthor(DocumentSnapshotMap doc) {
    final int index = _authorList.indexWhere((Author x) => x.id == doc.id);
    if (index == -1) return;
    setState(() => _authorList.removeAt(index));
  }

  /// Handle removed document.
  void handleRemovedDocument(DocumentSnapshotMap doc) {
    if (_searchCategory == EnumSearchCategory.authors) {
      handleRemovedAuthor(doc);
      return;
    }

    if (_searchCategory == EnumSearchCategory.references) {
      handleRemovedReference(doc);
      return;
    }
  }

  /// Handle removed reference.
  void handleRemovedReference(DocumentSnapshotMap doc) {
    final int index = _referenceList.indexWhere(
      (Reference x) => x.id == doc.id,
    );

    if (index == -1) return;
    setState(() => _referenceList.removeAt(index));
  }

  /// Handle start url for search by topic.
  bool handleSearchByTopic() {
    final RouteInformation conf =
        NavigationStateHelper.searchRouterDelegate.configuration;
    final bool hasTopic = conf.uri.path.contains("/topic/");

    if (!hasTopic) {
      return false;
    }

    final String topicName = conf.uri.pathSegments.last;
    _searchInputController.text = topicName;
    fetchTopic(topicName);

    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: "page_title.search_subject".tr(args: [topicName]),
      ),
    );

    return true;
  }

  /// Handle search query param on initialization.
  bool handleSearchQueryParam() {
    final RouteInformation conf =
        NavigationStateHelper.searchRouterDelegate.configuration;
    final Map<String, String> queryParameters = conf.uri.queryParameters;

    bool handled = false;

    if (queryParameters.containsKey("category")) {
      updateCategoryFromKey(queryParameters["category"] ?? "");
      handled = true;
    }

    if (queryParameters.containsKey("q")) {
      _searchInputController.text = queryParameters["q"] ?? "";
      handled = true;
    }

    return handled;
  }

  /// Initialize properties (search category).
  Future<void> initProps() async {
    _searchCategory = await Utils.vault.getLastSearchCategory();
    setState(() {});
  }

  /// Listen to document changes.
  void listenToDocumentChanges(QueryMap query) {
    _streamSnapshot?.cancel();
    _streamSnapshot = query.snapshots().skip(1).listen((QuerySnapMap snapshot) {
      for (final DocumentChangeMap docChange in snapshot.docChanges) {
        switch (docChange.type) {
          case DocumentChangeType.added:
            handleAddedDocument(docChange.doc);
            break;
          case DocumentChangeType.modified:
            handleModifiedDocument(docChange.doc);
            break;
          case DocumentChangeType.removed:
            handleRemovedDocument(docChange.doc);
            break;
          default:
            break;
        }
      }
    }, onDone: () {
      _streamSnapshot?.cancel();
      _streamSnapshot = null;
    });
  }

  /// Manually select search category.
  void manualSelectSearchCategory(String value) {
    switch (value) {
      case "quote":
      case "quotes":
        onSelectSearchCategory(EnumSearchCategory.quotes);
        break;
      case "author":
        onSelectSearchCategory(EnumSearchCategory.authors);
        break;
      case "reference":
        onSelectSearchCategory(EnumSearchCategory.references);
        break;
      default:
    }
  }

  /// Callback fired to clear the search input.
  void onClearInput() {
    _searchInputController.text = "";
    updateBrowserUrl();

    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: "page_title.search".tr(),
      ),
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

    fetchShowcaseData();
  }

  /// Callback fired to open add quote to list dialog.
  void onOpenAddQuoteToList(Quote quote) {
    final String userId =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore).value.id;

    Utils.graphic.showAddToListDialog(
      context,
      isMobileSize: Utils.measurements.isMobileSize(context) ||
          NavigationStateHelper.isIpad,
      isIpad: NavigationStateHelper.isIpad,
      quotes: [quote],
      userId: userId,
    );
  }

  /// Callback fired when route changes (listen to route changes).
  void onRouteChanged() {
    Future.delayed(const Duration(milliseconds: 250), () {
      checkRouteParams();
    });
  }

  /// Callback event when scrolling.
  void onScroll(double offset) {
    handlePullQuickAction();

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
      fetchShowcaseData(fetchMore: true);
      return;
    }

    if (_scrollController.position.maxScrollExtent - offset <= 200) {
      final RouteInformation conf = Beamer.of(context).configuration;
      final bool hasTopic = conf.uri.path.contains("/topic/");
      hasTopic ? fetchTopic(conf.uri.pathSegments.last) : searchMore();
    }
  }

  /// Scroll the view to the top.
  void onScrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceInOut,
    );
    _searchFocusNode.requestFocus();
  }

  /// Callback fired when search input has changed.
  void onSearchFocusChanged() {
    setState(() {});
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
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: "page_title.search_subject".tr(args: [value]),
      ),
    );

    updateBrowserUrl();

    if (value.isEmpty) {
      setState(() {
        _quoteResults.clear();
        _authorResults.clear();
        _referenceResults.clear();
        _prevSearchTextValue = value;
      });

      fetchShowcaseData();
      return;
    }
  }

  /// Callback fired when a different search category is selected (e.g. author).
  /// Clear previous results.
  void onSelectSearchCategory(EnumSearchCategory searchEntity) {
    Utils.vault.saveLastSearchCategory(searchEntity);

    setState(() {
      _searchCategory = searchEntity;
      _resultCount = 0;
      _showMoreButton = searchEntity != EnumSearchCategory.quotes;
    });

    updateBrowserUrl();

    if (!Utils.graphic.isMobile()) {
      _searchFocusNode.requestFocus();
    }

    search();
    fetchShowcaseData(reinit: true);
  }

  /// Callback fired when author is tapped.
  void onTapAuthor(Author author) {
    FocusManager.instance.primaryFocus?.unfocus();
    NavigationStateHelper.author = author;
    Beamer.of(context).beamToNamed(
      SearchContentLocation.authorRoute.replaceFirst(
        ":authorId",
        author.id,
      ),
      routeState: {
        "authorName": author.name,
      },
    );
  }

  /// Callback fired when quote is tapped.
  void onTapQuote(Quote quote) {
    NavigationStateHelper.quote = quote;
    Beamer.of(context).beamToNamed(
      SearchContentLocation.quoteRoute.replaceFirst(":quoteId", quote.id),
      routeState: {
        "quoteName": quote.name,
      },
    );
  }

  /// Callback fired to cancel search.
  void onTapCancelButton() {
    _searchFocusNode.unfocus();
  }

  /// Callback fired when reference is tapped.
  void onTapReference(Reference reference) {
    FocusManager.instance.primaryFocus?.unfocus();
    NavigationStateHelper.reference = reference;
    Beamer.of(context).beamToNamed(
      SearchContentLocation.referenceRoute.replaceFirst(
        ":referenceId",
        reference.id,
      ),
      routeState: {
        "referenceName": reference.name,
      },
    );
  }

  /// Callback fired when a topic is tapped.
  void onTapTopic(Topic topic) {
    FocusManager.instance.primaryFocus?.unfocus();
    _searchInputController.text = topic.name;

    final String path = SearchContentLocation.topicRoute.replaceFirst(
      ":topicName",
      topic.name,
    );

    Beamer.of(context).update(
      configuration: RouteInformation(uri: Uri(path: path)),
    );

    _lastQuoteDocument = null;
    _searchPage = 0;
    _pageState = EnumPageState.searching;
    _quoteResults.clear();
    fetchTopic(topic.name);

    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: "page_title.search_subject".tr(
          args: [topic.name],
        ),
      ),
    );
  }

  /// Callback fired when user avatar is tapped.
  void onTapUserAvatar() {
    Beamer.of(context, root: true).beamToNamed(
      SettingsLocation.route,
    );
  }

  /// Callback fired when a quote is liked or unliked.
  void onToggleLike(Quote quote) async {
    final int index = _quoteResults.indexWhere((x) => x.id == quote.id);
    if (index != -1) {
      setState(() {
        _quoteResults[index] = quote.copyWith(starred: !quote.starred);
      });
    }

    try {
      final Signal<UserFirestore> currentUser =
          context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

      final DocumentSnapshotMap doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.value.id)
          .collection("favourites")
          .doc(quote.id)
          .get();

      if (doc.exists) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.value.id)
            .collection("favourites")
            .doc(quote.id)
            .delete();
        return;
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.value.id)
          .collection("favourites")
          .doc(quote.id)
          .set(quote.toMapFavourite());
    } catch (error) {
      loggy.error(error.toString());
      if (index != -1) {
        setState(() {
          _quoteResults[index] = quote.copyWith(starred: quote.starred);
        });
      }
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

    _searchPage = 0;
    deferPageState(
      newPageState: EnumPageState.searching,
      fct: () => _authorResults.clear(),
    );
    searchAuthors(text);
  }

  /// Build the query to search more authors.
  Future<void> preSearchMoreAuthors(String text) async {
    if (text.isEmpty || !_hasMoreResults) {
      return;
    }

    _pageState = EnumPageState.searchingMore;
    searchAuthors(text);
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

    _searchPage = 0;
    deferPageState(
      newPageState: EnumPageState.searching,
      fct: () {
        _quoteResults.clear();
      },
    );
    searchQuotes(text);
  }

  /// Build the query to search more quotes.
  Future<void> preSearchMoreQuotes(String text) async {
    if (text.isEmpty || !_hasMoreResults) {
      return;
    }

    _pageState = EnumPageState.searchingMore;
    searchQuotes(text);
  }

  /// Build the query to search references.
  Future<void> preSearchReferences(String text) async {
    if (text.isEmpty) {
      setState(() => _referenceResults.clear());
      return;
    }

    deferPageState(
      newPageState: EnumPageState.searching,
      fct: () {
        _referenceResults.clear();
      },
    );
    searchReferences(text);
  }

  /// Build the query to search more references.
  Future<void> preSearchMoreReferences(String text) async {
    if (text.isEmpty || !_hasMoreResults) {
      return;
    }

    _pageState = EnumPageState.searchingMore;
    searchReferences(text);
  }

  /// Remove special keywords from text search (to search the real value).
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

  /// Selective search (according to entity category).
  void search() async {
    _prevSearchTextValue = _searchInputController.text;
    final String text = removeSpecialKeywords(_searchInputController.text);

    switch (_searchCategory) {
      case EnumSearchCategory.quotes:
        preSearchQuotes(text);
        break;
      case EnumSearchCategory.authors:
        preSearchAuthors(text);
        break;
      case EnumSearchCategory.references:
        preSearchReferences(text);
        break;
      default:
    }
  }

  /// Find authors according to the passed text.
  void searchAuthors(String text) async {
    try {
      final AlgoliaQuery query = Utils.search.algolia
          .index("authors")
          .query(text)
          .setHitsPerPage(_searchLimit)
          .setPage(_searchPage);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        setImmediatePageState(fct: () => _hasMoreResults = false);
        return;
      }

      _authorResults.clear();
      for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
        final Json data = hit.data;
        data["id"] = hit.objectID;

        final Author author = Author.fromMap(data);
        _authorResults.add(author);
      }

      setImmediatePageState(fct: () {
        _searchPage = _searchPage + 1;
        _resultCount = snapshot.nbHits;
        _hasMoreResults = snapshot.page < snapshot.nbPages - 1;
      });
    } catch (error) {
      loggy.error(error.toString());
      setImmediatePageState();
    }
  }

  /// Selective search (according to entity category).
  void searchMore() async {
    _prevSearchTextValue = _searchInputController.text;

    final String text = removeSpecialKeywords(_searchInputController.text);

    switch (_searchCategory) {
      case EnumSearchCategory.quotes:
        preSearchMoreQuotes(text);
        break;
      case EnumSearchCategory.authors:
        preSearchMoreAuthors(text);
        break;
      case EnumSearchCategory.references:
        preSearchMoreReferences(text);
        break;
      default:
    }
  }

  /// Find quotes according to the passed text.
  void searchQuotes(String text) async {
    try {
      final AlgoliaQuery query = Utils.search.algolia
          .index("quotes")
          .query(text)
          .setHitsPerPage(_searchLimit)
          .setPage(_searchPage);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        setImmediatePageState(fct: () => _hasMoreResults = false);
        return;
      }

      _quoteResults.clear();
      for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
        final Json data = hit.data;
        data["id"] = hit.objectID;

        final bool starred = await fetchLikeForUser(data["id"]);
        data["starred"] = starred;
        final Quote quote = Quote.fromMap(data);
        _quoteResults.add(quote);
      }

      setImmediatePageState(fct: () {
        _searchPage = _searchPage + 1;
        _resultCount = snapshot.nbHits;
        _hasMoreResults = snapshot.page < snapshot.nbPages - 1;
      });
    } catch (error) {
      loggy.error(error.toString());
      setImmediatePageState();
    }
  }

  /// Find references according to the passed text.
  void searchReferences(String text) async {
    try {
      final AlgoliaQuery query = Utils.search.algolia
          .index("references")
          .query(text)
          .setHitsPerPage(_searchLimit)
          .setPage(0);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        setImmediatePageState();
        return;
      }

      _referenceResults.clear();
      for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
        final Json data = hit.data;
        data["id"] = hit.objectID;

        final Reference reference = Reference.fromMap(data);
        _referenceResults.add(reference);
      }

      setImmediatePageState(fct: () {
        _searchPage++;
        _resultCount = snapshot.nbHits;
        _hasMoreResults = snapshot.page < snapshot.nbPages - 1;
      });
    } catch (error) {
      loggy.error(error.toString());
      setImmediatePageState();
    }
  }

  /// Set the new page state without any delay.
  void setImmediatePageState({
    EnumPageState newPageState = EnumPageState.idle,
    void Function()? fct,
  }) {
    _pageSateTimer?.cancel();
    setState(() {
      _pageState = newPageState;
      fct?.call();
      _pageSateTimer = null;
    });
  }

  /// Update browser URL on input changes.
  void updateBrowserUrl() {
    final String queryCategory = getCategoryQueryString();
    final String text = _searchInputController.text;
    final String querySearch = text.isEmpty ? "" : "&q=$text";

    final String path =
        "${SearchContentLocation.route}$queryCategory$querySearch";

    NavigationStateHelper.searchRouterDelegate.beamToReplacementNamed(
      path,
    );
  }

  /// Update search category from query param.
  void updateCategoryFromKey(String key) {
    EnumSearchCategory searchCategory = EnumSearchCategory.quotes;

    switch (key) {
      case "authors":
        searchCategory = EnumSearchCategory.authors;
        break;
      case "quotes":
        searchCategory = EnumSearchCategory.quotes;
        break;
      case "references":
        searchCategory = EnumSearchCategory.references;
        break;
      default:
        searchCategory = EnumSearchCategory.quotes;
        break;
    }

    setState(() => _searchCategory = searchCategory);
  }
}
