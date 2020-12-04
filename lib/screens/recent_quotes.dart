import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/actions/users.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/components/sliver_loading_view.dart';
import 'package:figstyle/components/empty_content.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class RecentQuotes extends StatefulWidget {
  final bool showNavBackIcon;

  RecentQuotes({this.showNavBackIcon = true});

  @override
  RecentQuotesState createState() => RecentQuotesState();
}

class RecentQuotesState extends State<RecentQuotes> {
  bool canManage = false;
  bool descending = true;
  bool hasNext = true;
  bool hasErrors = false;
  bool isConnected = false;
  bool isFabVisible = false;
  bool isLoading = false;
  bool isLoadingMore = false;

  final pageRoute = QuotesRoute;

  final limit = 30;
  List<Quote> quotes = [];
  String lang = 'en';

  var itemsLayout = ItemsLayout.list;
  DocumentSnapshot lastDoc;
  var scrollController = ScrollController();

  @override
  initState() {
    super.initState();
    initProps();
    fetch();
  }

  void initProps() async {
    lang = appStorage.getPageLang(pageRoute: pageRoute);
    descending = appStorage.getPageOrder(pageRoute: pageRoute);
    itemsLayout = appStorage.getItemsStyle(pageRoute);

    canManage = await canUserManage();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              onPressed: () {
                scrollController.animateTo(
                  0.0,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: stateColors.primary,
              foregroundColor: Colors.white,
              child: Icon(Icons.arrow_upward),
            )
          : null,
      body: RefreshIndicator(
          onRefresh: () async {
            await fetch();
            return null;
          },
          child: NotificationListener<ScrollNotification>(
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

              if (scrollNotif.metrics.pixels <
                  scrollNotif.metrics.maxScrollExtent) {
                return false;
              }

              if (hasNext && !isLoadingMore) {
                fetchMore();
              }

              return false;
            },
            child: CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
                appBar(),
                gridHeroCard(),
                body(),
              ],
            ),
          )),
    );
  }

  Widget appBar() {
    final width = MediaQuery.of(context).size.width;
    double titleLeftPadding = 70.0;
    double bottomContentLeftPadding = 94.0;

    if (width < Constants.maxMobileWidth) {
      titleLeftPadding = 0.0;
      bottomContentLeftPadding = 24.0;
    }

    return PageAppBar(
      textTitle: 'Recent',
      titlePadding: EdgeInsets.only(
        left: titleLeftPadding,
        top: 24.0,
      ),
      bottomPadding: EdgeInsets.only(
        left: bottomContentLeftPadding,
        bottom: 10.0,
      ),
      onTitlePressed: () {
        scrollController.animateTo(
          0,
          duration: 250.milliseconds,
          curve: Curves.easeIn,
        );
      },
      descending: descending,
      onDescendingChanged: (newDescending) {
        if (descending == newDescending) {
          return;
        }

        descending = newDescending;
        fetch();

        appStorage.setPageOrder(
          descending: newDescending,
          pageRoute: pageRoute,
        );
      },
      lang: lang,
      onLangChanged: (String newLang) {
        lang = newLang;
        appStorage.setPageLang(lang: lang, pageRoute: pageRoute);
        fetch();
      },
      itemsLayout: itemsLayout,
      onItemsLayoutSelected: (selectedLayout) {
        if (selectedLayout == itemsLayout) {
          return;
        }

        setState(() {
          itemsLayout = selectedLayout;
        });

        appStorage.saveItemsStyle(
          pageRoute: pageRoute,
          style: selectedLayout,
        );
      },
    );
  }

  Widget body() {
    if (isLoading) {
      return SliverLoadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (quotes.length == 0) {
      return emptyView();
    }

    final Widget sliver =
        itemsLayout == ItemsLayout.list ? listView() : gridView();

    return SliverPadding(
      padding: const EdgeInsets.only(top: 24.0),
      sliver: sliver,
    );
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        FadeInY(
          delay: 2.0,
          beginY: 50.0,
          child: EmptyContent(
            icon: Opacity(
              opacity: .8,
              child: Icon(
                Icons.sentiment_neutral,
                size: 120.0,
                color: Color(0xFFFF005C),
              ),
            ),
            title: "There's no recent quotes",
            subtitle: "Maybe your this language has been added recently",
            onRefresh: () => fetch(),
          ),
        ),
      ]),
    );
  }

  Widget errorView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 150.0),
          child: ErrorContainer(
            onRefresh: () => fetch(),
          ),
        ),
      ]),
    );
  }

  Widget sliverContiner() {
    return SliverPadding(padding: EdgeInsets.zero);
  }

  Widget gridHeroCard() {
    if (itemsLayout == ItemsLayout.list) {
      return sliverContiner();
    }

    if (!isLoading && hasErrors) {
      return sliverContiner();
    }

    if (quotes.isEmpty) {
      return sliverContiner();
    }

    final quote = quotes.first;
    final index = 0;

    return Observer(
      builder: (context) {
        return SliverPadding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              QuoteRowWithActions(
                quote: quote,
                isConnected: userState.isUserConnected,
                canManage: canManage,
                quoteFontSize: 42.0,
                cardWidth: 250.0,
                maxLines: null,
                overflow: TextOverflow.visible,
                componentType: ItemComponentType.card,
                elevation: Constants.cardElevation,
                padding: const EdgeInsets.all(25.0),
                onBeforeDeletePubQuote: () {
                  setState(() {
                    quotes.removeAt(index);
                  });
                },
                onAfterDeletePubQuote: (bool success) {
                  if (!success) {
                    quotes.insert(index, quote);

                    showSnack(
                      context: context,
                      message: "Couldn't delete the temporary quote.",
                      type: SnackType.error,
                    );
                  }
                },
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget gridView() {
    return Observer(builder: (context) {
      final isConnected = userState.isUserConnected;

      return SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300.0,
            mainAxisSpacing: 20.0,
            crossAxisSpacing: 20.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final quote = quotes.elementAt(index);

              return QuoteRowWithActions(
                quote: quote,
                canManage: canManage,
                isConnected: isConnected,
                elevation: Constants.cardElevation,
                padding: const EdgeInsets.all(20.0),
                componentType: ItemComponentType.card,
                onBeforeDeletePubQuote: () {
                  setState(() {
                    quotes.removeAt(index);
                  });
                },
                onAfterDeletePubQuote: (bool success) {
                  if (!success) {
                    quotes.insert(index, quote);

                    showSnack(
                      context: context,
                      message: "Couldn't delete the temporary quote.",
                      type: SnackType.error,
                    );
                  }
                },
              );
            },
            childCount: quotes.length,
          ),
        ),
      );
    });
  }

  Widget listView() {
    final width = MediaQuery.of(context).size.width;
    double horizontal = 0.0;
    double heroQuoteFontSize = 42.0;
    double normalQuoteFontSize = 18.0;

    if (width > Constants.maxMobileWidth) {
      heroQuoteFontSize = 92.0;
      horizontal = 70.0;
      normalQuoteFontSize = 26.0;
    }

    return Observer(builder: (context) {
      final isConnected = userState.isUserConnected;

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final quote = quotes.elementAt(index);

            double quoteFontSize = normalQuoteFontSize;

            if (index == 0) {
              quoteFontSize = heroQuoteFontSize;
            }

            return QuoteRowWithActions(
              quote: quote,
              canManage: canManage,
              isConnected: isConnected,
              key: ObjectKey(index),
              useSwipeActions: true,
              quoteFontSize: quoteFontSize,
              color: stateColors.appBackground,
              padding: EdgeInsets.symmetric(
                horizontal: horizontal,
              ),
              quotePageType: QuotePageType.published,
            );
          },
          childCount: quotes.length,
        ),
      );
    });
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
      quotes.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      lastDoc = snapshot.docs.last;

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchMore() async {
    if (lastDoc == null) {
      return;
    }
    isLoadingMore = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .startAfterDocument(lastDoc)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      lastDoc = snapshot.docs.last;

      setState(() {
        isLoadingMore = false;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingMore = false;
      });
    }
  }
}
