import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/quote_card_grid_item.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class AdminQuotes extends StatefulWidget {
  @override
  _AdminQuotesState createState() => _AdminQuotesState();
}

class _AdminQuotesState extends State<AdminQuotes> {
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
            child: gridQuotes(),
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
        title: 'Loading all published quotes...',
      );
    }

    if (!isLoading && quotes.length == 0) {
      return emptyContainer();
    }

    return gridQuotes();
  }

  Widget emptyContainer() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          Icon(Icons.warning, size: 40.0),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('No quotes found. Either the service has trouble or your connection does not work properly.'),
          ),
        ],
      ),
    );
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
                            'All published quotes',
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
                final topicColor = appTopicsColors.find(quote.topics.first);

                return FadeInY(
                  delay: 3.0 + index.toDouble(),
                  beginY: 100.0,
                  child: SizedBox(
                    width: 250.0,
                    height: 250.0,
                    child: QuoteCardGridItem(
                      quote: quote,
                      popupMenuButton: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          color: Color(topicColor.decimal),
                        ),
                        onSelected: (value) {
                          if (value == 'quotidian') {
                            addQuotidian(quote);
                            return;
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem(
                            value: 'quotidian',
                            child: ListTile(
                              leading: Icon(Icons.add),
                              title: Text('Add to quotidians'),
                            )
                          ),
                        ],
                      ),
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

  void addQuotidian(Quote quote) async {
    try {
      // Decide the next date
      final snapshot = await FirestoreApp.instance
        .collection('quotidians')
        .where('lang', '==', Language.current)
        .orderBy('date', 'desc')
        .limit(1)
        .get();

      String id = '';
      DateTime nextDate;

      if (snapshot.empty) {
        final now = DateTime.now();
        nextDate = now;

        String month = now.month.toString();
        month = month.length == 2 ? month : '0$month';

        String day = now.day.toString();
        day = day.length == 2 ? day : '0$day';

        id = '${now.year}:$month:$day:${Language.current}';

      } else {
        final first = snapshot.docs.first;
        final DateTime lastDate = first.data()['date'];

        nextDate = lastDate.add(
          Duration(days: 1)
        );

        String nextMonth = nextDate.month.toString();
        nextMonth = nextMonth.length == 2 ? nextMonth : '0$nextMonth';

        String nextDay = nextDate.day.toString();
        nextDay = nextDay.length == 2 ? nextDay : '0$nextDay';

        id = '${nextDate.year}:$nextMonth:$nextDay:${Language.current}';
      }

      await FirestoreApp.instance
        .collection('quotidians')
        .doc(id)
        .set({
          'createdAt': DateTime.now(),
          'date': nextDate,
          'lang': Language.current,
          'quote': {
            'author': {
              'id': quote.author.id,
              'name': quote.author.name,
            },
            'id': quote.id,
            'mainReference': {
              'id': quote.mainReference.id,
              'name': quote.mainReference.name,
            },
            'name': quote.name,
            'topics': quote.topics,
          },
          'updatedAt': DateTime.now(),
          'urls': {
            'image': {
              'small': '',
              'medium': '',
              'large': '',
            },
            'imageAndText': {
              'small': '',
              'medium': '',
              'large': '',
            },
          }
        });

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'The quote has been successfully added to quotidians.'
          ),
        )
      );

    } catch (error) {
      debugPrint(error.toString());

      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sorry, an error occurred while adding the quotes to quotidian.'
          ),
        )
      );
    }
  }

  void checkAuthStatus() async {
    userAuth = await FirebaseAuth.instance.currentUser();

    if (userAuth == null) {
      FluroRouter.router.navigateTo(context, SigninRoute);
    }

    final user = await FirestoreApp.instance
      .collection('users')
      .doc(userAuth.uid)
      .get();

    if (!user.exists) {
      FluroRouter.router.navigateTo(context, SigninRoute);
      return;
    }

    canManage = user.data()['rights']['user:managequote'] == true;

    if (!canManage) {
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  void fetchQuotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirestoreApp.instance
        .collection('quotes')
        .where('lang', '==', Language.current)
        .limit(30)
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

  void fetchMoreQuotes() async {
    if (lastDoc == null) { return; }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final snapshot = await FirestoreApp.instance
        .collection('quotes')
        .where('lang', '==', Language.current)
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
        quotes.insert(quotes.length - 1, quote);
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
