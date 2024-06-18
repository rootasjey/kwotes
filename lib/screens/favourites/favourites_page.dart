import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/favourites/favourites_page_header.dart";
import "package:kwotes/screens/favourites/favourites_page_body.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/firestore/query_snapshot_stream_subscription.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";
import "package:screenshot/screenshot.dart";
import "package:text_wrap_auto_size/solution.dart";
import "package:wave_divider/wave_divider.dart";

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> with UiLoggy {
  /// Animate list's items if true.
  bool _animateList = true;

  /// True if more results can be loaded.
  bool _hasNextPage = true;

  /// True if the order is the most recent first.
  final bool _descending = true;

  /// Page's state.
  EnumPageState _pageState = EnumPageState.idle;

  /// Last document.
  QueryDocSnapMap? _lastDocument;

  /// List of quotes in favourites.
  final List<Quote> _quotes = [];

  /// Result count limit.
  final int _limit = 20;

  /// Stream subscription for favourite quotes.
  QuerySnapshotStreamSubscription? _quoteSub;

  /// Screenshot controller (to share quote image).
  final ScreenshotController _screenshotController = ScreenshotController();

  /// Page's scroll controller.
  final ScrollController _pageScrollController = ScrollController();

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

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
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                isMobileSize: isMobileSize,
                toolbarHeight: isMobileSize ? 140.0 : 242.0,
                children: [
                  FavouritesPageHeader(
                    isMobileSize: isMobileSize,
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: const WaveDivider(
                  padding: EdgeInsets.symmetric(
                    vertical: 24.0,
                  ),
                ).animate().fadeIn(
                      duration: const Duration(milliseconds: 1500),
                      begin: 0.0,
                    ),
              ),
              SignalBuilder(
                signal: signalUserFirestore,
                builder: (context, userFirestore, child) {
                  return FavouritesPageBody(
                    animateList: _animateList,
                    isDark: isDark,
                    isMobileSize: isMobileSize,
                    pageState: _pageState,
                    quotes: _quotes,
                    onCopy: onCopyQuote,
                    onCopyUrl: onCopyQuoteUrl,
                    onOpenAddToList: onOpenAddToList,
                    onRemove: onRemove,
                    onTap: onTap,
                    onDoubleTap: onDoubleTap,
                    onShareImage: onShareImage,
                    onShareLink: onShareLink,
                    onShareText: onShareText,
                    userId: userFirestore.id,
                  );
                },
              ),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 90.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fetch quotes from firebase.
  void fetch() async {
    final Signal<UserFirestore> currentUser =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (currentUser.value.id.isEmpty) {
      return;
    }

    _pageState = _lastDocument == null
        ? EnumPageState.loading
        : EnumPageState.loadingMore;

    try {
      final QueryMap query = getQuery(currentUser.value.id);
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

  /// Handle added favourite quote.
  void handleAddedFavourite(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) return;

    data["id"] = doc.id;
    final Quote quote = Quote.fromMap(data);
    setState(() => _quotes.insert(0, quote));
  }

  /// Handle removed favourite quote.
  void handleRemovedFavourite(DocumentSnapshotMap doc) {
    setState(() => _quotes.removeWhere((Quote x) => x.id == doc.id));
  }

  /// Listen to favourite quote changes.
  void listenToQuoteChanges(QueryMap query) {
    _quoteSub?.cancel();
    _quoteSub = query.snapshots().skip(1).listen((QuerySnapMap snapshot) {
      for (final docChange in snapshot.docChanges) {
        switch (docChange.type) {
          case DocumentChangeType.added:
            handleAddedFavourite(docChange.doc);
            break;
          case DocumentChangeType.removed:
            handleRemovedFavourite(docChange.doc);
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

  /// Return firebase query.
  QueryMap getQuery(String userId) {
    final QueryDocSnapMap? lastDocument = _lastDocument;

    if (lastDocument == null) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("favourites")
          .orderBy("created_at", descending: _descending)
          .limit(_limit);
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("favourites")
        .orderBy("created_at", descending: _descending)
        .limit(_limit)
        .startAfterDocument(lastDocument);
  }

  void initProps() async {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _animateList = false);
    });
  }

  /// Copy a quote's.
  void onCopyQuote(Quote quote) {
    QuoteActions.copyQuote(quote);
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyQuoteSnackbar(context, isMobileSize: isMobileSize);
  }

  /// Copy a quote's url.
  void onCopyQuoteUrl(Quote quote) {
    QuoteActions.copyQuoteUrl(quote);
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyQuoteLinkSnackbar(
      context,
      isMobileSize: isMobileSize,
    );
  }

  /// Copy quote and show snackbar.
  void onDoubleTap(Quote quote) {
    QuoteActions.copyQuote(quote);

    Utils.graphic.showSnackbar(
      context,
      message: "quote.copy.success.name".tr(),
    );
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

  /// Remove a quote from favourites.
  void onRemove(Quote quote) async {
    final int index = _quotes.indexOf(quote);

    setState(() {
      _quotes.remove(quote);
    });

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (userFirestoreSignal.value.id.isEmpty) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userFirestoreSignal.value.id)
          .collection("favourites")
          .doc(quote.id)
          .delete();
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;

      setState(() {
        _quotes.insert(index, quote);
      });

      Utils.graphic.showSnackbar(
        context,
        message: "quote.favourite.remove.failed".tr(),
      );
    }
  }

  /// Callback fired when the user scrolls.
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

  /// Navigate to quote page when a quote is tapped.
  void onTap(Quote quote) {
    NavigationStateHelper.quote = quote;
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.favouritesQuoteRoute.replaceFirst(
        ":quoteId",
        quote.id,
      ),
    );
  }

  void onShareImage(Quote quote) {
    final Size windowSize = MediaQuery.of(context).size;
    final Solution textWrapSolution = Utils.graphic.getTextSolution(
      quote: quote,
      windowSize: windowSize,
      style: Utils.calligraphy.body(),
    );

    Utils.graphic.onOpenShareImage(
      context,
      mounted: mounted,
      quote: quote,
      screenshotController: _screenshotController,
      textWrapSolution: textWrapSolution,
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
}
