import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quotidian.dart';

enum QuoteAction { addList, like, share }

class Quotidians extends StatelessWidget {
  final String fetchQuotidian = """
    query {
      quotidian {
        id
        quote {
          author {
            id
            imgUrl
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
    }
  """;

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: fetchQuotidian
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
          return LoadingComponent(
            title: 'Loading quotidians',
            padding: EdgeInsets.all(30.0),
          );
        }

        final quotidian = Quotidian.fromJSON(result.data['quotidian']);

        return Scaffold(
          body: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  bottom: 20.0,
                  left: 20.0,
                  top: 60.0,
                  right: 20.0
                ),
                child: Card(
                  color: quotidian.quote.topics.length > 0 ?
                    ThemeColor.topicColor(quotidian.quote.topics.first) :
                    ThemeColor.primary,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 50.0
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          '${quotidian.quote.name}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: FontSize.bigCard(quotidian.quote.name),
                            fontWeight: FontWeight.bold
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 40.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '${quotidian.quote.author.name}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.favorite_border, color: Colors.white60,),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.playlist_add, color: Colors.white60,),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.share, color: Colors.white60,),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
