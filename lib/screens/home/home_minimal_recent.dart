import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/animated_app_icon.dart';
import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/quotidian.dart';
import 'package:figstyle/utils/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:supercharged/supercharged.dart';

class HomeMinimalRecent extends StatefulWidget {
  @override
  _HomeMinimalRecentState createState() => _HomeMinimalRecentState();
}

class _HomeMinimalRecentState extends State<HomeMinimalRecent> {
  bool hasErrors = false;
  bool isFabVisible = false;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasNext = true;

  DocumentSnapshot lastFetchedDoc;

  final _scrollController = ScrollController();
  final recentLimit = 12;

  List<Quote> heroQuotes = [];
  List<Quote> quotes = [];

  Quotidian quotidian;

  ReactionDisposer langReaction;

  String lang = Language.en;

  @override
  void initState() {
    super.initState();
    initProps();
  }

  void initProps() {
    langReaction = autorun((reaction) async {
      lang = stateUser.lang;
      fetch();
    });
  }

  @override
  dispose() {
    langReaction?.reaction?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              foregroundColor: Colors.white,
              backgroundColor: stateColors.accent,
              child: Icon(Icons.arrow_upward),
              onPressed: () {
                _scrollController.animateTo(
                  0.0,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOut,
                );
              },
            )
          : null,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollNotif) {
          // FAB visibility
          if (scrollNotif.metrics.pixels < 50 && isFabVisible) {
            setState(() {
              isFabVisible = false;
            });
          } else if (scrollNotif.metrics.pixels > 50 && !isFabVisible) {
            setState(() {
              isFabVisible = true;
            });
          }

          // Load more scenario
          if (scrollNotif.metrics.pixels <
              scrollNotif.metrics.maxScrollExtent - 100.0) {
            return false;
          }

          if (hasNext && !isLoadingMore) {
            fetchMoreRecent();
          }

          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            DesktopAppBar(
              title: "fig.style",
              padding: const EdgeInsets.only(left: 65.0),
              onTapIconHeader: () {
                _scrollController.animateTo(
                  0,
                  duration: 250.milliseconds,
                  curve: Curves.decelerate,
                );
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 80.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  body(),
                ]),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                IconButton(
                    onPressed: () {
                      _scrollController.animateTo(
                        MediaQuery.of(context).size.height,
                        duration: 250.milliseconds,
                        curve: Curves.decelerate,
                      );
                    },
                    icon: Icon(Icons.arrow_downward)),
              ]),
            ),
            gridViewRecent(),
          ],
        ),
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return loadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (heroQuotes.length == 0) {
      return emptyView();
    }

    return heroCardsRow();
  }

  Widget loadingView() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 80.0,
        vertical: 40.0,
      ),
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          AnimatedAppIcon(
            size: 80.0,
          ),
          Opacity(
            opacity: 0.6,
            child: Text(
              'Loading...',
              style: TextStyle(
                fontSize: 30.0,
                // fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyView() {
    return Container(
      padding: const EdgeInsets.all(80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: 0.6,
                child: Text(
                  'Recent...',
                  style: TextStyle(
                    fontSize: 60.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: fetch,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "There's no recent quotes",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          Opacity(
            opacity: 0.6,
            child: Text(
              "Maybe your this language has been added recently",
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget errorView() {
    return Container(
      padding: const EdgeInsets.all(80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: 0.6,
                child: Text(
                  'Recent...',
                  style: TextStyle(
                    fontSize: 60.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: fetch,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "There was an error while loading",
                style: TextStyle(
                  fontSize: 26.0,
                ),
              ),
            ),
          ),
          Opacity(
            opacity: 0.6,
            child: Text(
              "Check your connection and try again.",
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget heroCardsRow() {
    final maxCount =
        MediaQuery.of(context).size.width < 1000.0 ? 2 : heroQuotes.length;

    return Observer(builder: (context) {
      final isConnected = stateUser.isUserConnected;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 1000.0,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 80.0,
                right: 80.0,
                top: 20.0,
                bottom: 80.0,
              ),
              child: Wrap(
                spacing: 40.0,
                runSpacing: 40.0,
                alignment: WrapAlignment.center,
                children:
                    heroQuotes.sublist(0, maxCount).mapIndexed((quote, index) {
                  if (index > 0) {
                    return QuoteRowWithActions(
                      quote: quote,
                      elevation: 4.0,
                      showAuthor: true,
                      showBorder: true,
                      cardHeight: 400.0,
                      cardWidth: 250.0,
                      padding: const EdgeInsets.all(30.0),
                      isConnected: isConnected,
                      componentType: ItemComponentType.verticalCard,
                    );
                  }

                  return Column(
                    children: [
                      QuoteRowWithActions(
                        quote: quote,
                        elevation: 4.0,
                        showAuthor: true,
                        showBorder: true,
                        cardHeight: 400.0,
                        cardWidth: 250.0,
                        padding: const EdgeInsets.all(30.0),
                        isConnected: isConnected,
                        componentType: ItemComponentType.verticalCard,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Opacity(
                          opacity: 0.6,
                          child: Text(
                            "This is the quote of the day",
                            style: TextStyle(
                              color: stateColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget gridViewRecent() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 80.0),
      sliver: Observer(
        builder: (context) {
          final isConnected = stateUser.isUserConnected;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return QuoteRowWithActions(
                  quote: quotes.elementAt(index),
                  elevation: 4.0,
                  showAuthor: true,
                  cardHeight: 250.0,
                  cardWidth: 250.0,
                  padding: const EdgeInsets.all(30.0),
                  isConnected: isConnected,
                  componentType: ItemComponentType.card,
                );
              },
              childCount: quotes.length,
            ),
          );
        },
      ),
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
      heroQuotes.clear();
    });

    await fetchQuotidians();
    setState(() => isLoading = false);
    fetchRecent();
  }

  /// Fetch last 3 quotidians.
  Future fetchQuotidians() async {
    final today = DateTime.now();
    final yesterday = today.subtract(1.days);
    final twoDaysAgo = yesterday.subtract(1.days);

    await fetchQuotidian(today);
    await fetchQuotidian(yesterday);
    await fetchQuotidian(twoDaysAgo);
  }

  /// Fetch a single quotidian based on the date parameter.
  Future fetchQuotidian(DateTime date) async {
    String month = date.month.toString();
    month = month.length == 2 ? month : '0$month';

    String day = date.day.toString();
    day = day.length == 2 ? day : '0$day';

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotidians')
          .doc('${date.year}:$month:$day:${lang.toLowerCase()}')
          .get();

      if (!snapshot.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      setState(() {
        quotidian = Quotidian.fromJSON(snapshot.data());
        heroQuotes.add(quotidian.quote);
      });
    } catch (error, stackTrace) {
      debugPrint('error => $error');
      debugPrint(stackTrace.toString());
    }
  }

  Future fetchRecent() async {
    setState(() {
      quotes.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: true)
          .limit(recentLimit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() => hasNext = false);
        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        lastFetchedDoc = snapshot.docs.last;
        hasNext = snapshot.docs.length == recentLimit;
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future fetchMoreRecent() async {
    if (!hasNext || lastFetchedDoc == null || isLoadingMore) {
      return;
    }

    isLoadingMore = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastFetchedDoc)
          .limit(recentLimit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isLoadingMore = false;
          hasNext = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        isLoadingMore = false;
        lastFetchedDoc = snapshot.docs.last;
        hasNext = snapshot.docs.length == recentLimit;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingMore = false;
      });
    }
  }
}
