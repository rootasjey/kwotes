import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/data/queriesOperations.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:provider/provider.dart';

class Queries {
  static Future<String> todayTopic(BuildContext context) async {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.todayTopics,
        )
      ).then((QueryResult queryResult) {
        final quotidian = Quotidian.fromJSON(queryResult.data['quotidian']);
        return quotidian.quote.topics.first;
      });
  }
}
