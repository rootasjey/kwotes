import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/loading_animation.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/user_quotes_list.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';
import 'package:supercharged/supercharged.dart';

class QuotesList extends StatefulWidget {
  final String listId;

  QuotesList({
    this.listId,
  });

  @override
  _QuoteListState createState() => _QuoteListState();
}

class _QuoteListState extends State<QuotesList> {
  UserQuotesList quotesList;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasNext = true;
  int limit = 10;

  final _scrollController = ScrollController();
  bool isFabVisible = false;

  List<Quote> quotes = [];

  FirebaseUser userAuth;

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
              NavBackFooter(),
            ],
          ),

          Footer(),
        ],
      ),
    );
  }

  Widget body() {
    return OrientationBuilder(
      builder: (context, orientation) {
        return NotificationListener(
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
                          delay: .5,
                          beginY: 50.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                quotesList?.name ?? 'List',
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

              listContent(
                screenWidth: MediaQuery.of(context).size.width,
              ),
            ],
          ),
        );
      }
    );
  }

  Widget listContent({double screenWidth}) {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate([
            LoadingAnimation(
              title: 'Loading list...',
            ),
          ]
        ),
      );
    }

    if (quotes.length == 0) {
      return SliverList(
        delegate: SliverChildListDelegate([
            FadeInY(
              delay: 2.0,
              beginY: 50.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: EmptyContent(
                  icon: Opacity(
                    opacity: .8,
                    child: Icon(
                      Icons.list,
                      size: 60.0,
                      color: Color(0xFFFF005C),
                    ),
                  ),
                  title: "You've no quotes in the ${quotesList.name} list at this moment",
                  subtitle: 'You can add some from others pages',
                ),
              ),
            ),
          ]
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final quote = quotes.elementAt(index);

          return FadeInY(
            delay: 2.0 + index.toDouble() * 0.1,
            beginY: 50.0,
            child: quoteContainer(quote: quote, screenWidth: screenWidth),
          );
        },
        childCount: quotes.length,
      ),
    );
  }

  Widget quoteContainer({Quote quote, double screenWidth}) {
    return Container(
      padding: const EdgeInsets.all(80.0),
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              FluroRouter.router.navigateTo(
                context,
                QuotePageRoute.replaceFirst(':id', quote.quoteId),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                quote.name,
                style: TextStyle(
                  fontSize: FontSize.hero(quote.name) / (2000 / screenWidth),
                ),
              ),
            ),
          ),

          SizedBox(
            width: 100.0,
            child: Divider(
              thickness: 2.0,
              height: 40.0,
            ),
          ),

          Opacity(
            opacity: .6,
            child: Text(
              quote.author.name,
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),

          Padding(padding: const EdgeInsets.only(top: 15.0),),

          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz),
            onSelected: (value) {
              if (value == 'remove') {
                removeQuote(quote);
                return;
              }

              if (value == 'share') {
                shareTwitter(quote: quote);
                return;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'remove',
                child: ListTile(
                  leading: Icon(Icons.remove_circle),
                  title: Text('Remove'),
                )
              ),
              PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  void fetchQuotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      quotes.clear();

      userAuth = userAuth ?? await FirebaseAuth.instance.currentUser();

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      final docList = await FirestoreApp.instance
        .collection('users')
        .doc(userAuth.uid)
        .collection('lists')
        .doc(widget.listId)
        .get();

      if (!docList.exists) {
        Flushbar(
          duration: 2.seconds,
          backgroundColor: Colors.red ,
          message: "This list doesn't' exist anymore",
        )..show(context);

        FluroRouter.router.pop(context);
        return;
      }

      final data = docList.data();
      data['id'] = docList.id;
      quotesList = UserQuotesList.fromJSON(data);

      final snapshot = await FirestoreApp.instance
        .collection('users')
        .doc(userAuth.uid)
        .collection('lists')
        .doc(quotesList.id)
        .collection('quotes')
        .limit(limit)
        .get();

      if (snapshot.empty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapshot.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        hasNext = snapshot.size == limit;
        isLoading = false;
      });

    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchMoreQuotes() async {
    setState(() {
      isLoadingMore = true;
    });

    try {
      final snapshot = await FirestoreApp.instance
        .collection('users')
        .doc(userAuth.uid)
        .collection('lists')
        .doc(quotesList.id)
        .collection('quotes')
        .startAfter(snapshot: lastDoc)
        .limit(limit)
        .get();

      if (snapshot.empty) {
        setState(() {
          hasNext = false;
        });

        return;
      }

      snapshot.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        hasNext = snapshot.size == limit;
        isLoadingMore = false;
      });

    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void removeQuote(Quote quote) async {
    int index = quotes.indexOf(quote);

    setState(() {
      quotes.removeAt(index);
    });

    try {
      userAuth = userAuth ?? await FirebaseAuth.instance.currentUser();

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      await FirestoreApp.instance
        .collection('users')
        .doc(userAuth.uid)
        .collection('lists')
        .doc(widget.listId)
        .collection('quotes')
        .doc(quote.id)
        .delete();

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        quotes.insert(index, quote);
      });
    }
  }
}
