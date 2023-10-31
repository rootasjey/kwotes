import "dart:math";

import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/icons/app_icon.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/mini_card.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/author_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/reference_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/home/home_page_footer.dart";
import "package:kwotes/screens/home/home_page_hero_quote.dart";
import "package:kwotes/screens/home/latest_added_references.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
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
import "package:url_launcher/url_launcher.dart";

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.isMobileSize = false,
  });

  /// Adapt user interface to small screens.
  final bool isMobileSize;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with UiLoggy {
  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Quote amount to fetch.
  int _maxQuoteCount = 40;

  /// Amount of authors to fetch.
  final int _maxAuthorCount = 3;

  /// Amount of references to fetch.
  final int _maxReferenceCount = 3;

  @override
  void initState() {
    super.initState();

    if (widget.isMobileSize) {
      _maxQuoteCount = 20;
    }

    if (NavigationStateHelper.randomQuotes.isEmpty) {
      fetchRandomQuotes();
    }

    if (NavigationStateHelper.latestAddedReferences.isEmpty) {
      fetchLatestAddedReferences();
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

    final Size screenSize = MediaQuery.of(context).size;

    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6);

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final Color randomColor = Constants.colors.getRandomFromPalette();

    return BasicShortcuts(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: fetchRandomQuotes,
          backgroundColor: randomColor,
          foregroundColor: randomColor.computeLuminance() < 0.5
              ? Colors.white
              : Colors.black,
          tooltip: "quote.shuffle".tr(),
          child: const Icon(TablerIcons.arrows_shuffle),
        ),
        body: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.topLeft,
                child: AppIcon(
                  margin: EdgeInsets.only(top: 42.0, left: 42.0),
                ),
              ),
            ),
            HomePageHeroQuote(
              randomQuotes: NavigationStateHelper.randomQuotes,
              textColor: iconColor,
              onTapAuthor: onTapAuthor,
              onTapQuote: onTapQuote,
            ),
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
                      screenSize: screenSize,
                      entranceDelay: Duration(
                        milliseconds: Random().nextInt(120),
                      ),
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
            LatestAddedReferences(
              references: NavigationStateHelper.latestAddedReferences,
              onTapReference: onTapReference,
              textColor: iconColor,
            ),
            HomePageFooter(
              iconColor: iconColor,
              isMobileSize: widget.isMobileSize,
              onAddQuote: onAddQuote,
              onFetchRandomQuotes: fetchRandomQuotes,
              onTapGitHub: onTapGitHub,
              onTapSettings: onTapSettings,
              onTapOpenRandomQuote: onTapOpenRandomQuote,
              userFirestoreSignal: userFirestoreSignal,
            ),
          ],
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

  /// Fetches latest added authors.
  void fetchLatestAddedAuthors() async {
    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("authors")
          .orderBy("created_at", descending: true)
          .limit(_maxAuthorCount)
          .get();

      if (snapshot.size == 0) {
        return;
      }

      for (final DocumentSnapshotMap doc in snapshot.docs) {
        final Json? data = doc.data();
        if (data == null) {
          continue;
        }

        data["id"] = doc.id;
        NavigationStateHelper.latestAddedAuthors.add(Author.fromMap(data));
      }

      setState(() {});
    } catch (error) {
      loggy.error(error);
    }
  }

  /// Fetches latest added references.
  void fetchLatestAddedReferences() async {
    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("references")
          .orderBy("created_at", descending: true)
          .limit(_maxReferenceCount)
          .get();

      if (snapshot.size == 0) {
        return;
      }

      for (final DocumentSnapshotMap doc in snapshot.docs) {
        final Json? data = doc.data();
        if (data == null) {
          continue;
        }

        data["id"] = doc.id;
        final Reference reference = Reference.fromMap(data);
        NavigationStateHelper.latestAddedReferences.add(reference);
      }

      setState(() {});
    } catch (error) {
      loggy.error(error);
    }
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
      final List<String> items =
          randomQuoteDoc.items.take(_maxQuoteCount).toList();

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
      if (!mounted) return;
      setState(() {
        _pageState = EnumPageState.idle;
      });
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

  void onAddQuote() {
    NavigationStateHelper.quote = Quote.empty();
    Beamer.of(context).beamToNamed(
      "/dashboard/add-quote",
    );
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

  void onTapSettings() {
    Beamer.of(context).beamToNamed("settings");
  }

  void onTapGitHub() {
    launchUrl(Uri.parse(Constants.githubUrl));
  }

  void onTapAuthor(Author author) {
    Beamer.of(context).beamToNamed(
      AuthorLocation.route.replaceFirst(
        ":authorId",
        author.id,
      ),
    );
  }

  void onTapReference(Reference reference) {
    Beamer.of(context).beamToNamed(
      ReferenceLocation.route.replaceFirst(
        ":referenceId",
        reference.id,
      ),
    );
  }
}
