import 'package:flutter/material.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/filter_fab.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/small_quote_card.dart';
import 'package:memorare/data/queries.dart';
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
      floatingActionButton: FilterFab(
        onOrderChanged: (int newOrder) {
          setState(() {
            order = newOrder;
          });

          fetchQuotes();
        },
        order: order,
      ),
      body: GridView.builder(
        itemCount: quotes.length,
        padding: EdgeInsets.symmetric(vertical: 20.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (BuildContext context, int index) {
          return SmallQuoteCard(quote: quotes.elementAt(index),);
        },
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
