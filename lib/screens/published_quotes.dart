import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/filter_fab.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/small_quote_card.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/quotes_response.dart';

class MyPublishedQuotes extends StatefulWidget {
  @override
  MyPublishedQuotesState createState() => MyPublishedQuotesState();
}

class MyPublishedQuotesState extends State<MyPublishedQuotes> {
  String lang = 'en';
  int limit = 10;
  int order = -1;
  int skip = 0;
  List<Quote> quotes = [];

  int attempts = 1;
  int maxAttempts = 2;

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: queryPublishedQuotes(),
        variables: {'lang': lang, 'limit': limit, 'order': order, 'skip': skip},
      ),
      builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
        if (result.hasErrors) {
          if (attempts < maxAttempts &&
            ErrorComponent.isJWTRelated(result.errors.first.toString())) {

            attempts++;

            ErrorComponent.trySignin(context)
              .then((errorReason) {
                if (errorReason.hasErrors) { return; }
                refetch();
              });

            return Scaffold(
              body: LoadingComponent(),
            );
          }

          return ErrorComponent(
            description: result.errors.first.toString(),
            title: 'Published Quotes',
          );
        }

        if (result.loading) {
          return Scaffold(
            body: LoadingComponent(),
          );
        }

        var response = QuotesResponse.fromJSON(result.data['publishedQuotes']);
        quotes = response.entries;

        return Scaffold(
          appBar: AppBar(
            title: Text('Published Quotes'),
          ),
          floatingActionButton: FilterFab(
            onOrderChanged: (int newOrder) {
              setState(() {
                order = newOrder;
              });
            },
            order: order,
          ),
          body: GridView.builder(
            itemCount: quotes.length,
            padding: EdgeInsets.symmetric(vertical: 20.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (BuildContext context, int index) {
              return SmallQuoteCard(quote: quotes.elementAt(index),);
            },
          ),
        );
      },
    );
  }

  String queryPublishedQuotes() {
    return """
      query (\$lang: String, \$limit: Float, \$order: Float, \$skip: Float) {
        publishedQuotes (lang: \$lang, limit: \$limit, order: \$order, skip: \$skip) {
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
  }
}
