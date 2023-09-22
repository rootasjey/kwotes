import "dart:math";

import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/mini_card.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/random_quote_document.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";
import "package:super_context_menu/super_context_menu.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with UiLoggy {
  EnumPageState _pageState = EnumPageState.idle;

  @override
  void initState() {
    super.initState();
    if (NavigationStateHelper.randomQuotes.isEmpty) {
      fetchRandomQuotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "loading".tr(),
      );
    }

    if (NavigationStateHelper.randomQuotes.isEmpty) {
      return EmptyView.scaffold(
        context,
        description: "empty_quote.home".tr(),
      );
    }

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    return BasicShortcuts(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const ApplicationBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 48.0,
                vertical: 24.0,
              ),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 64.0,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final Quote quote = NavigationStateHelper.randomQuotes[index];
                  return ContextMenuWidget(
                    child: TinyCard(
                      quote: quote,
                      onTap: onTapQuote,
                    ),
                    menuProvider: (MenuRequest request) {
                      return Menu(
                        children: [
                          MenuAction(
                            title: "quote.copy.name".tr(),
                            image: MenuImage.icon(TablerIcons.copy),
                            callback: () => onCopyQuote(quote),
                          ),
                          MenuAction(
                            title: "quote.copy.url".tr(),
                            image: MenuImage.icon(TablerIcons.link),
                            callback: () => onCopyQuoteUrl(quote),
                          ),
                        ],
                      );
                    },
                  );
                },
                itemCount: NavigationStateHelper.randomQuotes.length,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 48.0,
                vertical: 24.0,
              ),
              sliver: SliverList.list(children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    onPressed: onTapOpenRandomQuote,
                    style: TextButton.styleFrom(
                      foregroundColor: foregroundColor?.withOpacity(0.6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(TablerIcons.hand_finger),
                        ),
                        Text(
                          "quote.open_random".tr(),
                          style: Utils.calligraphy.body(
                            textStyle: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    onPressed: fetchRandomQuotes,
                    style: TextButton.styleFrom(
                      foregroundColor: foregroundColor?.withOpacity(0.6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(TablerIcons.arrows_shuffle),
                        ),
                        Text(
                          "quote.shuffle".tr(),
                          style: Utils.calligraphy.body(
                            textStyle: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SignalBuilder(
                    signal: userFirestoreSignal,
                    builder: (
                      BuildContext context,
                      UserFirestore userFirestore,
                      Widget? child,
                    ) {
                      if (!userFirestore.rights.canProposeQuote) {
                        return Container();
                      }

                      return Align(
                        alignment: Alignment.topLeft,
                        child: TextButton(
                          onPressed: () {
                            Beamer.of(context).beamToNamed(
                              "/dashboard/add-quote",
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: foregroundColor?.withOpacity(0.6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(TablerIcons.plus),
                              ),
                              Text(
                                "quote.add.a".tr(),
                                style: Utils.calligraphy.body(
                                  textStyle: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getLanguage() async {
    final String languageCode = await Utils.vault.getLanguage();
    if (Utils.linguistic.available().contains(languageCode)) {
      return languageCode;
    }

    return "en";
  }

  void fetchRandomQuotes() async {
    setState(() {
      _pageState = EnumPageState.loading;
      NavigationStateHelper.randomQuotes.clear();
    });

    try {
      final String language = await getLanguage();
      final QuerySnapMap randomSnapshot = await FirebaseFirestore.instance
          .collection("randoms")
          .where("language", isEqualTo: language)
          .limit(1)
          .get();

      if (randomSnapshot.size == 0) {
        setState(() {
          _pageState = EnumPageState.idle;
        });
        return;
      }

      final QueryDocSnapMap randomDocSnap = randomSnapshot.docs.first;
      final Json map = randomDocSnap.data();
      map["id"] = randomDocSnap.id;

      final RandomQuoteDocument randomQuoteDoc =
          RandomQuoteDocument.fromMap(map);
      randomQuoteDoc.items.shuffle();
      final List<String> items = randomQuoteDoc.items.take(40).toList();

      for (final String quoteId in items) {
        final DocumentSnapshotMap quoteDoc = await FirebaseFirestore.instance
            .collection("quotes")
            .doc(quoteId)
            .get();

        final Json? data = quoteDoc.data();
        if (data == null) {
          continue;
        }

        data["id"] = quoteDoc.id;
        final Quote quote = Quote.fromMap(data);
        // final Author? author = await fetchAuthor(quote.author.id);
        // final Reference? reference = await fetchReference(quote.reference.id);
        // quotes.add(quote.copyWith(author: author, reference: reference));
        NavigationStateHelper.randomQuotes.add(quote);
      }

      setState(() {
        _pageState = EnumPageState.idle;
      });
    } catch (error) {
      loggy.error(error);
      setState(() {
        _pageState = EnumPageState.idle;
      });
    }
  }

  Future<Author?> fetchAuthor(String authorId) async {
    if (authorId.isEmpty) {
      return null;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("authors")
          .doc(authorId)
          .get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }

      data["id"] = snapshot.id;
      return Author.fromMap(data);
    } catch (error) {
      loggy.error(error);
      return null;
    }
  }

  Future<Reference?> fetchReference(String referenceId) async {
    if (referenceId.isEmpty) {
      return null;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("references")
          .doc(referenceId)
          .get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }

      data["id"] = snapshot.id;
      return Reference.fromMap(data);
    } catch (error) {
      loggy.error(error);
      return null;
    }
  }

  void onCopyQuote(Quote quote) {
    QuoteActions.copyQuote(quote);
  }

  void onCopyQuoteUrl(Quote quote) {
    Clipboard.setData(ClipboardData(text: "${Constants.quoteUrl}/${quote.id}"));
  }

  void onTapQuote(Quote quote) {
    NavigationStateHelper.quote = quote;
    context.beamToNamed(
      HomeLocation.quoteRoute.replaceFirst(":quoteId", quote.id),
      data: {
        "quoteId": quote.id,
      },
      routeState: {
        "quoteId": quote.id,
      },
    );
  }

  void onTapOpenRandomQuote() {
    final List<Quote> quotes = NavigationStateHelper.randomQuotes;

    onTapQuote(
      quotes.elementAt(Random().nextInt(quotes.length)),
    );
  }
}
