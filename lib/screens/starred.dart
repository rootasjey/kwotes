import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/medium_quote_card.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:provider/provider.dart';

class Starred extends StatefulWidget {
  @override
  _StarredState createState() => _StarredState();
}

class _StarredState extends State<Starred> {
  int limit = 10;
  int order = 1;
  int skip = 0;
  List<Quote> quotes = [];

  bool isLoading = false;
  bool hasErrors = false;
  FlutterError error;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    fetchStarred();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeColor>(context);
    final color = themeColor.accent;
    final backgroundColor = themeColor.background;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'favorites',
          style: TextStyle(
            color: color,
            fontSize: 30.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: color,),
        ),
      ),
      body: ListView(
        padding: isLoading ?
          EdgeInsets.zero :
          EdgeInsets.symmetric(horizontal: 20.0, vertical: 80.0),
        children: <Widget>[
          if (isLoading)
            LoadingComponent(
              title: 'Loading liked quotes',
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              color: backgroundColor,
              backgroundColor: Colors.transparent,
            ),

          if (!isLoading && quotes.length == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 80.0),
              child: Column(
                children: <Widget>[
                  Icon(IconsMore.heart_broken, size: 80.0,),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      'This place is empty',
                      style: TextStyle(
                        fontSize: 30.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Opacity(
                      opacity: 0.6,
                      child: Text(
                        'Your favorites quotes will show up here.',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (hasErrors)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 80.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'An error occurred',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  FlatButton(
                    onPressed: () { fetchStarred(); },
                    child: Opacity(
                      opacity: 0.6,
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  )
                ],
              ),
            ),

          if (!isLoading && quotes.length > 0)
            ...quotes.map<Widget>((quote) {
                quote.starred = true;

                return MediumQuoteCard(
                  quote: quote,
                  onUnlike: () async {
                    setState(() { // optimistic
                      quotes.removeWhere((q) => q.id == quote.id );
                    });

                    final booleanMessage = await UserMutations.unstar(context, quote.id);

                    if (!booleanMessage.boolean) {
                      setState(() { // rollback
                        quotes.add(quote);
                      });

                      Flushbar(
                        duration: Duration(seconds: 2),
                        backgroundColor: ThemeColor.error,
                        message: booleanMessage.message,
                      )..show(context);
                    }
                  },
                );
              }),
        ],
      ),
    );
  }

  void fetchStarred() {
    setState(() {
      isLoading = true;
    });

    Queries.starred(context, limit, order, skip)
      .then((quotesResponse) {
        setState(() {
          quotes = quotesResponse.entries;
          isLoading = false;
        });
      })
      .catchError((err) {
        setState(() {
          error = err;
          hasErrors = true;
          isLoading = false;
        });
      });
  }
}
