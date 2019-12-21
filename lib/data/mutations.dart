import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/data/mutationsOperations.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/types/boolean_message.dart';
import 'package:provider/provider.dart';

class UserMutations {
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
