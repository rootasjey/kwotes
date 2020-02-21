import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
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
      children.add(
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: 250.0,
            height: 250.0,
            child: Card(
              shape: BorderDirectional(
                bottom: BorderSide(
                  color: Colors.green,
                  width: 2.0,
                ),
              ),
              child: InkWell(
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
            ),
          ),
        )
      );
    });

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

      setState(() {
        isLoading = false;
      });

    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
