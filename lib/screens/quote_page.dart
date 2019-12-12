import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';

class QuotePage extends StatefulWidget {
  final String quoteId;

  QuotePage({this.quoteId});

  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  Quote quote;
  Color topicColor;

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: queryQuote(),
        variables: {'id': widget.quoteId},
      ),
      builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
        if (result.errors != null) {
          if (result.errors.first.message.contains('No host specified in URI')) {
            return LoadingComponent(
              title: 'Loading quotidians',
              padding: EdgeInsets.all(30.0),
            );
          }

          return ErrorComponent(
            description: result.errors.first.message,
            title: 'Quotidians',
          );
        }

        if (result.loading) {
          return Scaffold(body:
            LoadingComponent(
              title: 'Fetching quote...',
              padding: EdgeInsets.all(30.0),
            ),
          );
        }

        quote = Quote.fromJSON(result.data['quote']);

        topicColor = quote.topics.length > 0 ?
          ThemeColor.topicColor(quote.topics.first) :
          ThemeColor.primary;

        return Scaffold(
          body: ListView(
            padding: EdgeInsets.only(bottom: 70.0),
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0,),
                        color: topicColor,
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Card(
                              color: ThemeColor.lighten(topicColor),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30.0,
                                  vertical: 50.0
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      '${quote.name}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: FontSize.bigCard(quote.name),
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '${quote.author.name}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (quote.references.length > 0)
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                quote.references.first.name,
                                style: TextStyle(),
                              ),
                            ],
                          ),
                        ),

                      if (quote.topics.length > 0)
                        SizedBox(
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              padding: EdgeInsets.all(10.0),
                              itemCount: quote.topics.length,
                              itemBuilder: (BuildContext context, int index) {
                                final topic = quote.topics.elementAt(index);
                                final chipColor = ThemeColor.topicColor(topic);

                                return Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Chip(
                                    backgroundColor: chipColor,
                                    labelPadding: EdgeInsets.all(5.0),
                                    label: Text(
                                      topic,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              padding: EdgeInsets.all(16.0),
                              iconSize: 40.0,
                              icon: Icon(Icons.favorite_border,),
                              onPressed: () {},
                            ),
                            IconButton(
                              padding: EdgeInsets.all(16.0),
                              iconSize: 40.0,
                              icon: Icon(Icons.playlist_add,),
                              onPressed: () {},
                            ),
                            IconButton(
                              padding: EdgeInsets.all(16.0),
                              iconSize: 40.0,
                              icon: Icon(Icons.share,),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Positioned(
                    left: 5.0,
                    top: 20.0,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back, color: Colors.white,),
                      ),
                    )
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String queryQuote() {
    return """
      query (\$id: String!) {
        quote (id: \$id) {
          author {
            id
            name
          }
          id
          name
          references {
            id
            name
          }
          topics
        }
      }
    """;
  }
}
