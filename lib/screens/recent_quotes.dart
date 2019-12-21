import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/medium_quote_card.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:provider/provider.dart';

int _savedIndex = 0;

class RecentQuotes extends StatefulWidget {
  RecentQuotesState createState() => RecentQuotesState();
}

class RecentQuotesState extends State<RecentQuotes> {
  String lang = 'en';
  int limit = 10;
  int order = -1;
  int skip = 0;
  List<Quote> quotes = [];

  bool isLoading = false;
  bool hasErrors = false;
  FlutterError error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (quotes.length == 0) {
      fetchRecent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Provider.of<ThemeColor>(context).background;

    if (isLoading) {
      return LoadingComponent(
        backgroundColor: Colors.transparent,
        color: backgroundColor,
        title: 'Loading recent',
      );
    }

    if (!isLoading && hasErrors) {
      return ErrorComponent(
        title: 'Recent',
        description: error != null ? error.message : '',
      );
    }

    return Scaffold(
      body: Swiper(
        itemCount: quotes.length,
        scale: 0.9,
        viewportFraction: 0.8,
        index: _savedIndex,
        onIndexChanged: (index) {
          _savedIndex = index;
        },
        itemBuilder: (BuildContext context, int index) {
          return Center(
            child: MediumQuoteCard(
              quote: quotes.elementAt(index),
              onLike: () async {
                setState(() { // optimistic
                  quotes.elementAt(index).starred = true;
                });

                final booleanMessage = await UserMutations.star(
                  context,
                  quotes.elementAt(index).id
                );

                if (!booleanMessage.boolean) {
                  setState(() { // rollback
                    quotes.elementAt(index).starred = false;
                  });

                  Flushbar(
                    duration: Duration(seconds: 2),
                    backgroundColor: ThemeColor.error,
                    message: booleanMessage.message,
                  )..show(context);
                }

              },
              onUnlike: () async {
                setState(() { // optimistic
                  quotes.elementAt(index).starred = false;
                });

                final booleanMessage = await UserMutations.unstar(
                  context,
                  quotes.elementAt(index).id
                );

                if (!booleanMessage.boolean) {
                  setState(() { // rollback
                    quotes.elementAt(index).starred = true;
                  });

                  Flushbar(
                    duration: Duration(seconds: 2),
                    backgroundColor: ThemeColor.error,
                    message: booleanMessage.message,
                  )..show(context);
                }
              },
            )
          );
        },
      ),
    );
  }

  void fetchRecent() {
    setState(() {
      isLoading = true;
    });

    Queries.recent(context, limit, order, skip)
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
