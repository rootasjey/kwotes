import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/data/queriesOperations.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/quotes_response.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:provider/provider.dart';

class Queries {
  static Future<QuotesResponse> myPublihshedQuotes(
    BuildContext context, String lang, int limit, int order, int skip,
  ) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.publishedQuotes,
          variables: {'lang': lang, 'limit': limit, 'order': order, 'skip': skip},
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        return QuotesResponse.fromJSON(queryResult.data['publishedQuotes']);
      });
  }

  static Future<List<Quote>> quotesByTopics(
    BuildContext context, String topic,
  ) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.quotesByTopics,
          variables: {'topics': [topic]},
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        List<Quote> quotes = [];
        Map<String, dynamic> json = queryResult.data;

        for (var jsonQuote in json['quotesByTopics']) {
          quotes.add(Quote.fromJSON(jsonQuote));
        }

        return quotes;
      });
  }

  static Future<Quotidian> quotidian(BuildContext context) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.quotidian,
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        if(queryResult.hasException && queryResult.exception?.clientException != null) {
          return null;
        }

        return Quotidian.fromJSON(queryResult.data['quotidian']);
      });
  }

  static Future<QuotesResponse> recent(
    BuildContext context, int limit, int order, int skip,
  ) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.quotes,
          variables: {'limit': limit, 'order': order, 'skip': skip},
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        return QuotesResponse.fromJSON(queryResult.data['quotes']);
      });
  }

  static Future<QuotesResponse> starred(
    BuildContext context, int limit, int order, int skip,
  ) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.starred,
          variables: {'limit': limit, 'order': order, 'skip': skip},
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        return QuotesResponse.fromJSON(queryResult.data['userData']['starred']);
      });
  }

  static Future<String> todayTopic(BuildContext context) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.todayTopics,
        )
      ).then((QueryResult queryResult) {
        if (queryResult.hasException) { return ''; }

        final quotidian = Quotidian.fromJSON(queryResult.data['quotidian']);
        return quotidian.quote.topics.first;
      });
  }
}
