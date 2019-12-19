import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/quote_page.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quotidian.dart';

enum QuoteAction { addList, like, share }

class Quotidians extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Query(
        options: QueryOptions(
          documentNode: QuotidianQueries.quotidians,
        ),
        builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
          if (result.hasException) {
            final exception = result.exception;

            if (exception.clientException
              .message.contains('No host specified in URI')) {

              return LoadingComponent(
                title: 'Loading quotidians',
                padding: EdgeInsets.all(30.0),
              );
            }

            return ErrorComponent(
              description: exception.graphqlErrors.first.message,
              title: 'Quotidians',
            );
          }

          if (result.loading) {
            return LoadingComponent(
              title: 'Loading quotidians',
              padding: EdgeInsets.all(30.0),
            );
          }

          final quotidian = Quotidian.fromJSON(result.data['quotidian']);

          final topicColor = quotidian.quote.topics.length > 0 ?
            ThemeColor.topicColor(quotidian.quote.topics.first) :
            ThemeColor.primary;

          return Center(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(25.0),
              children: <Widget>[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide(
                      color: topicColor,
                      width: 5.0,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return QuotePage(quoteId: quotidian.quote.id,);
                              }
                            )
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
                          child: Text(
                            '${quotidian.quote.name}',
                            style: TextStyle(
                              fontSize: FontSize.bigCard(quotidian.quote.name),
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        )
                      ),

                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return AuthorPage(
                                  authorId: quotidian.quote.author.id,
                                  authorName: quotidian.quote.author.name,
                                );
                              }
                            )
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '${quotidian.quote.author.name}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (quotidian.quote.references.length > 0)
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                quotidian.quote.references.first.name,
                                style: TextStyle(
                                ),
                              ),
                            ],
                          ),
                        ),

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.playlist_add,
                                // color: Colors.white60,
                                size: 30.0,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.share,
                                // color: Colors.white60,
                                size: 30.0,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.favorite_border,
                                // color: Colors.white60,
                                size: 30.0,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}
