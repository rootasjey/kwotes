import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:firebase_auth/firebase_auth.dart";
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
import "package:kwotes/screens/published/published_page_body.dart";
import "package:kwotes/screens/published/published_page_header.dart";
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
import "package:kwotes/types/user/user_auth.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:kwotes/types/user/user_rights.dart";
import "package:loggy/loggy.dart";
import "package:screenshot/screenshot.dart";
import "package:text_wrap_auto_size/solution.dart";

class PublishedPage extends StatefulWidget {
  const PublishedPage({super.key});

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

  /// Selected tab index (owned | all).
  EnumDataOwnership _selectedOwnership = EnumDataOwnership.owned;

  /// Current selected language to fetch published quotes.
  EnumLanguageSelection _selectedLanguage = EnumLanguageSelection.all;

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
    initProps().then((_) => fetch());
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
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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
                isMobileSize: isMobileSize,
                toolbarHeight: isMobileSize ? 200.0 : 282.0,
                children: [
                  PublishedPageHeader(
                    selectedColor: chipSelectedColor,
                    onSelectedOwnership: onSelectedOnwership,
                    onSelectLanguage: onSelectedLanguage,
                    onTapTitle: onTapTitle,
                    selectedLanguage: _selectedLanguage,
                    selectedOwnership: _selectedOwnership,
                    show: NavigationStateHelper.showHeaderPageOptions,
                    isMobileSize: isMobileSize,
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

    if (_selectedOwnership == EnumDataOwnership.owned) {
      baseQuery = baseQuery.where("user.id", isEqualTo: userId);
    }

    if (_selectedLanguage != EnumLanguageSelection.all) {
      baseQuery = baseQuery.where(
        "language",
        isEqualTo: _selectedLanguage.name,
      );
    }

    if (lastDocument == null) {
      return baseQuery;
    }

    return baseQuery.startAfterDocument(lastDocument);
  }

  /// Fetch data.
  void fetch() async {
    final UserAuth? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    _pageState = _lastDocument == null
        ? EnumPageState.loading
        : EnumPageState.loadingMore;

    final String userId = currentUser.uid;

    try {
      final QueryMap query = getQuery(userId);
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
    _selectedLanguage = await Utils.vault.getPageLanguage();
    _selectedOwnership = await Utils.vault.getDataOwnership();

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

    if (_selectedLanguage != EnumLanguageSelection.all &&
        _selectedLanguage.name != language) {
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
      loggy.info("will delete quote: ${quote.id}");

      if (!mounted) return;
      Utils.graphic.showSnackbarWithCustomText(
        context,
        duration: const Duration(seconds: 10),
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
                loggy.info("reverse add quote: ${quote.id}");
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
    if (_selectedLanguage == language) {
      return;
    }

    setState(() {
      _selectedLanguage = language;
      _quotes.clear();
      _lastDocument = null;
    });

    Utils.vault.setPageLanguage(language);
    fetch();
  }

  /// Callback to filter published quotes (owned | all).
  void onSelectedOnwership(EnumDataOwnership ownership) {
    if (_selectedOwnership == ownership) {
      return;
    }

    setState(() {
      _selectedOwnership = ownership;
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
}
