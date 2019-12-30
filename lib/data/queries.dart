import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/data/queriesOperations.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/boolean_message.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/quotes_list.dart';
import 'package:memorare/types/quotes_lists_response.dart';
import 'package:memorare/types/quotes_response.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:memorare/types/quotodians_response.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/types/temp_quotes_response.dart';
import 'package:memorare/types/user_data.dart';
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

  static Future<QuotesListsResponse> lists(
    BuildContext context, int limit, int order, int skip,
  ) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.lists,
          variables: {'limit': limit, 'order': order, 'skip': skip},
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        return QuotesListsResponse.fromJSON(queryResult.data['userData']['quotesLists']);
      });
  }

  static Future<QuotesList> listById(
    BuildContext context, String id,
  ) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.listById,
          variables: {'id': id },
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        return QuotesList.fromJSON(queryResult.data['listById']);
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

  static Future<QuotesResponse> quotesByReference(
    BuildContext context, String id,
  ) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.quotesByReferenceId,
          variables: {'id': id },
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        return QuotesResponse.fromJSON(queryResult.data['quotesByReferenceId']);
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

  static Future<QuotidiansResponse> quotidians(BuildContext context) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.quotidians,
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        if(queryResult.hasException && queryResult.exception?.clientException != null) {
          return null;
        }

        return QuotidiansResponse.fromJSON(queryResult.data['quotidians']);
      });
  }

  static Future<List<Author>> randomAuthors(BuildContext context, String quoteLang) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.randomAuthors,
          variables: {'quoteLang': quoteLang},
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        if(queryResult.hasException && queryResult.exception?.clientException != null) {
          return null;
        }

        List<Author> authors = [];
        Map<String, dynamic> json = queryResult.data;

        for (var authorData in json['randomAuthors']) {
          authors.add(Author.fromJSON(authorData));
        }

        return authors;
      });
  }

  static Future<List<Reference>> randomReferences(BuildContext context, String quoteLang) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.randomReferences,
          variables: {'quoteLang': quoteLang},
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        if(queryResult.hasException && queryResult.exception?.clientException != null) {
          return null;
        }

        List<Reference> references = [];
        Map<String, dynamic> json = queryResult.data;

        for (var refenreceData in json['randomReferences']) {
          references.add(Reference.fromJSON(refenreceData));
        }

        return references;
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

  static Future<Reference> reference(
    BuildContext context, String id,
  ) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .query(
        QueryOptions(
          documentNode: QueriesOperations.reference,
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
        )
      ).then((QueryResult queryResult) {
        return Reference.fromJSON(queryResult.data['reference']);
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

  static Future<List<String>> topics(BuildContext context) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
    .query(
      QueryOptions(
        documentNode: QueriesOperations.topics,
        fetchPolicy: FetchPolicy.networkOnly,
      )
    )
    .then((queryResult) {
      final json = queryResult.data;
      List<String> topics = [];

      for (var str in json['randomTopics']) {
        topics.add(str);
      }

      return topics;
    });
  }

  static Future<BooleanMessage> updateEmailStepOne(BuildContext context, String newEmail) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .mutate(
      MutationOptions(
        documentNode: QueriesOperations.updateEmailStepOne,
        variables: {'newEmail': newEmail},
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

  static Future<UserData> userData(BuildContext context) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
      .mutate(
      MutationOptions(
        documentNode: QueriesOperations.userData,
      )
    )
    .then((queryResult) {
      return UserData.fromJSON(queryResult.data['userData']);
    });
  }
}
