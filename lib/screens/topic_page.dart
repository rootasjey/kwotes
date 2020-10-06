import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/animation.dart';
import 'package:mobx/mobx.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:supercharged/supercharged.dart';

import 'author_page.dart';
import 'web/quote_page.dart';

class TopicPage extends StatefulWidget {
  final String name;

  TopicPage({
    this.name,
  });

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  final beginY = 50.0;
  final delay = 1.0;
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
              child: Icon(Icons.arrow_upward),
            )
          : null,
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: body(),
          ),
        ],
      ),
    );
  }

  Widget animatedDivider() {
    return ControlledAnimation(
      delay: 1.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 200.0),
      child: Divider(
        color: Color(decimal),
        thickness: 2.0,
      ),
      builderWithChild: (context, child, value) {
        return SizedBox(
          width: value,
          child: child,
        );
      },
    );
  }

  Widget authorName(Quote quote) {
    return ControlledAnimation(
      delay: 1.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 0.8),
      builderWithChild: (context, child, value) {
        return Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Opacity(
              opacity: value,
              child: child,
            ));
      },
      child: GestureDetector(
        onTap: () {
          final id = quote.author.id;

          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AuthorPage(
                    id: id,
                  )));
        },
        child: Text(
          quote.author.name,
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
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
        if (scrollNotif.metrics.pixels <
            scrollNotif.metrics.maxScrollExtent - 100.0) {
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
          Observer(
            builder: (_) {
              return SliverAppBar(
                floating: true,
                snap: true,
                expandedHeight: 200.0,
                backgroundColor: stateColors.softBackground,
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
                              size: 80.0,
                              color: Color(decimal),
                              name: widget.name,
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20.0,
                      top: 60.0,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          listQuotesContent(),
        ],
      ),
    );
  }

  Widget listQuotesContent() {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 150.0,
            ),
            child: LoadingAnimation(
              textTitle: 'Loading ${widget.name} quotes...',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
        ]),
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
        ]),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final quote = quotes.elementAt(index);

          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: listItem(
              quote: quote,
              index: index,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          );
        },
        childCount: quotes.length,
      ),
    );
  }

  Widget listItem({
    Quote quote,
    int index,
    double screenWidth,
    double screenHeight,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => QuotePage(quoteId: quote.id)));
      },
      onLongPress: () {
        showActionsSheet(quote);
      },
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                createHeroQuoteAnimation(
                  quote: quote,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  isMobile: true,
                ),
              ],
            ),
          ),
          animatedDivider(),
          authorName(quote),
          userActions(quote),
        ],
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
      if (topicColor == null) {
        return;
      }

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
              fetchIsFav(quote.id).then((isOk) {
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
                        Navigator.pop(context);
                        shareFromMobile(context: context, quote: quote);
                      },
                      tooltip: 'Share',
                      icon: Icon(Icons.share),
                    ),
                  ),
                  isFav
                      ? IconButton(
                          onPressed: isFavLoaded
                              ? () {
                                  removeFromFavourites(
                                      context: context, quote: quote);
                                  Navigator.pop(context);
                                }
                              : null,
                          tooltip: 'Remove from favourites',
                          icon: Icon(Icons.favorite),
                        )
                      : IconButton(
                          onPressed: isFavLoaded
                              ? () {
                                  addToFavourites(
                                      context: context, quote: quote);
                                  Navigator.pop(context);
                                }
                              : null,
                          tooltip: 'Add to favourites',
                          icon: Icon(
                            Icons.favorite_border,
                          )),
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
