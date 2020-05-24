import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/footer.dart';
import'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:mobx/mobx.dart';

class TopicPage extends StatefulWidget {
  final String name;

  TopicPage({
    this.name,
  });

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  final beginY    = 50.0;
  final delay     = 1.0;
  final delayStep = 1.2;

  int decimal = 4283980123;
  String topicName;
  ReactionDisposer topicDisposer;

  var lastDoc;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasNext = true;

  List<Quote> quotes = [];

  final scrollController = ScrollController();

  bool isFav = false;
  bool isFavLoaded = false;
  bool isFavLoading = false;
  bool isFabVisible = false;

  FirebaseUser userAuth;

  @override
  void initState() {
    super.initState();

    setupTopic();
    fetchQuotes();
  }

  @override
  void dispose() {
    if (topicDisposer != null) {
      topicDisposer();
    }

    super.dispose();
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
        controller: scrollController,
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 250.0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: Stack(
              children: <Widget>[
                FadeInY(
                  beginY: 50.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TopicCardColor(
                          color: Color(decimal),
                          name: widget.name,
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: 80.0,
                  top: 50.0,
                  child: IconButton(
                    onPressed: () {
                      FluroRouter.router.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
              ],
            ),
          ),

          gridQuotesContent(),
        ],
      ),
    );
  }

  Widget gridQuotesContent() {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate([
            LoadingAnimation(
              textTitle: 'Loading ${widget.name} quotes...',
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
                      Icons.chat_bubble_outline,
                      size: 60.0,
                      color: Color(0xFFFF005C),
                    ),
                  ),
                  title: "There's no quotes for ${widget.name} at this moment",
                  subtitle: 'You can help us and propose some',
                ),
              ),
            ),
          ]
        ),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final quote = quotes.elementAt(index);

          return SizedBox(
            width: 250.0,
            height: 250.0,
            child: gridItem(quote: quote, index: index),
          );
        },
        childCount: quotes.length,
      ),
    );
  }

  Widget gridItem({Quote quote, int index}) {
    return FadeInY(
      delay: delay + (index * delayStep),
      beginY: beginY,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            FluroRouter.router.navigateTo(
              context,
              QuotePageRoute.replaceFirst(':id', quote.id)
            );
          },
          onLongPress: () {
            showActionsSheet(quote);
          },
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      quote.name,
                      style: TextStyle(
                        fontSize: adaptativeFont(quote.name),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: userActions(quote),
              ),
            ],
          ),
        ),
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
          side: BorderSide(),
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

  Widget userActions(Quote quote) {
    return IconButton(
      onPressed: () {
        showActionsSheet(quote);
      },
      tooltip: 'Quotes actions',
      icon: Opacity(
        opacity: .5,
        child: Icon(
          Icons.more_horiz,
          color: Color(decimal),
        ),
      ),
    );
  }

  double adaptativeFont(String text) {
    if (text.length > 90) {
      return 16.0;
    }

    if (text.length > 60) {
      return 18.0;
    }

    return 20.0;
  }

  Future<bool> fetchIsFav(String quoteId) async {
    isFavLoading = true;

    if (userAuth == null) {
      userAuth = await FirebaseAuth.instance.currentUser();
    }

    if (userAuth == null) {
      return false;
    }

    try {
      final doc = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .collection('favourites')
        .document(quoteId)
        .get();

      setState(() {
        isFav = doc.exists;
        isFavLoading = false;
      });

      return true;

    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  void fetchQuotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await Firestore.instance
        .collection('quotes')
        .where('topics.$topicName', isEqualTo: true)
        .where('lang', isEqualTo: userState.lang)
        .limit(10)
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

  void fetchMoreQuotes() async {
    isLoadingMore = true;

    try {
      final snapshot = await Firestore.instance
        .collection('quotes')
        .where('topics.$topicName', isEqualTo: true)
        .where('lang', isEqualTo: userState.lang)
        .startAfterDocument(lastDoc)
        .limit(10)
        .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
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
        isLoadingMore = false;
      });

    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void setupTopic() async {
    topicName = widget.name.toLowerCase();

    topicDisposer = autorun((_) {
      final topicColor = appTopicsColors.find(topicName);
      if (topicColor == null) { return; }

      decimal = topicColor.decimal;
    });
  }

  void showActionsSheet(Quote quote) {
    isFav = false;
    isFavLoaded = false;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) {
            if (!isFavLoading && !isFavLoaded) {
              fetchIsFav(quote.id)
                .then((isOk) {
                  stateSetter(() {
                    isFavLoaded = isOk;
                  });
                });
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: IconButton(
                      onPressed: () {
                        shareTwitter(quote: quote);
                      },
                      tooltip: 'Share',
                      icon: Icon(Icons.share),
                    ),
                  ),

                  isFav ?
                  IconButton(
                    onPressed: isFavLoaded ?
                      () {
                        removeFromFavourites(context: context, quote: quote);
                        Navigator.pop(context);
                      } : null,
                    tooltip: 'Remove from favourites',
                    icon: Icon(Icons.favorite),
                  ) :
                  IconButton(
                    onPressed: isFavLoaded ?
                      () {
                        addToFavourites(context: context, quote: quote);
                        Navigator.pop(context);
                      } : null,
                    tooltip: 'Add to favourites',
                    icon: Icon(Icons.favorite_border,)
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: IconButton(
                      onPressed: null,
                      tooltip: 'Add to...',
                      icon: Icon(Icons.playlist_add),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
