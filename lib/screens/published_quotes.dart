import 'package:flutter/material.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/filter_fab.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/small_quote_card.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/screens/add_quote.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:provider/provider.dart';

class MyPublishedQuotes extends StatefulWidget {
  @override
  MyPublishedQuotesState createState() => MyPublishedQuotesState();
}

class MyPublishedQuotesState extends State<MyPublishedQuotes> {
  String lang = 'en';
  int limit = 10;
  int order = -1;
  int skip = 0;
  List<Quote> quotes = [];

  int attempts = 1;
  int maxAttempts = 2;

  bool isLoading = false;
  bool hasErrors = false;
  Error error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchQuotes();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context).accent;

    if (isLoading) {
      return Scaffold(
        body: LoadingComponent(
          title: 'Loading my published quotes...',
        ),
      );
    }

    if (!isLoading && hasErrors) {
      return ErrorComponent(
        description: error != null ? error.toString() : '',
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Published quotes',
          style: TextStyle(
            color: accent,
            fontSize: 25.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: accent,),
        ),
      ),
      floatingActionButton: quotes.length > 0 ?
        FilterFab(
          onOrderChanged: (int newOrder) {
            setState(() {
              order = newOrder;
            });

            fetchQuotes();
          },
          order: order,
        ):
        Padding(padding: EdgeInsets.zero,),
      body: Builder(
        builder: (BuildContext context) {
          if (quotes.length == 0) {
            return emptyView();
          }

          return GridView.builder(
            itemCount: quotes.length,
            padding: EdgeInsets.symmetric(vertical: 20.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (BuildContext context, int index) {
              return SmallQuoteCard(quote: quotes.elementAt(index),);
            },
          );
        },
      )
    );
  }

  Widget emptyView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.speaker_notes_off, size: 60.0),

          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(
              'No quotes',
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
          ),

          Opacity(
            opacity: .6,
            child: FlatButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return AddQuote();
                    }
                  )
                );
              },
              child: Text(
                'You have not published any quotes yet. Go to the Add Quote page to start sharing your thoughts with others.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            )
          ),
        ],
      ),
    );
  }

  void fetchQuotes() {
    setState(() {
      isLoading = true;
    });

    Queries.myPublihshedQuotes(context, lang, limit, order, skip)
      .then((quotesResp) {
        setState(() {
          isLoading = false;
          quotes = quotesResp.entries;
        });
      })
      .catchError((err) {
        setState(() {
          isLoading = false;
          hasErrors = true;
          error = err;
        });
      });
  }
}
