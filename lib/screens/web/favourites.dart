import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/loading_animation.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_fav.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/auth.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class Favourites extends StatefulWidget {
  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasNext = true;

  final _scrollController = ScrollController();
  bool isFabVisible = false;

  List<Quote> quotes = [];

  FirebaseUser userAuth;

  var lastDoc;

  @override
  initState() {
    super.initState();
    fetchFavQuotes();
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
        final screenWidth = MediaQuery.of(context).size.width;

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
              fetchMoreFavQuotes();
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
                                'Favourites',
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

              listContent(screenWidth: screenWidth),
            ],
          ),
        );
      },
    );
  }

  Widget listContent({double screenWidth}) {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate([
            LoadingAnimation(
              title: 'Loading your favourites...',
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
                      Icons.favorite_border,
                      size: 60.0,
                      color: Color(0xFFFF005C),
                    ),
                  ),
                  title: "You've no favourites quotes at this moment",
                  subtitle: 'You can add them with the ❤️ button',
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
            child: quoteContainer(
              quote: quote,
              screenWidth: screenWidth,
            )
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

          userActions(quote),
        ],
      ),
    );
  }

  Widget userActions(Quote quote) {
    return PopupMenuButton<String>(
      icon: Opacity(
        opacity: .6,
        child: Icon(Icons.more_horiz)
      ),
      onSelected: (value) {
        switch (value) {
          case 'remove':
            removeFav(quote);
            break;
          case 'share':
            shareTwitter(quote: quote);
            break;
          default:
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
    );
  }

  void fetchFavQuotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      // User check
      userAuth = userAuth ?? await getUserAuth();

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
      }

      // Data
      final snapshot = await FirestoreApp.instance
        .collection('users')
        .doc(userAuth.uid)
        .collection('favourites')
        .limit(30)
        .get();

      if (snapshot.empty) {
        setState(() {
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

      lastDoc = snapshot.docs.last;

      setState(() {
        isLoading = false;
      });

    } catch (error) {
      debugPrint(error.toString());

      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        message: "There was an issue while fetching your favourites.",
      )..show(context);

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }
    }
  }

  void fetchMoreFavQuotes() async {
    setState(() {
      isLoadingMore = true;
    });

    try {
      userAuth = userAuth ?? await FirebaseAuth.instance.currentUser();

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
      }

      final snapshot = await FirestoreApp.instance
        .collection('users')
        .doc(userAuth.uid)
        .collection('favourites')
        .startAfter(snapshot: lastDoc)
        .limit(30)
        .get();

      if (snapshot.empty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.forEach((doc) {
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

      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        message: "There was an issue while fetching your favourites.",
      )..show(context);
    }
  }

  Future removeFav(Quote quote) async {
    final index = quotes.indexOf(quote);

    setState(() { // optimistic
      quotes.removeAt(index);
    });

    try {
      final result = await removeFromFavourites(quote: quote);

      if (!result) {
        setState(() {
          quotes.insert(index, quote);
        });
      }

      stateUserFav.updateDate();

    } catch (error) {
      debugPrint(error.toString());

      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        message: "There was an issue while removing the quote from your favourites.",
      )
      ..show(context);

      if (!quotes.contains(quote)) {
        setState(() {
          quotes.insert(index, quote);
        });
      }
    }
  }
}
