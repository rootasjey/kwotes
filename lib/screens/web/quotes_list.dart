import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/lists.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/loading_animation.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/user_quotes_list.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/utils/snack.dart';

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

  final scrollController = ScrollController();
  bool isFabVisible = false;

  List<Quote> quotes = [];

  var lastDoc;

  @override
  initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible ?
        FloatingActionButton(
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
              fetchMore();
            }

            return false;
          },
          child: CustomScrollView(
            controller: scrollController,
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
                      top: 85.0,
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
    final topicColor = appTopicsColors.find(quote.topics.first);

    return Container(
      padding: const EdgeInsets.all(80.0),
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              FluroRouter.router.navigateTo(
                context,
                QuotePageRoute.replaceFirst(':id', quote.quoteId),
              );
            },
            child: Text(
              quote.name,
              style: TextStyle(
                fontSize: FontSize.hero(quote.name) / (2000 / screenWidth),
              ),
            ),
          ),

          topicColor != null ?
            SizedBox(
              width: 100.0,
              child: Divider(
                color: Color(topicColor.decimal),
                thickness: 2.0,
                height: 40.0,
              )
            ) :
            SizedBox(
              width: 100.0,
              child: Divider(
                thickness: 2.0,
                height: 40.0,
              ),
            ),

          GestureDetector(
            onTap: () {
              FluroRouter.router.navigateTo(
                context,
                AuthorRoute.replaceFirst(':id', quote.author.id),
              );
            },
            child: Opacity(
              opacity: .6,
              child: Text(
                quote.author.name,
                style: TextStyle(
                  fontSize: 20.0,
                ),
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

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      quotes.clear();

      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isLoading = false;
        });

        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      final docList = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .collection('lists')
        .document(widget.listId)
        .get();

      if (!docList.exists) {
        showSnack(
        context: context,
        message: "This list doesn't' exist anymore",
        type: SnackType.error,
      );

        FluroRouter.router.pop(context);
        return;
      }

      final data = docList.data;
      data['id'] = docList.documentID;
      quotesList = UserQuotesList.fromJSON(data);

      final snapshot = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .collection('lists')
        .document(quotesList.id)
        .collection('quotes')
        .limit(limit)
        .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          hasNext = false;
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

      setState(() {
        hasNext = snapshot.documents.length == limit;
        isLoading = false;
      });

    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchMore() async {
    setState(() {
      isLoadingMore = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isLoadingMore = false;
        });

        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      final snapshot = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .collection('lists')
        .document(quotesList.id)
        .collection('quotes')
        .startAfterDocument(lastDoc)
        .limit(limit)
        .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          hasNext = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        hasNext = snapshot.documents.length == limit;
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

    final success = await removeFromList(
      context: context,
      id: widget.listId,
      quote: quote,
    );

    if (!success) {
      setState(() {
        quotes.insert(index, quote);
      });

      showSnack(
        context: context,
        message: "Sorry, could not remove the quote from your list. Please try again later.",
        type: SnackType.error,
      );
    }
  }
}
