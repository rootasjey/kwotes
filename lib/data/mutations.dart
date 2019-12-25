import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/data/mutationsOperations.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/types/boolean_message.dart';
import 'package:memorare/types/quotes_lists_response.dart';
import 'package:provider/provider.dart';

class UserMutations {
  static Future<QuotesListsResponse> createList({
    BuildContext context,
    String name,
    String description = ''
  }) {

    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
      documentNode: MutationsOperations.createList,
      variables: {'name': name, 'description': description},
    ))
    .then((queryResult) {
      return QuotesListsResponse.fromJSON(queryResult.data['createList']['quotesLists']);
    });
  }

  static Future<BooleanMessage> deleteList(BuildContext context, String id) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(MutationOptions(
      documentNode: MutationsOperations.deleteList,
      variables: {'id': id},
    ))
    .then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);
    })
    .catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }

  static Future<BooleanMessage> deleteTempQuote(BuildContext context, String id) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(MutationOptions(
      documentNode: MutationsOperations.deleteTempQuote,
      variables: {'id': id},
    ))
    .then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);
    })
    .catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }

  static Future<BooleanMessage> star(BuildContext context, String quoteId) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        documentNode: MutationsOperations.star,
        variables: {'quoteId': quoteId},
      )
    )
    .then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);
    })
    .catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }

  static Future<BooleanMessage> unstar(BuildContext context, String quoteId) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        documentNode: MutationsOperations.unstar,
        variables: {'quoteId': quoteId},
      )
    )
    .then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);
    })
    .catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }

  static Future<BooleanMessage> updateList(
    BuildContext context,
    String id,
    String name,
    String description,
  ) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        documentNode: MutationsOperations.updateList,
        variables: {'id': id, 'name': name, 'description': description},
      )
    ).then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);

    }).catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }

  static Future<BooleanMessage> validateTempQuote(
    BuildContext context, String id
  ) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(MutationOptions(
      documentNode: MutationsOperations.validateTempQuote,
      variables: {'id': id, 'ignoreStatus':  true},
    ))
    .then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);
    })
    .catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }
}
