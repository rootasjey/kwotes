import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queriesOperations.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/quote_page.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quotidian.dart';

enum QuoteAction { addList, like, share }

class Quotidians extends StatefulWidget {
  @override
  _QuotidiansState createState() => _QuotidiansState();
}

class _QuotidiansState extends State<Quotidians> {
  Quotidian quotidian;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Query(
        options: QueryOptions(
          documentNode: QueriesOperations.quotidians,
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

          quotidian = Quotidian.fromJSON(result.data['quotidian']);
          final quote = quotidian.quote;

          final topicColor = quote.topics.length > 0 ?
            ThemeColor.topicColor(quote.topics.first) :
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
                                return QuotePage(quoteId: quote.id,);
                              }
                            )
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
                          child: Text(
                            '${quote.name}',
                            style: TextStyle(
                              fontSize: FontSize.bigCard(quote.name),
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
                                  authorId: quote.author.id,
                                  authorName: quote.author.name,
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
                                '${quote.author.name}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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
                                size: 30.0,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.share,
                                size: 30.0,
                              ),
                              onPressed: () {},
                            ),

                            if (!quote.starred)
                              IconButton(
                                icon: Icon(
                                  Icons.favorite_border,
                                  size: 30.0,
                                ),
                                onPressed: () async {
                                  final booleanMessage = await UserMutations.star(context, quote.id);

                                  if (booleanMessage.boolean) {
                                    setState(() {
                                      quotidian.quote.starred = true;
                                    });
                                  }

                                  Flushbar(
                                    duration: Duration(seconds: 2),
                                    backgroundColor: booleanMessage.boolean ?
                                      ThemeColor.success :
                                      ThemeColor.error,
                                    message: booleanMessage.boolean ?
                                      'This quote has been added to your loved ones.':
                                      booleanMessage.message,
                                  )..show(context);
                                },
                              ),

                            if (quote.starred)
                              IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  size: 30.0,
                                ),
                                onPressed: () async {
                                  final booleanMessage = await UserMutations.unstar(context, quote.id);

                                  if (booleanMessage.boolean) {
                                    setState(() {
                                      quotidian.quote.starred = false;
                                    });
                                  }

                                  Flushbar(
                                    duration: Duration(seconds: 2),
                                    backgroundColor: booleanMessage.boolean ?
                                      ThemeColor.success :
                                      ThemeColor.error,
                                    message: booleanMessage.boolean ?
                                      'This quote has been removed from your loved ones.':
                                      booleanMessage.message,
                                  )..show(context);
                                },
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
