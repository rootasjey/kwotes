import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/drafts/drafts_page_body.dart";
import "package:kwotes/screens/drafts/drafts_page_header.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/document_change_map.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/firestore/query_snapshot_stream_subscription.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";

class DraftsPage extends StatefulWidget {
  const DraftsPage({
    super.key,
    this.isInTab = false,
    this.pageScrollController,
    this.selectedLanguage = EnumLanguageSelection.en,
  });

  /// True if this page is in a tab.
  final bool isInTab;

  /// Current selected language to fetch draft quotes.
  final EnumLanguageSelection selectedLanguage;

  /// Page's scroll controller from parent widget.
  final ScrollController? pageScrollController;

  @override
  State<DraftsPage> createState() => _DraftsPageState();
}

class _DraftsPageState extends State<DraftsPage> with UiLoggy {
  /// Animate list's items if true.
  bool _animateList = true;

  /// True if more results can be loaded.
  bool _hasNextPage = true;

  /// True if the order is the most recent first.
  final bool _descending = true;

  /// Color of selected widgets (e.g. for filter chips).
  Color _selectedColor = Colors.amber.shade200;

  /// Page's state.
  EnumPageState _pageState = EnumPageState.idle;

  /// Result count limit.
  final int _limit = 20;

  /// List of drafts quotes.
  final List<DraftQuote> _drafts = [];

  /// Last document.
  QueryDocSnapMap? _lastDocument;

  /// Stream subscription for draft quotes.
  QuerySnapshotStreamSubscription? _draftSub;

