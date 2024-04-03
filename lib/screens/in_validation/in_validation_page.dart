import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/in_validation/in_validation_page_body.dart";
import "package:kwotes/screens/in_validation/in_validation_page_header.dart";
import "package:kwotes/screens/in_validation/simple_in_validation_page_header.dart";
import "package:kwotes/screens/published/header_filter.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/enums/enum_data_ownership.dart";
import "package:kwotes/types/enums/enum_draft_quote_operation.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/document_change_map.dart";
import "package:kwotes/types/firestore/document_map.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/firestore/query_snapshot_stream_subscription.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_auth.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:kwotes/types/user/user_rights.dart";
import "package:loggy/loggy.dart";

class InValidationPage extends StatefulWidget {
  const InValidationPage({
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
  State<InValidationPage> createState() => _InValidationPageState();
}

class _InValidationPageState extends State<InValidationPage> with UiLoggy {
  /// Animate list's items if true.
  bool _animateList = true;

  /// True if more results can be loaded.
  bool _hasNextPage = true;

  /// True if the order is the most recent first.
  final bool _descending = true;

  /// Color of selected widgets (e.g. for filter chips).
  Color _selectedColor = Colors.amber.shade200;

  /// Selected tab index (owned | all).
  // EnumDataOwnership _selectedOwnership = EnumDataOwnership.owned;

  /// Current selected language to fetch quotes in validation.
  // EnumLanguageSelection _selectedLanguage = EnumLanguageSelection.all;

  /// Page's state.
  EnumPageState _pageState = EnumPageState.idle;

  /// Result count limit.
  final int _limit = 20;

  /// List of draft quotes in validation.
  final List<DraftQuote> _drafts = [];

  /// Last document.
  QueryDocSnapMap? _lastDocument;

  /// Page's scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  /// Stream subscription for draft quotes.
  QuerySnapshotStreamSubscription? _draftSub;

  /// Page collection name.
  final String _collectionName = "drafts";

  @override
  void initState() {
    super.initState();
    initProps();
    fetch();
  }

  @override
  void didUpdateWidget(covariant InValidationPage oldWidget) {
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
          final bool canManage = userRights.canManageQuotes;

          return InValidationPageBody(
            animateList: _animateList,
            isDark: isDark,
            isMobileSize: isMobileSize,
            pageState: _pageState,
            quotes: _drafts,
            onTap: onTapDraftQuote,
            onDelete: onDeleteDraftQuote,
            onValidate: canManage ? onValidateDraftQuote : null,
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
              SignalBuilder(
                signal: signalUserFirestore,
                builder: (
                  BuildContext context,
                  UserFirestore userFirestore,
                  Widget? child,
                ) {
                  final UserRights userRights = userFirestore.rights;
                  final bool canManage = userRights.canManageQuotes;
                  final onSelectOwnership =
                      canManage ? onSelectedOnwership : null;

                  return PageAppBar(
                    hideBackButton: widget.isInTab,
                    isMobileSize: isMobileSize,
                    toolbarHeight: toolbarHeight,
                    children: [
                      widget.isInTab
                          ? SimpleInValidationPageHeader(
                              onTapFilter: onTapFilter,
                              canManageQuotes: canManage,
                            )
                          : InValidationPageHeader(
                              onSelectedOwnership: onSelectOwnership,
                              onSelectLanguage: onSelectedLanguage,
                              onTapTitle: onTapTitle,
                              selectedColor: _selectedColor,
                              selectedLanguage: widget.selectedLanguage,
                              selectedOwnership: widget.selectedOwnership,
                              show: NavigationStateHelper.showHeaderPageOptions,
                              showAllOwnership: canManage,
                              showAllLanguagesChip: true,
                              isMobileSize: isMobileSize,
                            ),
                    ],
                  );
                },
              ),
              SignalBuilder(
                signal: signalUserFirestore,
                builder: (
                  BuildContext context,
                  UserFirestore userFirestore,
                  Widget? child,
                ) {
                  final UserRights userRights = userFirestore.rights;
                  final bool canManage = userRights.canManageQuotes;

                  return InValidationPageBody(
                    animateList: _animateList,
                    isDark: isDark,
                    isMobileSize: isMobileSize,
                    pageState: _pageState,
                    quotes: _drafts,
                    onTap: onTapDraftQuote,
                    onDelete: onDeleteDraftQuote,
                    onValidate: canManage ? onValidateDraftQuote : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fetch draft quotes.
  void fetch() async {
    final UserAuth? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final String userId = currentUser.uid;
    _pageState = EnumPageState.loadingMore;

    try {
      final QueryMap query = getQuery(userId);
      final QuerySnapMap snapshot = await query.get();
      listenToDraftChanges(query);

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
        data["in_validation"] = true;
        final DraftQuote draft = DraftQuote.fromMap(data);
        _drafts.add(draft);
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _lastDocument = snapshot.docs.last;
        _hasNextPage = _limit == snapshot.docs.length;
      });
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      setState(() => _pageState = EnumPageState.error);
    }
  }

  /// Returns firestore query according to the last fetched document.
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
      baseQuery =
          baseQuery.where("language", isEqualTo: widget.selectedLanguage.name);
    }

    if (lastDocument == null) {
      return baseQuery;
    }

    return baseQuery.startAfterDocument(lastDocument);
  }

  /// Callback fired when a draft is added to the Firestore collection.
  void handleAddedDraft(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) return;

    data["id"] = doc.id;
    data["in_validation"] = true;
    final DraftQuote draft = DraftQuote.fromMap(data);

    final bool shouldAddOnTop =
        DateTime.now().difference(draft.createdAt).inDays < 1;

    shouldAddOnTop ? _drafts.insert(0, draft) : _drafts.add(draft);
    setState(() {});
  }

  /// Callback fired when a draft is modified in the Firestore collection.
  void handleModifiedDraft(DocumentSnapshotMap doc) {
    final int index = _drafts.indexWhere((DraftQuote x) => x.id == doc.id);
    if (index == -1) return;

    final Json? data = doc.data();
    if (data == null) return;

    data["id"] = doc.id;
    data["in_validation"] = true;

    final DraftQuote draft = DraftQuote.fromMap(data);
    setState(() => _drafts[index] = draft);
  }

  /// Callback fired when a draft is removed from the Firestore collection.
  void handleRemovedDraft(DocumentSnapshotMap doc) {
    final int index = _drafts.indexWhere((DraftQuote x) => x.id == doc.id);
    if (index == -1) return;
    setState(() => _drafts.removeAt(index));
  }

  /// Initialize page properties.
  void initProps() async {
    widget.pageScrollController?.addListener(onPageScroll);
    _selectedColor = Constants.colors.getRandomFromPalette().withOpacity(0.6);
    setState(() {});

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _animateList = false);
    });
  }

  /// Listen to draft quote changes.
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

  /// Callback fired when the page is scrolled.
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

  /// Callback fired when a draft quote is tapped.
  void onTapDraftQuote(Quote draftQuote) {
    NavigationStateHelper.quote = draftQuote;
    context.beamToNamed(DashboardContentLocation.addQuoteRoute);
  }

  /// Callback fired when a draft quote in validation is deleted.
  void onDeleteDraftQuote(DraftQuote quote) async {
    final int index = _drafts.indexOf(quote);
    setState(() => _drafts.remove(quote));

    try {
      await FirebaseFirestore.instance
          .collection(_collectionName)
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

  /// Callback to select a language.
  void onSelectedLanguage(EnumLanguageSelection language) {
    if (widget.selectedLanguage == language) {
      return;
    }

    setState(() {
      _drafts.clear();
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
      _drafts.clear();
      _lastDocument = null;
    });

    Utils.vault.setDataOwnership(ownership);
    fetch();
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

  /// Callback fired when a draft quote is validated.
  void onValidateDraftQuote(DraftQuote draft) async {
    final int index = _drafts.indexOf(draft);
    if (index == -1) {
      Utils.graphic.showSnackbar(
        context,
        message: "quote.error.not_found".tr(),
      );
      return;
    }

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (userFirestoreSignal.value.id.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "quote.error.user.unauthenticated".tr(),
      );
      return;
    }

    final UserRights rights = userFirestoreSignal.value.rights;
    if (!rights.canManageQuotes) {
      Utils.graphic.showSnackbar(
        context,
        message: "quote.error.user.not_admin".tr(),
      );
      return;
    }

    setState(() => _drafts.removeAt(index));

    try {
      final DocumentMap addedQuoteDoc =
          await FirebaseFirestore.instance.collection("quotes").add(draft.toMap(
                userId: userFirestoreSignal.value.id,
                operation: EnumQuoteOperation.validate,
              ));

      final DocumentSnapshotMap snapshot = await addedQuoteDoc.get();
      if (!snapshot.exists) {
        if (!mounted) return;
        Utils.graphic.showSnackbar(
          context,
          message: "quote.validate.failed".tr(),
        );
        return;
      }

      // Delete draft.
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(draft.id)
          .delete();
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;

      Utils.graphic.showSnackbar(
        context,
        message: "quote.validate.failed".tr(),
      );

      setState(() => _drafts.insert(index, draft));
    }
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
              onSelectLanguage: (EnumLanguageSelection language) {
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
