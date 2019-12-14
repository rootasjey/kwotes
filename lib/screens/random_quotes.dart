import 'package:flutter/material.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/types/quote.dart';

class RandomQuotes extends StatefulWidget {
  RandomQuotesState createState() => RandomQuotesState();
}

class RandomQuotesState extends State<RandomQuotes> {
  Quote quote;
  String lang = 'en';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        documentNode: parseString(queryRandomQuotes()),
        variables: {'lang': lang},
      ),
      builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
        if (result.hasException) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(result.exception.graphqlErrors.first.message),
            ],
          );
        }

        if (result.loading) {
          return LoadingComponent(
            title: 'Loading a random quote...',
            padding: EdgeInsets.all(30.0),
          );
        }

        quote = Quote.fromJSON(result.data['randomQuote']);

        return Scaffold(
          body: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 20.0, top: 50.0, right: 20.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      '${quote.name}',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: CircleAvatar(
                              backgroundImage: quote.author.imgUrl.length > 1 ?
                                NetworkImage(quote.author.imgUrl) :
                                AssetImage('assets/images/monk.png'),
                              child: Text('${quote.author.name.substring(0,1)}'),
                            ),
                          ),
                          Text(
                            '${quote.author.name}',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '${quote.references.length > 0 ? quote.references[0].name : ""}',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: RaisedButton(
                        color: Color(0xFFF56498),
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            'Refresh',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          )
                        ),
                        onPressed: () {
                          refetch();
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  String queryRandomQuotes() {
    return """
      query (\$lang: String) {
        randomQuote (lang: \$lang) {
          author {
            id
            name
          }
          id
          name
        }
      }
    """;
  }
}
