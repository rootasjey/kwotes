import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/components/empty_content.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/utils/app_localstorage.dart';
import 'package:supercharged/supercharged.dart';

import 'signin.dart';

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
  final String pageRoute = PublishedQuotesRoute;

  @override
  initState() {
    super.initState();
    initProps();
    fetch();
    fetchPermissions();
  }

  void initProps() {
    lang = appLocalStorage.getPageLang(pageRoute: pageRoute);
    itemsLayout = appLocalStorage.getItemsStyle(pageRoute);
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
            child: CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
                appBar(),
                body(),
              ],
            ),
          )),
    );
  }

  Widget appBar() {
    return PageAppBar(
      textTitle: 'Published',
      textSubTitle: 'Quotes published by you',
      expandedHeight: 120.0,
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

        appLocalStorage.saveItemsStyle(
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

    if (itemsLayout == ItemsLayout.list) {
      return listView();
    }

    return gridView();
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
              componentType: ItemComponentType.card,
            );
          },
          childCount: quotes.length,
        ),
      ),
    );
  }

  Widget listView() {
    final isConnected = userState.isUserConnected;
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
    });

    lastDoc = null;
    quotes.clear();

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('user.id', isEqualTo: userAuth.uid)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(30)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
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

    setState(() {
      isLoadingMore = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('user.id', isEqualTo: userAuth.uid)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .startAfterDocument(lastDoc)
          .limit(30)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isLoadingMore = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.insert(quotes.length - 1, quote);
      });

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

  void fetchPermissions() async {
    try {
      final userAuth = await userState.userAuth;

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
