import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/empty_view.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/medium_quote_card.dart';
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

  @override
  Widget build(BuildContext context) {
    Color topicColor = ThemeColor.topicColor(widget.topic);

    return Scaffold(
      body: Query(
        options: QueryOptions(
          documentNode: parseString(queryQuotes()),
          variables: {'topics': [widget.topic]},
        ),
        builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            return ErrorComponent(
              description: result.exception.graphqlErrors.first.message,
            );
          }

          if (result.loading) {
            return LoadingComponent(
              title: 'Loading ${widget.topic} quotes...',
              padding: EdgeInsets.all(30.0),
            );
          }

          Map<String, dynamic> json = result.data;

          for (var jsonQuote in json['quotesByTopics']) {
            quotes.add(Quote.fromJSON(jsonQuote));
          }

          if (quotes.length == 0) {
            return Center(
              child: EmptyView(
                title: 'Topic quotes',
                description: 'There is no quotes in this language on the "${widget.topic}" topic',
              ),
            );
          }

          return Stack(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Text(
                      widget.topic,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: topicColor,
                        fontSize: 35.0,
                      ),
                    ),
                  )
                ],
              ),

              Swiper(
                itemCount: quotes.length,
                scale: 0.9,
                viewportFraction: 0.8,
                itemBuilder: (BuildContext context, int index) {
                  return Center(
                    child: MediumQuoteCard(
                      quote: quotes.elementAt(index),
                      color: topicColor,
                    )
                  );
                },
              ),

              Positioned(
                left: 5.0,
                top: 35.0,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back, color: topicColor,),
                  ),
                )
              ),
            ],
          );
        },
      ),
    );
  }

  String queryQuotes() {
    return """
      query (\$topics: [String!]!) {
        quotesByTopics (topics: \$topics) {
          id
          name
          author {
            id
            name
          }
        }
      }
    """;
  }
}
