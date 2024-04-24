import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/published/header_filter.dart";
import "package:kwotes/screens/published/published_page_body.dart";
import "package:kwotes/screens/published/published_page_header.dart";
import "package:kwotes/screens/published/simple_published_page_header.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/enums/enum_data_ownership.dart";
import "package:kwotes/types/enums/enum_draft_quote_operation.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/document_change_map.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/firestore/query_snapshot_stream_subscription.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:kwotes/types/user/user_rights.dart";
import "package:loggy/loggy.dart";
import "package:screenshot/screenshot.dart";
import "package:text_wrap_auto_size/solution.dart";

class PublishedPage extends StatefulWidget {
  const PublishedPage({
    super.key,
    this.isInTab = false,
    this.pageScrollController,
    this.selectedLanguage = EnumLanguageSelection.en,
    this.selectedOwnership = EnumDataOwnership.owned,
  });

  /// True if this page is in a tab.
  final bool isInTab;

  /// The selected ownership for quotes in validation.
  final EnumDataOwnership selectedOwnership;

  /// The selected language for quotes in validation.
  final EnumLanguageSelection selectedLanguage;

  /// Page's scroll controller from parent widget.
  final ScrollController? pageScrollController;

  @override
  State<PublishedPage> createState() => _PublishedPageState();
}

class _PublishedPageState extends State<PublishedPage> with UiLoggy {
  /// True if the order is the most recent first.
  final bool _descending = true;

  /// True if more results can be loaded.
  bool _hasNextPage = true;

  /// Color of selected widgets (e.g. for filter chips).
  Color chipSelectedColor = Colors.amber;

  /// Page's state.
  EnumPageState _pageState = EnumPageState.idle;

  /// Result count limit.
  final int _limit = 20;

  /// List of pubslihed quotes.
  final List<Quote> _quotes = [];

  /// Last document.
  QueryDocSnapMap? _lastDocument;

  /// Stream subscription for published quotes.
  QuerySnapshotStreamSubscription? _quoteSub;

  /// Screenshot controller (to share quote image).
  final ScreenshotController _screenshotController = ScreenshotController();

  /// Page's scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  /// Text wrap solution to calculate font size according to window size.
  Solution _textWrapSolution = Solution(
    const Text(""),
    const TextStyle(),
    const Size(0, 0),
    const Size(0, 0),
  );

  /// Firestore collection name.
  final String _collectionName = "quotes";

  @override
  void initState() {
    super.initState();
    initProps();
    fetch();
  }

