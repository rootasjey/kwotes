import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/medium_quote_card.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/types/quotes_response.dart';

class RecentQuotes extends StatefulWidget {
  RecentQuotesState createState() => RecentQuotesState();
}

class RecentQuotesState extends State<RecentQuotes> {
  String lang;
  int limit;
  int order;

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
        documentNode: QuoteQueries.quotes,
        variables: {'lang': lang, 'order': order},
      ),
      builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
        if (result.hasException) {
          return ErrorComponent(description: result.exception.graphqlErrors.toString(),);
        }

        if (result.loading) {
          return LoadingComponent();
        }

        var response = QuotesResponse.fromJSON(result.data['quotes']);
        var quotes = response.entries;

        return Scaffold(
          body: Swiper(
            itemCount: quotes.length,
            scale: 0.9,
            viewportFraction: 0.8,
            itemBuilder: (BuildContext context, int index) {
              return Center(
                child: MediumQuoteCard(quote: quotes.elementAt(index),)
              );
            },
          ),
        );
      },
    );
  }
}