  /// Page's scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initProps();
    fetch();
  }

  @override
  void didUpdateWidget(covariant DraftsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLanguage != widget.selectedLanguage) {
      _lastDocument = null;
      _drafts.clear();
      fetch();
    }
  }

  @override
  void dispose() {
    widget.pageScrollController?.removeListener(onPageScroll);
    _pageScrollController.dispose();
    _draftSub?.cancel();
    _draftSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.isInTab) {
      return DraftsPageBody(
        animateList: _animateList,
        draftQuotes: _drafts,
        isDark: isDark,
        isMobileSize: isMobileSize,
        onCopyFrom: onCopyFromDraftQuote,
        onDelete: onDeleteDraftQuote,
        onEdit: onEditDraftQuote,
        onSubmit: onSubmitDraftQuote,
        onTap: onTapDraftQuote,
        pageState: _pageState,
      );
    }

    double toolbarHeight = 160.0;
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
                  DraftsPageHeader(
                    isMobileSize: isMobileSize,
                    onSelectLanguage: onSelectedLanguage,
                    onTapTitle: onTapTitle,
                    selectedColor: _selectedColor,
                    selectedLanguage: widget.selectedLanguage,
                    show: NavigationStateHelper.showHeaderPageOptions,
                  ),
                ],
              ),
              DraftsPageBody(
                animateList: _animateList,
                draftQuotes: _drafts,
                isDark: isDark,
                isMobileSize: isMobileSize,
                onCopyFrom: onCopyFromDraftQuote,
                onDelete: onDeleteDraftQuote,
                onEdit: onEditDraftQuote,
                onSubmit: onSubmitDraftQuote,
                onTap: onTapDraftQuote,
                pageState: _pageState,
              ),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 96.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fetch() async {
    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final UserFirestore userFirestore = signalUserFirestore.value;
    if (userFirestore.id.isEmpty) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _pageState = _lastDocument == null
          ? EnumPageState.loading
          : EnumPageState.loadingMore;
    });

    try {
      final QueryMap query = getQuery(userFirestore.id);
      final QuerySnapMap snapshot = await query.get();
      listenToDraftChanges(query);

      if (snapshot.docs.isEmpty) {
        if (!mounted) return;
        setState(() {
          _pageState = EnumPageState.idle;
          _hasNextPage = false;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;
        final DraftQuote quote = DraftQuote.fromMap(data);
        _drafts.add(quote);
      }

      if (!mounted) return;
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

  QueryMap getQuery(String userId) {
    final QueryDocSnapMap? lastDocument = _lastDocument;

    QueryMap baseQuery = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("drafts")
        .orderBy("created_at", descending: _descending)
        .limit(_limit);

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

  /// Callback fired when a draft is added to the Firestore collection.
  void handleAddedDraft(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) {
      return;
    }

    final DraftQuote foundDraft = _drafts.firstWhere(
      (DraftQuote x) => x.id == doc.id,
      orElse: () => DraftQuote.empty(),
    );

    if (foundDraft.id.isNotEmpty) {
      return;
    }

    data["id"] = doc.id;
    final DraftQuote draft = DraftQuote.fromMap(data);
    if (!mounted) return;
    setState(() => _drafts.insert(0, draft));
  }

  /// Callback fired when a draft is modified in the Firestore collection.
  void handleModifiedDraft(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) {
      return;
    }

    final int index = _drafts.indexWhere(
      (DraftQuote x) => x.id == doc.id,
    );

    if (index == -1) {
      return;
    }

    data["id"] = doc.id;
    final DraftQuote draft = DraftQuote.fromMap(data);
    if (!mounted) return;
    setState(() => _drafts[index] = draft);
  }

  /// Callback fired when a draft is removed from the Firestore collection.
  void handleRemovedDraft(DocumentSnapshotMap doc) {
    final int index = _drafts.indexWhere(
      (DraftQuote x) => x.id == doc.id,
    );

    if (index == -1) {
      return;
    }

    if (!mounted) return;
    setState(() => _drafts.removeAt(index));
  }

  /// Initialize page properties.
  void initProps() async {
    widget.pageScrollController?.addListener(onPageScroll);
    _selectedColor = Constants.colors.getRandomFromPalette().withOpacity(0.6);
    if (!mounted) return;
    setState(() {});

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _animateList = false);
    });
  }

  /// Listen to draft quotes changes.
  void listenToDraftChanges(QueryMap query) {
    _draftSub?.cancel();
    _draftSub = query.snapshots().skip(1).listen((QuerySnapMap snapshot) {
      for (final DocumentChangeMap docChange in snapshot.docChanges) {
        switch (docChange.type) {
          case DocumentChangeType.added:
            handleAddedDraft(docChange.doc);
            break;
          case DocumentChangeType.modified:
            handleModifiedDraft(docChange.doc);
            break;
          case DocumentChangeType.removed:
            handleRemovedDraft(docChange.doc);
            break;
          default:
            break;
        }
      }
    }, onDone: () {
      _draftSub?.cancel();
      _draftSub = null;
    });
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

  /// Callback fired when the draft quote is tapped.
  /// Navigate to the edit page with the selected quote.
  void onTapDraftQuote(DraftQuote draftQuote) {
    onEditDraftQuote(draftQuote);
  }

  /// Callback fired when a draft quote is going to be deleted.
  void onDeleteDraftQuote(DraftQuote quote) async {
    final int index = _drafts.indexOf(quote);
    if (!mounted) return;
    setState(() => _drafts.removeAt(index));

    final Signal<UserFirestore> userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userFirestore.value.id)
          .collection("drafts")
          .doc(quote.id)
          .delete();
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      setState(() => _drafts.insert(index, quote));

      Utils.graphic.showSnackbar(
        context,
        message: "quote.delete.failed".tr(),
      );
    }
  }

  /// Callback fired when a draft quote is going to be edited.
  void onEditDraftQuote(DraftQuote draftQuote) {
    NavigationStateHelper.quote = draftQuote;
    context.beamToNamed(
      DashboardContentLocation.editQuoteRoute.replaceFirst(
        ":quoteId",
        draftQuote.id,
      ),
    );
  }

  /// Create a new quote from an existing draft.
  void onCopyFromDraftQuote(DraftQuote quote) {
    NavigationStateHelper.quote = quote.copyDraftWith(id: "");
    context.beamToNamed(DashboardContentLocation.addQuoteRoute);
  }

  /// Callback to select a language.
  void onSelectedLanguage(EnumLanguageSelection language) {
    if (widget.selectedLanguage == language) {
      return;
    }

    Utils.vault.setPageLanguage(language);

    if (!mounted) return;
    setState(() {
      // _selectedLanguage = language;
      _drafts.clear();
      _lastDocument = null;
    });

    fetch();
  }

  /// Callback to submit a draft quote for validation.
  void onSubmitDraftQuote(DraftQuote quote) async {
    final Signal<UserFirestore> userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (userFirestore.value.id.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "signin.again".tr(),
      );
    }

    final bool success = await QuoteActions.submitQuote(
      quote: quote,
      userId: userFirestore.value.id,
    );

    if (!mounted || success) return;
    Utils.graphic.showSnackbar(
      context,
      message: "quote.submit.failed".tr(),
    );
  }

  /// Callback to show/hide page options.
  void onTapTitle() {
    final bool newShowPageOptions =
        !NavigationStateHelper.showHeaderPageOptions;
    Utils.vault.setShowHeaderOptions(newShowPageOptions);

    if (!mounted) return;
    setState(() {
      NavigationStateHelper.showHeaderPageOptions = newShowPageOptions;
    });
  }
}