  @override
  void didUpdateWidget(covariant PublishedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLanguage != widget.selectedLanguage) {
      _lastDocument = null;
      _quotes.clear();
      fetch();
    }
  }

  @override
  void dispose() {
    widget.pageScrollController?.removeListener(onPageScroll);
    _pageScrollController.dispose();
    _quoteSub?.cancel();
    _quoteSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.isInTab) {
      return SignalBuilder(
        signal: signalUserFirestore,
        builder: (
          BuildContext context,
          UserFirestore userFirestore,
          Widget? child,
        ) {
          final UserRights userRights = userFirestore.rights;
          final bool isAdmin = userRights.canManageQuotes;

          return PublishedPageBody(
            isDark: isDark,
            pageState: _pageState,
            isMobileSize: isMobileSize,
            quotes: _quotes,
            onTap: onTapQuote,
            onCopy: onCopyQuote,
            onCopyQuoteUrl: onCopyQuoteUrl,
            onDelete: isAdmin ? onDeleteQuote : null,
            onEdit: isAdmin ? onEditQuote : null,
            onChangeLanguage: isAdmin ? onChangeQuoteLanguage : null,
            onOpenAddToList: onOpenAddToList,
            onShareImage: onShareImage,
            onShareLink: onShareLink,
            onShareText: onShareText,
            userId: userFirestore.id,
          );
        },
      );
    }

    double toolbarHeight = 92.0;
    if (!widget.isInTab) {
      toolbarHeight = isMobileSize ? 200.0 : 282.0;
    }

    return Scaffold(
      body: ImprovedScrolling(
        scrollController: _pageScrollController,
        onScroll: onScroll,
        child: ScrollConfiguration(
          behavior: const CustomScrollBehavior(),
          child: CustomScrollView(
            controller: _pageScrollController,
            slivers: [
              PageAppBar(
                hideBackButton: widget.isInTab,
                isMobileSize: isMobileSize,
                toolbarHeight: toolbarHeight,
                children: [
                  widget.isInTab
                      ? SimplePublishedPageHeader(
                          onTapFilter: onTapFilter,
                          canSeeOtherQuotes: true,
                        )
                      : PublishedPageHeader(
                          isMobileSize: isMobileSize,
                          onSelectedOwnership: onSelectedOnwership,
                          onSelectLanguage: onSelectedLanguage,
                          onTapTitle: onTapTitle,
                          selectedColor: chipSelectedColor,
                          selectedLanguage: widget.selectedLanguage,
                          selectedOwnership: widget.selectedOwnership,
                          show: NavigationStateHelper.showHeaderPageOptions,
                          showAllOwnership: true,
                        ),
                ],
              ),
              SignalBuilder(
                signal: signalUserFirestore,
                builder: (
                  BuildContext context,
                  UserFirestore userFirestore,
                  Widget? child,
                ) {
                  final UserRights userRights = userFirestore.rights;
                  final bool isAdmin = userRights.canManageQuotes;

                  return PublishedPageBody(
                    isDark: isDark,
                    pageState: _pageState,
                    isMobileSize: isMobileSize,
                    quotes: _quotes,
                    onOpenAddToList: onOpenAddToList,
                    onTap: onTapQuote,
                    onCopy: onCopyQuote,
                    onCopyQuoteUrl: onCopyQuoteUrl,
                    onDelete: isAdmin ? onDeleteQuote : null,
                    onEdit: isAdmin ? onEditQuote : null,
                    onChangeLanguage: isAdmin ? onChangeQuoteLanguage : null,
                    onShareImage: onShareImage,
                    onShareLink: onShareLink,
                    onShareText: onShareText,
                    userId: userFirestore.id,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Return Firestore query.
  QueryMap getQuery(String userId) {
    final QueryDocSnapMap? lastDocument = _lastDocument;

    QueryMap baseQuery = FirebaseFirestore.instance
        .collection(_collectionName)
        .limit(_limit)
        .orderBy("created_at", descending: _descending);

    if (widget.selectedOwnership == EnumDataOwnership.owned) {
      baseQuery = baseQuery.where("user.id", isEqualTo: userId);
    }

    if (widget.selectedLanguage != EnumLanguageSelection.all) {
      baseQuery = baseQuery.where(
        "language",
        isEqualTo: widget.selectedLanguage.name,
      );
    }

    if (lastDocument == null) {
      return baseQuery;
    }

    return baseQuery.startAfterDocument(lastDocument);
  }

  /// Fetch data.
  void fetch() async {
    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final UserFirestore userFirestore = signalUserFirestore.value;
    if (userFirestore.id.isEmpty) {
      return;
    }

    _pageState = _lastDocument == null
        ? EnumPageState.loading
        : EnumPageState.loadingMore;

    try {
      final QueryMap query = getQuery(userFirestore.id);
      final QuerySnapMap snapshot = await query.get();
      listenToQuoteChanges(query);

      if (snapshot.docs.isEmpty) {
        setState(() {
          _pageState = EnumPageState.idle;
          _hasNextPage = false;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;
        final Quote quote = Quote.fromMap(data);
        _quotes.add(quote);
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _lastDocument = snapshot.docs.last;
        _hasNextPage = _limit == snapshot.docs.length;
      });
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      setState(() {
        _pageState = EnumPageState.idle;
      });
    }
  }

  /// Callback fired when a document is added to the Firestore collection.
  void handleAddedQuote(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) {
      return;
    }

    final int foundIndex = _quotes.indexWhere((Quote x) => x.id == doc.id);
    if (foundIndex > -1) return;

    data["id"] = doc.id;
    final Quote draft = Quote.fromMap(data);
    setState(() => _quotes.insert(0, draft));
  }

  /// Callback fired when a quote is modified in the Firestore collection.
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
    final int index = _quotes.indexWhere(
      (Quote x) => x.id == doc.id,
    );

    if (index == -1) {
      return;
    }

    setState(() => _quotes.removeAt(index));
  }

  /// Load saved settings and initialize properties.
  Future<void> initProps() async {
    widget.pageScrollController?.addListener(onPageScroll);
    chipSelectedColor =
        Constants.colors.getRandomFromPalette().withOpacity(0.6);
  }

  /// Listen to quote changes.
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

  /// Callback to update a quote's language.
  void onChangeQuoteLanguage(Quote quote, String language) async {
    final Signal<UserFirestore> currentUser =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final UserRights userRights = currentUser.value.rights;
    final bool canManageQuotes = userRights.canManageQuotes;

    if (!canManageQuotes) {
      return;
    }

    final int index = _quotes.indexOf(quote);
    if (index == -1) {
      return;
    }

    if (language == quote.language) {
      return;
    }

    if (widget.selectedLanguage != EnumLanguageSelection.all &&
        widget.selectedLanguage.name != language) {
      setState(() => _quotes.removeAt(index));
    }

    try {
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(quote.id)
          .update({"language": language});
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      Utils.graphic.showSnackbar(
        context,
        message: "quote.update.failed".tr(),
      );
    }
  }

  /// Copy a quote's name.
  void onCopyQuote(Quote quote) {
    QuoteActions.copyQuote(quote);
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyQuoteSnackbar(context, isMobileSize: isMobileSize);
  }

  /// Copy quote's url.
  void onCopyQuoteUrl(Quote quote) {
    QuoteActions.copyQuoteUrl(quote);
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyQuoteLinkSnackbar(
      context,
      isMobileSize: isMobileSize,
    );
  }

  /// Callback to delete a published quote.
  void onDeleteQuote(Quote quote) async {
    final Signal<UserFirestore> currentUser =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final UserRights userRights = currentUser.value.rights;
    final bool canManageQuotes = userRights.canManageQuotes;

    if (!canManageQuotes) return;

    final int index = _quotes.indexOf(quote);
    if (index == -1) return;

    setState(() => _quotes.removeAt(index));

    try {
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(quote.id)
          .delete();

      if (!mounted) return;
      Utils.graphic.showSnackbarWithCustomText(
        context,
        duration: const Duration(seconds: 30),
        text: Row(children: [
          Expanded(
            flex: 0,
            child: Text(
              "quote.delete.success".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.6),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: TextButton(
              onPressed: () {
                setState(() => _quotes.insert(index, quote));
                FirebaseFirestore.instance
                    .collection(_collectionName)
                    .doc(quote.id)
                    .set(quote.toMap(
                      operation: EnumQuoteOperation.restore,
                    ));

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                fontSize: 16.0,
              )),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "rollback".tr(),
                    style: Utils.calligraphy.body(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(TablerIcons.rotate_2),
                  ),
                ],
              ),
            ),
          ),
        ]),
      );
    } catch (error) {
      loggy.error(error);
      setState(() => _quotes.insert(index, quote));
    }
  }

  /// Open add to list dialog.
  void onOpenAddToList(Quote quote) {
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

  /// Callback to edit a published quote.
  void onEditQuote(Quote quote) {
    NavigationStateHelper.quote = quote;
    context.beamToNamed(
      DashboardContentLocation.addQuoteRoute.replaceFirst(":quoteId", quote.id),
      data: {
        "quoteId": quote.id,
      },
    );
  }

  /// Scrolls the page based on the current scroll position.
  ///
  /// This function retrieves the current scroll position from the provided
  /// `pageScrollController`. If the scroll position is at or beyond the maximum
  /// scroll extent, it calls the `fetch` function.
  void onPageScroll() {
    final ScrollController? controller = widget.pageScrollController;
    if (controller == null) return;
    if (controller.position.pixels >= controller.position.maxScrollExtent) {
      fetch();
    }
  }

  /// Callback fired when the page is scrolled.
  /// Fetch more data.
  void onScroll(double offset) {
    if (!_hasNextPage) {
      return;
    }

    if (_pageState == EnumPageState.loading ||
        _pageState == EnumPageState.loadingMore) {
      return;
    }

    if (_pageScrollController.position.maxScrollExtent - offset <= 200) {
      fetch();
    }
  }

  /// Callback to select a language.
  void onSelectedLanguage(EnumLanguageSelection language) {
    if (widget.selectedLanguage == language) {
      return;
    }

    setState(() {
      _quotes.clear();
      _lastDocument = null;
    });

    Utils.vault.setPageLanguage(language);
    fetch();
  }

  /// Callback to filter published quotes (owned | all).
  void onSelectedOnwership(EnumDataOwnership ownership) {
    if (widget.selectedOwnership == ownership) {
      return;
    }

    setState(() {
      _quotes.clear();
      _lastDocument = null;
    });

    Utils.vault.setDataOwnership(ownership);
    fetch();
  }

  /// Open share image bottom sheet.
  void onShareImage(Quote quote) {
    final Size windowSize = MediaQuery.of(context).size;
    _textWrapSolution = Utils.graphic.getTextSolution(
      quote: quote,
      windowSize: windowSize,
      style: Utils.calligraphy.body(),
    );

    Utils.graphic.onOpenShareImage(
      context,
      mounted: mounted,
      quote: quote,
      screenshotController: _screenshotController,
      textWrapSolution: _textWrapSolution,
    );
  }

  /// Callback fired to share quote as link.
  void onShareLink(Quote quote) {
    Utils.graphic.onShareLink(context, quote: quote);
  }

  /// Callback fired to share quote as text.
  void onShareText(Quote quote) {
    Utils.graphic.onShareText(
      context,
      quote: quote,
      onCopyQuote: (Quote quote) {
        onCopyQuote(quote);
        Utils.graphic.showSnackbar(
          context,
          message: "quote.copy.success.name".tr(),
        );
      },
    );
  }

  /// Navigate to quote page when a quote is tapped.
  void onTapQuote(Quote quote) {
    NavigationStateHelper.quote = quote;
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.publishedQuoteRoute.replaceFirst(
        ":quoteId",
        quote.id,
      ),
    );
  }

  /// Callback to show/hide page options.
  void onTapTitle() {
    final bool newShowPageOptions =
        !NavigationStateHelper.showHeaderPageOptions;
    Utils.vault.setShowHeaderOptions(newShowPageOptions);

    setState(() {
      NavigationStateHelper.showHeaderPageOptions = newShowPageOptions;
    });
  }

  void onTapFilter(bool canManageQuotes) {
    Utils.graphic.showAdaptiveDialog(
      context,
      isMobileSize: true,
      builder: (BuildContext context) {
        return Align(
          heightFactor: 0.5,
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 24.0,
              top: 142.0,
            ),
            child: HeaderFilter(
              direction: Axis.vertical,
              showAllOwnership: canManageQuotes,
              selectedOwnership: widget.selectedOwnership,
              onSelectedOwnership: canManageQuotes ? onSelectedOnwership : null,
              selectedLanguage: widget.selectedLanguage,
              onSelectLanguage: (language) {
                onSelectedLanguage(language);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }
}
