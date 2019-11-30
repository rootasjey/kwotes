import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/QuoteRow.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/quotesResp.dart';

class MyPublishedQuotesScreen extends StatefulWidget {
  @override
  MyPublishedQuotesScreenState createState() => MyPublishedQuotesScreenState();
}

class MyPublishedQuotesScreenState extends State<MyPublishedQuotesScreen> {
  String lang = 'en';
  int limit = 10;
  int order = 1;
  int skip = 0;
  List<Quote> quotes = [];

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
        if (result.errors != null) {
          return ErrorComponent(description: result.errors.toString());
        }

        if (result.loading) {
          return LoadingComponent();
        }

        var response = QuotesResp.fromJSON(result.data['publishedQuotes']);
        quotes = response.entries;

        return Scaffold(
          appBar: AppBar(
            title: Text('My Published Quotes'),
          ),
          body: ListView.separated(
            itemBuilder: (context, index) {
              return QuoteRowComponent(quote: quotes[index]);
            },
            itemCount: quotes.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
          ),
        );
      },
    );
  }
}
