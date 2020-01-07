import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/data/mutationsOperations.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/boolean_message.dart';
import 'package:memorare/types/error_reason.dart';
import 'package:memorare/types/quotes_list.dart';
import 'package:memorare/types/try_response.dart';
import 'package:provider/provider.dart';

class Mutations {
  static Future<BooleanMessage> addUniqToList(
    BuildContext context,
    String listId,
    String quoteId,
  ) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        documentNode: MutationsOperations.addUniqToList,
        variables: {'listId': listId, 'quoteId': quoteId},
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

  static Future<QuotesList> createList({
    BuildContext context,
    String name,
    String description = '',
    String quoteId,
  }) {

    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
      documentNode: MutationsOperations.createList,
      variables: {
        'name': name,
        'description': description,
        'quoteId': quoteId,
      },
    ))
    .then((queryResult) {
      return QuotesList.fromJSON(queryResult.data['createList']);
    });
  }

  static Future<String> createDraft({BuildContext context}) {
    final clientsModels = Provider.of<HttpClientsModel>(context);
    final client = clientsModels.defaultClient.value;

    return client.mutate(
      MutationOptions(
        documentNode: MutationsOperations.createDraft,
        variables: {
          'authorImgUrl'  : AddQuoteInputs.authorImgUrl,
          'authorName'    : AddQuoteInputs.authorName,
          'authorJob'     : AddQuoteInputs.authorJob,
          'authorSummary' : AddQuoteInputs.authorSummary,
          'authorUrl'     : AddQuoteInputs.authorUrl,
          'authorWikiUrl' : AddQuoteInputs.authorWikiUrl,
          'comment'       : AddQuoteInputs.comment,
          'lang'          : AddQuoteInputs.lang,
          'name'          : AddQuoteInputs.name,
          'topics'        : AddQuoteInputs.topics,
          'refImgUrl'     : AddQuoteInputs.refImgUrl,
          'refLang'       : AddQuoteInputs.refLang,
          'refName'       : AddQuoteInputs.refName,
          'refSubType'    : AddQuoteInputs.refSubType,
          'refSummary'    : AddQuoteInputs.refSummary,
          'refType'       : AddQuoteInputs.refType,
          'refUrl'        : AddQuoteInputs.refUrl,
          'refWikiUrl'    : AddQuoteInputs.refWikiUrl,
        }
      )
    ).then((queryResult) {
      if (queryResult.hasException) {
        return '';
      }

      String id = queryResult.data['createDraft']['id'];
      return id;
    });
  }

  static Future<BooleanMessage> createTempQuote({BuildContext context}) async {
    final clientsModels = Provider.of<HttpClientsModel>(context);
    final client = clientsModels.defaultClient.value;

    return client.mutate(
      MutationOptions(
        documentNode: MutationsOperations.createTempQuote,
        variables: {
          'authorImgUrl'  : AddQuoteInputs.authorImgUrl,
          'authorName'    : AddQuoteInputs.authorName,
          'authorJob'     : AddQuoteInputs.authorJob,
          'authorSummary' : AddQuoteInputs.authorSummary,
          'authorUrl'     : AddQuoteInputs.authorUrl,
          'authorWikiUrl' : AddQuoteInputs.authorWikiUrl,
          'comment'       : AddQuoteInputs.comment,
          'lang'          : AddQuoteInputs.lang,
          'name'          : AddQuoteInputs.name,
          'topics'        : AddQuoteInputs.topics,
          'refImgUrl'     : AddQuoteInputs.refImgUrl,
          'refLang'       : AddQuoteInputs.refLang,
          'refName'       : AddQuoteInputs.refName,
          'refSubType'    : AddQuoteInputs.refSubType,
          'refSummary'    : AddQuoteInputs.refSummary,
          'refType'       : AddQuoteInputs.refType,
          'refUrl'        : AddQuoteInputs.refUrl,
          'refWikiUrl'    : AddQuoteInputs.refWikiUrl,
        }
      )
    ).then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.length > 0 ?
            queryResult.exception.graphqlErrors.first.message :
            queryResult.exception.clientException.message,
        );
      }

      return BooleanMessage(boolean: true,);

    }).catchError((error) {
      return BooleanMessage(
        boolean: false,
        message: error.toString(),
      );
    });
  }

  static Future<TryResponse> deleteAccount(BuildContext context, String password) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
    .mutate(MutationOptions(
      documentNode: MutationsOperations.deleteAccount,
      variables: {'password': password},
    ))
    .then((queryResult) {
      if (queryResult.hasException) {
        return TryResponse(hasErrors: true, reason: ErrorReason.unknown);
      }

      return TryResponse(hasErrors: false, reason: ErrorReason.none);
    })
    .catchError((error) {
      return TryResponse(hasErrors: true, reason: ErrorReason.unknown);
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

  static Future<BooleanMessage> removeFromList(
    BuildContext context,
    String listId,
    String quoteId,
  ) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        documentNode: MutationsOperations.removeFromList,
        variables: {'listId': listId, 'quoteId': quoteId},
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

  static Future<BooleanMessage> updateDraft({BuildContext context}) async {
    final client = Provider.of<HttpClientsModel>(context).defaultClient.value;

    return client.mutate(
      MutationOptions(
        documentNode: MutationsOperations.updateDraft,
        variables: {
          'authorImgUrl'  : AddQuoteInputs.authorImgUrl,
          'authorJob'     : AddQuoteInputs.authorJob,
          'authorName'    : AddQuoteInputs.authorName,
          'authorSummary' : AddQuoteInputs.authorSummary,
          'authorUrl'     : AddQuoteInputs.authorUrl,
          'authorWikiUrl' : AddQuoteInputs.authorWikiUrl,
          'comment'       : AddQuoteInputs.comment,
          'id'            : AddQuoteInputs.draftId,
          'lang'          : AddQuoteInputs.lang,
          'name'          : AddQuoteInputs.name,
          'topics'        : AddQuoteInputs.topics,
          'refImgUrl'     : AddQuoteInputs.refImgUrl,
          'refLang'       : AddQuoteInputs.refLang,
          'refName'       : AddQuoteInputs.refName,
          'refSubType'    : AddQuoteInputs.refSubType,
          'refSummary'    : AddQuoteInputs.refSummary,
          'refType'       : AddQuoteInputs.refType,
          'refUrl'        : AddQuoteInputs.refUrl,
          'refWikiUrl'    : AddQuoteInputs.refWikiUrl,
        }
      )
    ).then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.length > 0 ?
            queryResult.exception.graphqlErrors.first.message :
            queryResult.exception.clientException.message,
        );
      }

      return BooleanMessage(boolean: true);

    }).catchError((error) {
      return BooleanMessage(
        boolean: false,
        message: error.toString(),
      );
    });
  }

  static Future<TryResponse> updateImgUrl(
    BuildContext context,
    String imgUrl,
  ) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        documentNode: MutationsOperations.updateImgUrl,
        variables: {'imgUrl': imgUrl},
      )
    ).then((queryResult) {
      Map<String, dynamic> jsonMap = queryResult.data['updateImgUrl'];

      final String imgUrl = jsonMap['imgUrl'];

      final userDataModel = Provider.of<UserDataModel>(context);

      userDataModel.setImgUrl(imgUrl);

      return TryResponse(hasErrors: false, reason: ErrorReason.none);

    }).catchError((error) {
      return TryResponse(hasErrors: true, reason: ErrorReason.unknown);
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

  static Future<String> updateName(
    BuildContext context,
    String name,
  ) {

    return Provider.of<HttpClientsModel>(context).defaultClient.value
    .mutate(
      MutationOptions(
        documentNode: MutationsOperations.updateName,
        variables: {
          'name': name,
        },
      )
    )
    .then((queryResult) {
      return queryResult.data['updateName']['name'];
    });
  }

  static Future<BooleanMessage> updatePassword(
    BuildContext context,
    String oldPassword,
    String confirmPassword,
  ) {

    return Provider.of<HttpClientsModel>(context).defaultClient.value
    .mutate(
      MutationOptions(
        documentNode: MutationsOperations.updatePassword,
        variables: {
          'oldPassword': oldPassword,
          'newPassword': confirmPassword,
        },
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
      return BooleanMessage(
        boolean: false,
        message: error.toString()
      );
    });
  }

  static Future<BooleanMessage> updateTempQuote({BuildContext context}) async {
    final client = Provider.of<HttpClientsModel>(context).defaultClient.value;

    return client.mutate(
      MutationOptions(
        documentNode: MutationsOperations.updateTempQuote,
        variables: {
          'authorImgUrl'  : AddQuoteInputs.authorImgUrl,
          'authorJob'     : AddQuoteInputs.authorJob,
          'authorName'    : AddQuoteInputs.authorName,
          'authorSummary' : AddQuoteInputs.authorSummary,
          'authorUrl'     : AddQuoteInputs.authorUrl,
          'authorWikiUrl' : AddQuoteInputs.authorWikiUrl,
          'comment'       : AddQuoteInputs.comment,
          'id'            : AddQuoteInputs.id,
          'lang'          : AddQuoteInputs.lang,
          'name'          : AddQuoteInputs.name,
          'topics'        : AddQuoteInputs.topics,
          'refImgUrl'     : AddQuoteInputs.refImgUrl,
          'refLang'       : AddQuoteInputs.refLang,
          'refName'       : AddQuoteInputs.refName,
          'refSubType'    : AddQuoteInputs.refSubType,
          'refSummary'    : AddQuoteInputs.refSummary,
          'refType'       : AddQuoteInputs.refType,
          'refUrl'        : AddQuoteInputs.refUrl,
          'refWikiUrl'    : AddQuoteInputs.refWikiUrl,
        }
      )
    ).then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.length > 0 ?
            queryResult.exception.graphqlErrors.first.message :
            queryResult.exception.clientException.message,
        );
      }

      return BooleanMessage(boolean: true);

    }).catchError((error) {
      return BooleanMessage(
        boolean: false,
        message: error.toString(),
      );
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
