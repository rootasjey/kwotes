import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/filter_fab.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/small_temp_quote_card.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:provider/provider.dart';

class MyTempQuotes extends StatefulWidget {
  @override
  MyTempQuotesState createState() => MyTempQuotesState();
}

class MyTempQuotesState extends State<MyTempQuotes> {
  String lang = 'en';
  int limit = 10;
  int order = -1;
  int skip = 0;
  List<TempQuote> quotes = [];

  int attempts = 1;
  int maxAttempts = 2;

  bool isLoading = false;
  bool hasErrors = false;
  Error error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchTempQuotes();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context).accent;

    if (isLoading) {
      return Scaffold(
        body: LoadingComponent(
          title: 'Loading my quotes in validation...',
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
          'In validation',
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
        },
        order: order,
      ),
      body: GridView.builder(
        itemCount: quotes.length,
        padding: EdgeInsets.symmetric(vertical: 20.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (BuildContext context, int index) {
          return SmallTempQuoteCard(
            quote: quotes.elementAt(index),
            onDelete: (String id) async {
              final quoteToDelete = quotes.elementAt(index);

              setState(() {
                quotes.removeWhere((q) => q.id == id);
              });

              final booleanMessage = await UserMutations.deleteTempQuote(context, id);

              if (!booleanMessage.boolean) {
                quotes.insert(index, quoteToDelete);

                Flushbar(
                  duration: Duration(seconds: 3),
                  backgroundColor: ThemeColor.error,
                  message: booleanMessage.message,
                )..show(context);
              }
            },
            onDoubleTap: (String id) async {
              tryValidateQuote(index, id);
            },
            onValidate: (String id) async {
              tryValidateQuote(index, id);
            },
          );
        },
      ),
    );
  }

  void fetchTempQuotes() {
    setState(() {
      isLoading = true;
    });

    Queries.myTempQuotes(context, lang, limit, order, skip)
      .then((quotesResp) {
        setState(() {
          quotes = quotesResp.entries;
          isLoading = false;
        });
      })
      .catchError((err) {
        setState(() {
          error = err;
          isLoading = false;
          hasErrors = true;
        });
      });
  }

  void tryValidateQuote(int index, String id) async {
    final quoteToValidate = quotes.elementAt(index);

    setState(() {
      quotes.removeWhere((q) => q.id == id);
    });

    final booleanMessage = await UserMutations.validateTempQuote(context, id);

    if (!booleanMessage.boolean) {
      quotes.insert(index, quoteToValidate);

      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: ThemeColor.error,
        message: booleanMessage.message,
      )..show(context);

      return;
    }

    Flushbar(
      backgroundColor: ThemeColor.success,
      message: 'The quote has been successfully validated'
    )..show(context);
  }
}
