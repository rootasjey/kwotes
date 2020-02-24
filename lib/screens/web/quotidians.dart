import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/load_more_card.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:memorare/utils/converter.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class Quotidians extends StatefulWidget {
  @override
  _QuotidiansState createState() => _QuotidiansState();
}

class _QuotidiansState extends State<Quotidians> {
  List<Quotidian> quotidians = [];

  bool isLoading = false;
  bool isLoadingMore = false;

  var lastDoc;

  @override
  initState() {
    super.initState();
    fetchQuotidians();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NavBackHeader(),

        content(),

        NavBackFooter(),
      ],
    );
  }

  Widget content() {
    if (isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Loading quotidians...',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!isLoading && quotidians.length == 0) {
      return Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Icon(Icons.warning, size: 40.0),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('No quotidians found. Either the service has trouble or your connection does not work properly.'),
            ),
          ],
        ),
      );
    }

    return gridQuotes();
  }

  Widget createMonthTitle(DateTime date) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 12.0,
          ),
          child: SizedBox(
            width: 100.0,
            child: Divider(thickness: 2.0,),
          ),
        ),

        Text(
          getMonthFromNumber(date.month),
        ),
      ],
    );
  }

  Widget gridQuotes() {
    final children = <Widget>[];
    int currentMonth = 0;

    quotidians.forEach((quotidian) {
      final topicColor = ThemeColor.topicsColors
        .firstWhere((element) => element.name == quotidian.quote.topics.first);

      if (currentMonth != quotidian.date.month) {
        currentMonth = quotidian.date.month;

        children.add(
          createMonthTitle(quotidian.date)
        );
      }

      children.add(
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: 300.0,
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
                        QuotePageRoute.replaceFirst(':id', quotidian.quote.id)
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Opacity(
                              opacity: .6,
                              child: Text(
                                quotidian.date.day.toString(),
                              ),
                            ),
                          ),

                          Text(
                            quotidian.quote.name,
                            style: TextStyle(
                              fontSize: adaptativeFont(quotidian.quote.name),
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
                      if (value == 'delete') {
                        deleteQuotidian(quotidian);
                        return;
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Delete'),
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
          fetchMoreQuotidians();
        },
      )
    );

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Text(
            'Quotidians',
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

  void fetchQuotidians() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirestoreApp.instance
        .collection('quotidians')
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

        final quotidian = Quotidian.fromJSON(data);
        quotidians.add(quotidian);
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

  void fetchMoreQuotidians() async {
    if (lastDoc == null) { return; }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final snapshot = await FirestoreApp.instance
        .collection('quotidians')
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

        final quotidian = Quotidian.fromJSON(data);
        quotidians.insert(quotidians.length - 1, quotidian);
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

  void deleteQuotidian(Quotidian quotidian) async {
    try {
      await FirestoreApp.instance
        .collection('quotidians')
        .doc(quotidian.id)
        .delete();

      setState(() {
        quotidians.removeWhere((element) => element.id == quotidian.id);
      });

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'The quotidian has been successfully deleted.'
          ),
        )
      );

    } catch (error) {
      debugPrint(error.toString());

      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sorry, an error occurred while deleting the quotidian.'
          ),
        )
      );
    }
  }
}
