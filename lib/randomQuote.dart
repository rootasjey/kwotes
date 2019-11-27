import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'types/quote.dart';

class RandomQuoteWidget extends StatefulWidget {
  RandomQuoteWidgetState createState() => RandomQuoteWidgetState();
}

class RandomQuoteWidgetState extends State<RandomQuoteWidget> {
  Quote quote;
  String lang = 'en';
  bool loaded = false;

  final String fetchRandom = """
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: fetchRandom,
        variables: {'lang': lang},
      ),
      builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
        if (result.errors != null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(result.errors.toString()),
            ],
          );
        }

        if (result.loading) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Loading...'),
            ],
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
}
