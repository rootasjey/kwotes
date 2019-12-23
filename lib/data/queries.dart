import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/data/queriesOperations.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/quotes_response.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:memorare/types/temp_quotes_response.dart';
import 'package:provider/provider.dart';

class Queries {
  static Future<Author> author(
    BuildContext context, String id,
  ) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.author,
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        return Author.fromJSON(queryResult.data['author']);
      });
  }

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

  static Future<TempQuotesResponse> myTempQuotes(
    BuildContext context, String lang, int limit, int order, int skip,
  ) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.tempQuotes,
          variables: {'lang': lang, 'limit': limit, 'order': order, 'skip': skip},
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        return TempQuotesResponse.fromJSON(queryResult.data['tempQuotes']);
      });
  }

  static Future<Quote> quote(BuildContext context, String id) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.quote,
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        if(queryResult.hasException && queryResult.exception?.clientException != null) {
          return null;
        }

        return Quote.fromJSON(queryResult.data['quote']);
      });
  }

  static Future<QuotesResponse> quotesByAuthor(
    BuildContext context, String id,
  ) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.quotesByAuthorId,
          variables: {'id': id },
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        return QuotesResponse.fromJSON(queryResult.data['quotesByAuthorId']);
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
