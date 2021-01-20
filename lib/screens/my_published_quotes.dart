import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/sliver_edge_padding.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/components/empty_content.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:supercharged/supercharged.dart';

class MyPublishedQuotes extends StatefulWidget {
  @override
  MyPublishedQuotesState createState() => MyPublishedQuotesState();
}

class MyPublishedQuotesState extends State<MyPublishedQuotes> {
  final bool descending = true;
  bool canManage = false;
  bool hasErrors = false;
  bool hasNext = true;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isFabVisible = false;

  DocumentSnapshot lastDoc;

  int limit = 30;
  ItemsLayout itemsLayout = ItemsLayout.list;

  List<Quote> quotes = [];

  ScrollController scrollController = ScrollController();

  String lang = 'en';
  final String pageRoute = RouteNames.PublishedQuotesRoute;

  @override
  initState() {
    super.initState();
    initProps();
    fetch();
    fetchPermissions();
  }

  void initProps() {
    lang = appStorage.getPageLang(pageRoute: pageRoute);
    itemsLayout = appStorage.getItemsStyle(pageRoute);
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

              // Load more scenario
              if (scrollNotif.metrics.pixels <
                  scrollNotif.metrics.maxScrollExtent) {
                return false;
              }

              if (hasNext && !isLoadingMore) {
                fetchMore();
              }

              return false;
            },
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (_) => CustomScrollView(
                    controller: scrollController,
                    slivers: <Widget>[
                      SliverEdgePadding(),
                      appBar(),
                      body(),
                    ],
                  ),
                )
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
      textTitle: 'Published',
      textSubTitle: 'Quotes published by you',
      titlePadding: EdgeInsets.only(
        left: titleLeftPadding,
      ),
      bottomPadding: EdgeInsets.only(
        left: bottomContentLeftPadding,
        bottom: 10.0,
      ),
      expandedHeight: 120.0,
      showNavBackIcon: true,
      onTitlePressed: () {
        scrollController.animateTo(
          0,
          duration: 250.milliseconds,
          curve: Curves.easeIn,
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
      return loadingView();
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
          delay: 100.milliseconds,
          beginY: 50.0,
          child: EmptyContent(
            icon: Opacity(
              opacity: .8,
              child: Icon(
                Icons.speaker_notes_off,
                size: 120.0,
                color: Color(0xFFFF005C),
              ),
            ),
            title: "You've published no quote yet",
            subtitle: 'They will appear when you add a new quote',
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

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 200.0),
          child: LoadingAnimation(),
        ),
      ]),
    );
  }

  Widget gridView() {
    final isConnected = stateUser.isUserConnected;

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
              padding: const EdgeInsets.all(20.0),
              elevation: Constants.cardElevation,
              componentType: ItemComponentType.card,
            );
          },
          childCount: quotes.length,
        ),
      ),
    );
  }

  Widget listView() {
    final isConnected = stateUser.isUserConnected;
    final horPadding = MediaQuery.of(context).size.width < 700.00 ? 0.0 : 70.0;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final quote = quotes.elementAt(index);
          return QuoteRowWithActions(
            quote: quote,
            quoteId: quote.id,
            canManage: canManage,
            isConnected: isConnected,
            key: ObjectKey(index),
            useSwipeActions: true,
            color: stateColors.appBackground,
            padding: EdgeInsets.symmetric(
              horizontal: horPadding,
            ),
          );
        },
        childCount: quotes.length,
      ),
    );
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
      lastDoc = null;
      quotes.clear();
    });

    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Signin(),
          ),
        );

        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('user.id', isEqualTo: userAuth.uid)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
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
        isLoading = false;
        hasNext = limit == snapshot.size;
        lastDoc = snapshot.docs.last;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
        hasNext = false;
        lastDoc = null;
      });
    }
  }

  void fetchMore() async {
    if (lastDoc == null) {
      return;
    }

    isLoadingMore = true;

    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Signin(),
          ),
        );

        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('user.id', isEqualTo: userAuth.uid)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .startAfterDocument(lastDoc)
          .limit(limit)
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
        hasNext = limit == snapshot.size;
        lastDoc = snapshot.docs.last;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingMore = false;
        hasNext = false;
      });
    }
  }

  void fetchPermissions() async {
    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        return;
      }

      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .get();

      if (user == null) {
        return;
      }

      setState(() {
        canManage = user.data()['rights']['user:managequotidian'];
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
