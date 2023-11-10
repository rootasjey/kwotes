import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/home/reference_poster.dart";
import "package:kwotes/screens/search/search_quote_text.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";
import "package:loggy/loggy.dart";

class ReferenceQuotesPage extends StatefulWidget {
  const ReferenceQuotesPage({
    super.key,
    required this.referenceId,
  });

  final String referenceId;

  @override
  State<ReferenceQuotesPage> createState() => _ReferenceQuotesPageState();
}

class _ReferenceQuotesPageState extends State<ReferenceQuotesPage>
    with UiLoggy {
  /// Reference's data.
  Reference _reference = Reference.empty();

  /// Data list order.
  final bool _descending = true;

  /// True if more results can be loaded.
  /// This is true by default.
  bool _hasMoreResults = true;

  /// Page's state (e.g. idle, loading, ...).
  EnumPageState _pageState = EnumPageState.idle;

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
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (_pageState == EnumPageState.loading) {
      return LoadingView.scaffold();
    }

    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    // final Object imageProvider = _reference.urls.image.isNotEmpty
    //     ? NetworkImage(_reference.urls.image)
    //     : const AssetImage("assets/images/reference-picture-0.png");

    return Scaffold(
      body: ImprovedScrolling(
        onScroll: onScroll,
        scrollController: _pageScrollController,
        child: ScrollConfiguration(
          behavior: const CustomScrollBehavior(),
          child: CustomScrollView(
            controller: _pageScrollController,
            slivers: [
              PageAppBar(
                axis: Axis.horizontal,
                toolbarHeight: 120.0,
                children: [
                  SizedBox(
                    height: 40.0,
                    width: 40.0,
                    child: ReferencePoster(
                      reference: _reference,
                      accentColor: Constants.colors.getRandomPastel(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _reference.name,
                      style: Utils.calligraphy.title(
                        textStyle: TextStyle(
                          fontSize: isMobileSize ? 32.0 : 42.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: 24.0,
                  left: 24.0,
                  right: 24.0,
                  bottom: 54.0,
                ),
                sliver: SliverList.builder(
                  itemBuilder: (BuildContext context, int index) {
                    final Quote quote = _quotes[index];
                    return SearchQuoteText(
                      quote: quote,
                      onTapQuote: onTapQuote,
                      tiny: isMobileSize,
                      margin: const EdgeInsets.only(bottom: 16.0),
                    );
                  },
                  itemCount: _quotes.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fetch() async {
    if (widget.referenceId == NavigationStateHelper.reference.id) {
      _reference = NavigationStateHelper.reference;
      fetchQuotes();
      return;
    }

    setState(() => _pageState = EnumPageState.loading);

    await Future.any([
      fetchReference(),
      fetchQuotes(),
    ]);

    setState(() => _pageState = EnumPageState.idle);
  }

  Future<void> fetchReference() async {
    if (widget.referenceId.isEmpty) {
      return;
    }

    try {
      setState(() => _pageState = EnumPageState.loading);
      final DocumentSnapshotMap doc = await FirebaseFirestore.instance
          .collection("references")
          .doc(widget.referenceId)
          .get();

      if (!doc.exists) {
        return;
      }

      setState(() => _reference = Reference.fromMap(doc.data()));
    } catch (error) {
      loggy.error(error);
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  Future<void> fetchQuotes() async {
    if (widget.referenceId.isEmpty) {
      return;
    }

    try {
      setState(() => _pageState = EnumPageState.loading);

      final String language = await Utils.linguistic.getLanguage();
      final QueryMap query = getQuotesQuery(language: language);
      final QuerySnapMap snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
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

  QueryMap getQuotesQuery({String language = "en"}) {
    final QueryMap query = FirebaseFirestore.instance
        .collection("quotes")
        .where("reference.id", isEqualTo: widget.referenceId)
        .where("language", isEqualTo: language)
        .orderBy("created_at", descending: _descending)
        .limit(_limit);

    final QueryDocSnapMap? lastDocument = _lastDocument;
    if (lastDocument != null) {
      return query.startAfterDocument(lastDocument);
    }

    return query;
  }

  void onTapQuote(Quote quote) {
    Beamer.of(context).beamToNamed(
      HomeContentLocation.referenceQuoteRoute.replaceFirst(
        ":quoteId",
        quote.id,
      ),
    );
  }

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
}
