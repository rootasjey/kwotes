import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/page_app_bar.dart';
import 'package:memorare/components/quote_row_with_actions.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/enums.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:supercharged/supercharged.dart';

import 'signin.dart';

class MyPublishedQuotes extends StatefulWidget {
  @override
  MyPublishedQuotesState createState() => MyPublishedQuotesState();
}

class MyPublishedQuotesState extends State<MyPublishedQuotes> {
  bool descending = true;
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

    descending = appLocalStorage.getPageOrder(pageRoute: pageRoute);
    fetch();
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
      body: body(),
    );
  }

  Widget body() {
    return RefreshIndicator(
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
              bodyListContent(),
            ],
          ),
        ));
  }

  Widget appBar() {
    return PageAppBar(
      textTitle: 'Published',
      textSubTitle: 'Quotes published by you',
      expandedHeight: 170.0,
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

        appLocalStorage.setPageOrder(
          descending: newDescending,
          pageRoute: pageRoute,
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

  Widget bodyListContent() {
    if (isLoading) {
      return loadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (quotes.length == 0) {
      return emptyView();
    }

    return sliverQuotesList();
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

  Widget sliverQuotesList() {
    final horPadding = MediaQuery.of(context).size.width < 700.00 ? 20.0 : 70.0;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final quote = quotes.elementAt(index);
          return QuoteRowWithActions(
            quote: quote,
            quoteId: quote.id,
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

      final snapshot = await Firestore.instance
          .collection('quotes')
          .where('user.id', isEqualTo: userAuth.uid)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(30)
          .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      lastDoc = snapshot.documents.last;

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

      final snapshot = await Firestore.instance
          .collection('quotes')
          .where('user.id', isEqualTo: userAuth.uid)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .startAfterDocument(lastDoc)
          .limit(30)
          .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          isLoadingMore = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

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
}
