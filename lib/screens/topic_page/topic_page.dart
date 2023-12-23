import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/search/search_quote_text.dart";
import "package:kwotes/screens/topic_page/topic_page_header.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:loggy/loggy.dart";
import "package:super_context_menu/super_context_menu.dart";

class TopicPage extends StatefulWidget {
  const TopicPage({
    super.key,
    required this.topic,
  });

  /// Topic name.
  /// The page will fetch all related quotes.
  final String topic;

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> with UiLoggy {
  /// Fetch order.
  final bool _descending = true;

  /// Whether there is a next page.
  bool _hasMoreResults = true;

  /// Last fetched document.
  QueryDocSnapMap? _lastDocument;

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Quote amount to fetch per page.
  final int _limit = 12;

  /// List of quotes.
  final List<Quote> _quotes = [];

  /// Page scroll controller (used to fetch more data).
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchQuotes();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pageState == EnumPageState.loading) {
      return LoadingView.scaffold();
    }

    if (_quotes.isEmpty) {
      return EmptyView.scaffold(
        context,
        title: "empty_quote.home".tr(),
      );
    }

    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final EdgeInsets bodyPadding = isMobileSize
        ? const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
          )
        : const EdgeInsets.only(
            left: 48.0,
            right: 48.0,
          );

    return Focus(
      autofocus: true,
      child: Scaffold(
        body: ImprovedScrolling(
          onScroll: onScroll,
          scrollController: _pageScrollController,
          child: ScrollConfiguration(
            behavior: const CustomScrollBehavior(),
            child: CustomScrollView(
              controller: _pageScrollController,
              slivers: [
                TopicPageHeader(
                  topic: getTopic(),
                  onTapName: onTapTopicName,
                ),
                SliverPadding(
                  padding: bodyPadding,
                  sliver: SliverList.builder(
                    itemBuilder: (BuildContext context, int index) {
                      final Quote quote = _quotes[index];
                      return SearchQuoteText(
                        quote: quote,
                        onTapQuote: onTapQuote,
                        // onDoubleTapQuote: onDoubleTapQuote,
                        tiny: isMobileSize,
                        margin: const EdgeInsets.symmetric(
                          vertical: 12.0,
                        ),
                        quoteMenuProvider: (MenuRequest menuRequest) =>
                            ContextMenuComponents.quoteMenuProvider(
                          context,
                          quote: quote,
                        ),
                      );
                    },
                    itemCount: _quotes.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getLanguage() async {
    final EnumLanguageSelection savedLanguage = await Utils.vault.getLanguage();
    if (Utils.linguistic.available().contains(savedLanguage)) {
      return savedLanguage.name;
    }

    return "en";
  }

  /// Return firebase query.
  QueryMap getQuery({String language = "en"}) {
    final QueryDocSnapMap? lastDocument = _lastDocument;

    final String topic = getTopic();

    final QueryMap query = FirebaseFirestore.instance
        .collection("quotes")
        .where("topics.$topic", isEqualTo: true)
        .where("language", isEqualTo: language)
        .orderBy("created_at", descending: _descending)
        .limit(_limit);

    if (lastDocument == null) {
      return query;
    }

    return query.startAfterDocument(lastDocument);
  }

  String getTopic() {
    return widget.topic != HomeContentLocation.topicRoute.split("/").last
        ? widget.topic
        : NavigationStateHelper.lastTopicName;
  }

  /// Fetch quotes.
  void fetchQuotes() async {
    setState(() {
      _pageState = _lastDocument != null
          ? EnumPageState.loadingMore
          : EnumPageState.loading;
    });

    try {
      final String language = await getLanguage();
      final QueryMap query = getQuery(language: language);
      final QuerySnapMap snapshot = await query.get();

      if (snapshot.size == 0) {
        return;
      }

      for (final DocumentSnapshotMap doc in snapshot.docs) {
        final Json? data = doc.data();

        if (data == null) {
          continue;
        }

        data["id"] = doc.id;
        final Quote quote = Quote.fromMap(data);
        _quotes.add(quote);
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _hasMoreResults = snapshot.size == _limit;
        _lastDocument = snapshot.docs.last;
      });
    } catch (error) {
      loggy.error(error);
      setState(() {
        _pageState = EnumPageState.idle;
      });
    }
  }

  /// On double tap quote.
  void onDoubleTapQuote(Quote quote) {
    QuoteActions.copyQuote(quote);

    Utils.graphic.showSnackbar(
      context,
      message: "quote.copy.success.name".tr(),
    );
  }

  void onTapQuote(Quote quote) {
    NavigationStateHelper.lastTopicName = widget.topic;
    Beamer.of(context).beamToNamed(
      HomeContentLocation.topicQuoteRoute.replaceFirst(":quoteId", quote.id),
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

    if (_pageScrollController.position.maxScrollExtent - offset > 200) {
      return;
    }

    if (_pageScrollController.position.maxScrollExtent - offset <= 200) {
      fetchQuotes();
    }
  }

  void onTapTopicName() {
    _pageScrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.decelerate,
    );
  }
}
