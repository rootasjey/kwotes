import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:memorare/components/empty_view.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/medium_quote_card.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quote.dart';

class QuotesByTopics extends StatefulWidget {
  final String topic;

  QuotesByTopics({this.topic});

  @override
  _QuotesByTopicsState createState() => _QuotesByTopicsState();
}

class _QuotesByTopicsState extends State<QuotesByTopics> {
  List<Quote> quotes = [];

  bool isLoading = false;
  bool hasErrors = false;
  Error error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchQuotes(widget.topic);
  }

  @override
  Widget build(BuildContext context) {
    Color topicColor = ThemeColor.topicColor(widget.topic);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.topic,
          style: TextStyle(
            color: topicColor,
            fontSize: 35.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: topicColor,),
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          if (hasErrors && !isLoading) {
            return ErrorComponent(
              description: error != null ? error.toString() : '',
            );
          }

          if (isLoading) {
            return LoadingComponent(
              title: 'Loading ${widget.topic} quotes...',
            );
          }

          if (!isLoading && quotes.length == 0) {
            return topicEmptyView(topicColor);
          }

          return Swiper(
            itemCount: quotes.length,
            scale: 0.9,
            viewportFraction: 0.8,
            itemBuilder: (BuildContext context, int index) {
              return Center(
                child: MediumQuoteCard(
                  color: topicColor,
                  quote: quotes.elementAt(index),
                  onLike: () async {
                    setState(() { // optimistic
                      quotes.elementAt(index).starred = true;
                    });

                    final booleanMessage = await Mutations.star(
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

                    final booleanMessage = await Mutations.unstar(
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
          );
        },
      )
    );
  }

  Widget topicEmptyView(Color topicColor) {
    return Scaffold(
      body: EmptyView(
          title: 'Topic quotes',
          description: 'There is no quotes in your language on the "${widget.topic}" topic',
        ),
    );
  }

  void fetchQuotes(String topic) {
    setState(() {
      isLoading = true;
    });

    Queries.quotesByTopics(context, topic)
      .then((quotesResponse) {
        setState(() {
          quotes = quotesResponse;
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
}
