import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/empty_flat_card.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/load_more_card.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class AdminTempQuotes extends StatefulWidget {
  @override
  _AdminTempQuotesState createState() => _AdminTempQuotesState();
}

class _AdminTempQuotesState extends State<AdminTempQuotes> {
  final List<TempQuote> tempQuotes = [];
  bool isLoading = false;
  bool isLoadingMore = false;

  var lastDoc;

  @override
  initState() {
    super.initState();
    fetchTempQuotes();
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

    if (!isLoading && tempQuotes.length == 0) {
      return Container(
        height: MediaQuery.of(context).size.height - 300.0,
        child:  EmptyFlatCard(
          onPressed: () => fetchTempQuotes(),
        ),
      );
    }

    return gridQuotes();
  }

  Widget gridQuotes() {
    final children = <Widget>[];

    tempQuotes.forEach((tempQuote) {
      final topicColor = ThemeColor.topicsColors
        .firstWhere((element) => element.name == tempQuote.topics.first);

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
                        AddQuoteContentRoute,
                      );
                    },
                    child: SizedBox.expand(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              tempQuote.name,
                              style: TextStyle(
                                fontSize: adaptativeFont(tempQuote.name),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        deleteTempQuote(tempQuote);
                        return;
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_forever),
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
          fetchTempQuotesMore();
        },
      )
    );

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Text(
            'Quotes in validation',
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

  void deleteTempQuote(TempQuote tempQuote) async {
    int index = tempQuotes.indexOf(tempQuote);

    setState(() {
      tempQuotes.remove(tempQuote);
    });

    try {
      await FirestoreApp.instance
        .collection('tempquotes')
        .doc(tempQuote.id)
        .delete();

      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green,
        message: 'The temporary quote has been successfully deleted.',
      )..show(context);

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        tempQuotes.insert(index, tempQuote);
      });

      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        message: "Couldn't delete the temporary quote. Details: ${error.toString()}",
      )..show(context);
    }
  }

  void fetchTempQuotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirestoreApp.instance
        .collection('tempquotes')
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

        final quote = TempQuote.fromJSON(data);
        tempQuotes.add(quote);
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

  void fetchTempQuotesMore() async {
    if (lastDoc == null) { return; }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final snapshot = await FirestoreApp.instance
        .collection('tempquotes')
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

        final quote = TempQuote.fromJSON(data);
        tempQuotes.insert(tempQuotes.length - 1, quote);
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
