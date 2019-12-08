import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/quote_row.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/quotes_response.dart';

class MyPublishedQuotes extends StatefulWidget {
  @override
  MyPublishedQuotesState createState() => MyPublishedQuotesState();
}

class MyPublishedQuotesState extends State<MyPublishedQuotes> {
  String lang = 'en';
  int limit = 10;
  int order = 1;
  int skip = 0;
  List<Quote> quotes = [];

  int attempts = 1;
  int maxAttempts = 2;

  final String fetchPublishedQuotes = """
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

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: fetchPublishedQuotes,
        variables: {'lang': lang, 'order': order},
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

            return LoadingComponent();
          }

          return ErrorComponent(
            description: result.errors.first.toString(),
            title: 'My Published Quotes',
          );
        }

        if (result.loading) {
          return LoadingComponent();
        }

        var response = QuotesResponse.fromJSON(result.data['publishedQuotes']);
        quotes = response.entries;

        return Scaffold(
          appBar: AppBar(
            title: Text('My Published Quotes'),
          ),
          body: ListView.separated(
            itemBuilder: (context, index) {
              return QuoteRow(quote: quotes[index]);
            },
            itemCount: quotes.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
          ),
        );
      },
    );
  }
}
