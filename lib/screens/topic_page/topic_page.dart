import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
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
import "package:kwotes/types/enums/enum_draft_quote_operation.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:kwotes/types/user/user_rights.dart";
import "package:loggy/loggy.dart";
import "package:screenshot/screenshot.dart";
import "package:super_context_menu/super_context_menu.dart";
import "package:text_wrap_auto_size/solution.dart";

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

  /// Screenshot controller.
  final ScreenshotController _screenshotController = ScreenshotController();

  /// Page scroll controller (used to fetch more data).
  final ScrollController _pageScrollController = ScrollController();

  /// Text wrap solution to calculate font size according to window size.
  Solution _textWrapSolution = Solution(
    const Text(""),
    const TextStyle(),
    const Size(0, 0),
    const Size(0, 0),
  );

  /// Collection name.
  final String _collectionName = "quotes";

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

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

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
                  isMobileSize: isMobileSize,
                  topic: getTopic(),
                  onTapName: onTapTopicName,
                ),
                SignalBuilder(
                  signal: signalUserFirestore,
                  builder: (context, userFirestore, child) {
                    final UserRights userRights = userFirestore.rights;
                    final bool isAdmin = userRights.canManageQuotes;
                    final onChangeLanguage =
                        isAdmin ? onChangeQuoteLanguage : null;

                    return SliverPadding(
                      padding: getBodyPadding(isMobileSize),
                      sliver: SliverList.separated(
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            height: 54.0,
                            color: isDark ? Colors.white12 : Colors.black12,
                          );
                        },
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
                            quoteMenuProvider: (MenuRequest menuRequest) {
                              return ContextMenuComponents.quoteMenuProvider(
                                context,
                                quote: quote,
                                onCopyQuote: onCopyQuote,
                                onCopyQuoteUrl: onCopyQuoteUrl,
                                onChangeLanguage: onChangeLanguage,
                                onDelete: isAdmin ? onDeleteQuote : null,
                                onEdit: isAdmin ? onEditQuote : null,
                                onShareImage: onShareImage,
                                onShareLink: onShareLink,
                                onShareText: onShareText,
                                userId: userFirestore.id,
                              );
                            },
                          );
                        },
                        itemCount: _quotes.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Return body padding.
  EdgeInsets getBodyPadding(bool isMobileSize) {
    if (isMobileSize) {
      return const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
      );
    }

    return const EdgeInsets.only(
      left: 48.0,
      right: 48.0,
    );
  }

  /// Get language from vault.
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
        .collection(_collectionName)
        .where("topics.$topic", isEqualTo: true)
        .where("language", isEqualTo: language)
        .orderBy("created_at", descending: _descending)
        .limit(_limit);

    if (lastDocument == null) {
      return query;
    }

    return query.startAfterDocument(lastDocument);
  }

  /// Retrieve topic name from navigation state.
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

    final String selectedLanguage = await getLanguage();
    if (selectedLanguage != language) {
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

  /// Callback to copy.
  void onCopyQuote(Quote quote) {
    QuoteActions.copyQuote(quote);
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyQuoteSnackbar(context, isMobileSize: isMobileSize);
  }

  /// Callback to copy quote url.
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
      HomeContentLocation.editQuoteRoute.replaceFirst(":quoteId", quote.id),
      data: {
        "quoteId": quote.id,
      },
    );
  }

  /// On double tap quote.
  void onDoubleTapQuote(Quote quote) {
    QuoteActions.copyQuote(quote);

    Utils.graphic.showSnackbar(
      context,
      message: "quote.copy.success.name".tr(),
    );
  }

  /// Navigate to quote page.
  void onTapQuote(Quote quote) {
    NavigationStateHelper.lastTopicName = widget.topic;
    Beamer.of(context).beamToNamed(
      HomeContentLocation.topicQuoteRoute
          .replaceFirst(":topicName", widget.topic)
          .replaceFirst(":quoteId", quote.id),
    );
  }

  /// Watch scrolling to fetch more data.
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

  /// Callback on tap topic name -> scroll to top.
  void onTapTopicName() {
    _pageScrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.decelerate,
    );
  }
}
