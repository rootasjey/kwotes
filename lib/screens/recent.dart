import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/types/quotesResp.dart';

class RecentScreen extends StatefulWidget {
  RecentScreenState createState() => RecentScreenState();
}

class RecentScreenState extends State<RecentScreen> {
  String lang;
  int limit;
  int order;

  final String fetchRecent = """
    query (\$lang: String, \$limit: Float, \$order: Float) {
      quotes (lang: \$lang, limit: \$limit, order: \$order) {
        pagination {
          hasNext
          limit
          nextSkip
          skip
        }
        entries {
          author {
            id
            name
          }
          id
          name
        }
      }
    }
  """;

  @override
  void initState() {
    super.initState();
    setState(() {
      lang = 'en';
      limit = 10;
      order = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: fetchRecent,
        variables: {'lang': lang, 'order': order},
      ),
      builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
        if (result.errors != null) {
          return ErrorComponent(description: result.errors.toString(),);
        }

        if (result.loading) {
          return LoadingComponent();
        }

        var response = QuotesResp.fromJSON(result.data['quotes']);
        var quotes = response.entries;

        return Scaffold(
          body: ListView.separated(
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              return InkWell(
                child: Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        onLongPress: () {
                          print('Copy quote name to clipboard.');
                        },
                        onTap: () {
                          print('quote tapped: ${quotes[index].id}');
                        },
                        title: Text(
                          quotes[index].name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20.0, left: 15.0),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: CircleAvatar(
                                  backgroundColor: Color(0xFFF56098),
                                  backgroundImage: quotes[index].author.imgUrl.length > 1 ?
                                    NetworkImage(quotes[index].author.imgUrl) :
                                    AssetImage('assets/images/monk.png'),
                                  child: Text('${quotes[index].author.name.substring(0,1)}'),
                                ),
                              ),
                              Text(
                                '${quotes[index].author.name}',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          print('Navigate to author ${quotes[index].author.id}');
                        },
                      ),
                    ],
                  ),
                ),
                onLongPress: () {
                  print('show actions ui');
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) => Divider(),
          ),
        );
      },
    );
  }
}
