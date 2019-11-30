import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/quoteRow.dart';
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
              return QuoteRowComponent(quote: quotes[index]);
            },
            separatorBuilder: (BuildContext context, int index) => Divider(),
          ),
        );
      },
    );
  }
}
