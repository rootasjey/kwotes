import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
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
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

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
                childTitle: FavouritesPageHeader(
                  isMobileSize: isMobileSize,
                ),
              ),
              FavouritesPageBody(
                animateList: _animateList,
                isMobileSize: isMobileSize,
                pageState: _pageState,
                quotes: _quotes,
                onCopy: onCopy,
                onRemove: onRemove,
                onTap: onTap,
              ),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 90.0),
                sliver: SliverToBoxAdapter(),
              ),
            ],
          ),
        ),
      ),
    );
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

  /// Copy a quote's.
  void onCopy(Quote quote) {
    Clipboard.setData(ClipboardData(text: quote.name));
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
    context.beamToNamed(
      DashboardContentLocation.favouritesQuoteRoute.replaceFirst(
        ":quoteId",
        quote.id,
      ),
    );
  }

  void initProps() async {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _animateList = false;
      });
    });
  }
}
