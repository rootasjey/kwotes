import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/quote_card_grid_item.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/auth.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';

class PublishedQuotes extends StatefulWidget {
  @override
  _PublishedQuotesState createState() => _PublishedQuotesState();
}

class _PublishedQuotesState extends State<PublishedQuotes> {
  List<Quote> quotes = [];

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasNext = true;

  final _scrollController = ScrollController();
  bool isFabVisible = false;

  FirebaseUser userAuth;
  bool canManage = false;

  var lastDoc;

  @override
  initState() {
    super.initState();
    fetchQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible ?
        FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0.0,
              duration: Duration(seconds: 1),
              curve: Curves.easeOut,
            );
          },
          backgroundColor: stateColors.primary,
          foregroundColor: Colors.white,
          child: Icon(Icons.arrow_upward),
        ) : null,
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: body(),
          ),

          Column(
            children: <Widget>[
              loadMoreButton(),
              NavBackFooter(),
            ],
          ),

          Footer(),
        ],
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return FullPageLoading(
        title: 'Loading published quotes...',
      );
    }

    if (!isLoading && quotes.length == 0) {
      return Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Icon(Icons.check_box_outline_blank, size: 80.0),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('You have no published quotes yet.'),
            ),
          ],
        ),
      );
    }

    return gridQuotes();
  }

  Widget gridQuotes() {
    return NotificationListener<ScrollNotification>(
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
        if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent - 100.0) {
          return false;
        }

        if (hasNext && !isLoadingMore) {
          fetchMoreQuotes();
        }

        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 320.0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    FadeInY(
                      beginY: 50.0,
                      child: AppIconHeader(),
                    ),

                    FadeInY(
                      delay: 1.0,
                      beginY: 50.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Published quotes',
                            style: TextStyle(
                              fontSize: 30.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Positioned(
                  left: 80.0,
                  top: 50.0,
                  child: IconButton(
                    onPressed: () {
                      FluroRouter.router.pop(context);
                    },
                    tooltip: 'Back',
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
              ],
            ),
          ),

          SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final quote = quotes.elementAt(index);

                return FadeInY(
                  delay: 3.0 + index.toDouble(),
                  beginY: 100.0,
                  child: SizedBox(
                    width: 250.0,
                    height: 250.0,
                    child: QuoteCardGridItem(
                      quote: quote,
                    ),
                  ),
                );
              },
              childCount: quotes.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget loadMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
        child: FlatButton(
        onPressed: () {
          fetchMoreQuotes();
        },
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: stateColors.foreground,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            'Load more...'
          ),
        ),
      ),
    );
  }

  void fetchQuotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      userAuth = await getUserAuth();

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      final snapshot = await Firestore.instance
        .collection('quotes')
        .where('user.id', isEqualTo: userAuth.uid)
        .where('lang', isEqualTo: Language.current)
        .orderBy('createdAt', descending: true)
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

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }
    }
  }

  void fetchMoreQuotes() async {
    if (lastDoc == null) { return; }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final snapshot = await Firestore.instance
        .collection('quotes')
        .where('user.id', isEqualTo: userAuth.uid)
        .where('lang', isEqualTo: Language.current)
        .orderBy('createdAt', descending: true)
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
