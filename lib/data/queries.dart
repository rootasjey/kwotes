import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/data/queriesOperations.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/types/quotes_response.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:provider/provider.dart';

class Queries {
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
