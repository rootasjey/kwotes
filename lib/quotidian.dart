
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/types/quotidian.dart';

enum QuoteAction { addList, like, share }

class QuotidianWidget extends StatelessWidget {
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
          return Text(result.errors.toString());
        }

        if (result.loading) {
          return Text('Loading...');
        }

        var quotidian = Quotidian.fromJSON(result.data['quotidian']);

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Color(0xFF706FD3)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${quotidian.quote.name}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: CircleAvatar(
                                  backgroundColor: Color(0xFFF56098),
                                  backgroundImage: quotidian.quote.author.imgUrl.length > 1 ?
                                    NetworkImage(quotidian.quote.author.imgUrl) :
                                    AssetImage('assets/images/monk.png'),
                                  child: Text('${quotidian.quote.author.name.substring(0,1)}'),
                                ),
                              ),
                              Text(
                                '${quotidian.quote.author.name}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${quotidian.quote.references.length > 0 ? quotidian.quote.references[0].name : ""}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            PopupMenuButton(
                              icon: Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                                size: 40,
                                semanticLabel: 'Open quote actions',
                              ),
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<QuoteAction>>[
                                const PopupMenuItem<QuoteAction>(
                                  value: QuoteAction.like,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.favorite_border,
                                      size: 25,
                                    ),
                                    title: Text('Favorite'),
                                  )
                                ),
                                const PopupMenuItem<QuoteAction>(
                                  value: QuoteAction.addList,
                                  child: ListTile(
                                      leading: Icon(
                                      Icons.list,
                                      size: 25,
                                    ),
                                    title: Text('Add to...'),
                                  )
                                ),
                                const PopupMenuItem<QuoteAction>(
                                  value: QuoteAction.share,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.share,
                                      size: 25,
                                    ),
                                    title: Text('Share'),
                                  )
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    padding: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
                  )
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
