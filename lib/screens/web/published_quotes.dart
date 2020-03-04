import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/load_more_card.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class PublishedQuotes extends StatefulWidget {
  @override
  _PublishedQuotesState createState() => _PublishedQuotesState();
}

class _PublishedQuotesState extends State<PublishedQuotes> {
  List<Quote> quotes = [];

  bool isLoading = false;
  bool isLoadingMore = false;

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
    return Column(
      children: <Widget>[
        NavBackHeader(),
        body(),
        NavBackFooter(),
      ],
    );
  }

  Widget body() {
    if (isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Loading quotes...',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!isLoading && quotes.length == 0) {
      return Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Icon(Icons.list, size: 80.0),
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
    final children = <Widget>[];

    quotes.forEach((quote) {
      final topicColor = appTopicsColors.find(quote.topics.first);

      children.add(
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: 250.0,
            height: 250.0,
            child: Card(
              shape: BorderDirectional(
                bottom: BorderSide(
                  color: Color(topicColor.decimal),
                  width: 2.0,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      FluroRouter.router.navigateTo(
                        context,
                        QuotePageRoute.replaceFirst(':id', quote.id)
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            quote.name.length > 115 ?
                            '${quote.name.substring(0, 115)}...' : quote.name,
                            style: TextStyle(
                              fontSize: adaptativeFont(quote.name),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Positioned(
                  //   right: 0,
                  //   bottom: 0,
                  //   child: PopupMenuButton<String>(
                  //     onSelected: (value) {
                  //     },
                  //     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  //       PopupMenuItem(
                  //         value: 'favourite',
                  //         child: ListTile(
                  //           leading: Icon(Icons.add),
                  //           title: Text('Add to favourites'),
                  //         )
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        )
      );
    });

    children.add(
      LoadMoreCard(
        isLoading: isLoadingMore,
        onTap: () {
          fetchQuotesMore();
        },
      )
    );

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Text(
            'My published quotes',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),

        Wrap(
          children: children,
        ),
      ],
    );
  }

  double adaptativeFont(String text) {
    if (text.length > 120) {
      return 14.0;
    }

    if (text.length > 90) {
      return 16.0;
    }

    if (text.length > 60) {
      return 18.0;
    }

    return 20.0;
  }

  void fetchQuotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      userAuth = await FirebaseAuth.instance.currentUser();

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      final snapshot = await FirestoreApp.instance
        .collection('quotes')
        .where('user.id', '==', userAuth.uid)
        .where('lang', '==', Language.current)
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

      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchQuotesMore() async {
    if (lastDoc == null) { return; }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final snapshot = await FirestoreApp.instance
        .collection('quotes')
        .where('user.id', '==', userAuth.uid)
        .where('lang', '==', Language.current)
        .startAfter(snapshot: lastDoc)
        .limit(30)
        .get();

      if (snapshot.empty) {
        setState(() {
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
