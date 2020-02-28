import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/load_more_card.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class QuotesPage extends StatefulWidget {
  @override
  _QuotesPageState createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  List<Quote> quotes = [];

  bool isLoading = false;
  bool isLoadingMore = false;

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
            Icon(Icons.warning, size: 40.0),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('No quotes found. Either the service has trouble or your connection does not work properly.'),
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
      final topicColor = ThemeColor.topicsColors
        .firstWhere((element) => element.name == quote.topics.first);

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
                            quote.name,
                            style: TextStyle(
                              fontSize: adaptativeFont(quote.name),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: PopupMenuButton<String>(
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
            'Quotes',
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

  void addQuotidian(Quote quote) async {
    try {
      final snapshot = await FirestoreApp.instance
        .collection("quotidians")
        .orderBy("date", "desc")
        .limit(1)
        .get();

      String id = '';
      DateTime nextDate;

      if (snapshot.empty) {
        final now = DateTime.now();
        nextDate = now;

        id = '${now.year}:${now.month}:${now.day}:${Language.current}';

      } else {
        final first = snapshot.docs.first;
        final DateTime lastDate = first.data()['date'];

        nextDate = lastDate.add(
          Duration(days: 1)
        );

        id = '${nextDate.year}:${nextDate.month}:${nextDate.day}:${Language.current}';
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
      setState(() {
        isLoadingMore = false;
      });
    }
  }

}
