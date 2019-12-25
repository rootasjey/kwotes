import 'package:gql/language.dart';
import 'package:gql/ast.dart';

class MutationsOperations {
  static DocumentNode createList = parseString("""
    mutation (\$name: String!, \$description: String, \$quoteId: String) {
      createList (name: \$name, description: \$description, quoteId: \$quoteId) {
        quotesLists {
          entries {
            id
            name
            description
          }
        }
      }
    }
  """);

  static DocumentNode deleteList = parseString("""
    mutation (\$id: String!) {
      deleteList (id: \$id) {
        id
      }
    }
  """);

  static DocumentNode deleteTempQuote = parseString("""
    mutation (\$id: String!) {
      deleteTempQuoteAdmin (id: \$id) {
        id
      }
    }
  """);

  static DocumentNode propose = parseString("""
    mutation (
      \$authorImgUrl: String
      \$authorName: String
      \$authorJob: String
      \$authorSummary: String
      \$authorUrl: String
      \$authorWikiUrl: String
      \$comment: String
      \$lang: String
      \$name: String!
      \$origin: String
      \$refImgUrl: String
      \$refLang: String
      \$refName: String
      \$refPromoUrl: String
      \$refSummary: String
      \$refSubType: String
      \$refType: String
      \$refUrl: String
      \$topics: [String!]
    ) {
      createTempQuote(
        authorImgUrl: \$authorImgUrl
        authorName: \$authorName
        authorJob: \$authorJob
        authorSummary: \$authorSummary
        authorUrl: \$authorUrl
        authorWikiUrl: \$authorWikiUrl
        comment: \$comment
        lang: \$lang
        name:\$name
        origin: \$origin
        refImgUrl: \$refImgUrl
        refLang:\$refLang
        refName:\$refName
        refPromoUrl:\$refPromoUrl
        refSummary:\$refSummary
        refSubType:\$refSubType
        refType:\$refType
        refUrl:\$refUrl
        topics: \$topics
      ) {
        id
      }
    }
  """
  );

  static DocumentNode star = parseString("""
    mutation (\$quoteId: String!) {
      star (quoteId: \$quoteId) {
        id
      }
    }
  """);

  static DocumentNode unstar = parseString("""
    mutation (\$quoteId: String!) {
      unstar (quoteId: \$quoteId) {
        id
      }
    }
  """);

  static DocumentNode updateList = parseString("""
    mutation (\$id: String!, \$name: String, \$description: String) {
      updateList (id: \$id, name: \$name, description: \$description) {
        id
      }
    }
  """);

  static DocumentNode validateTempQuote = parseString("""
    mutation (\$id: String!, \$ignoreStatus: Boolean) {
      validateTempQuoteAdmin (id: \$id, ignoreStatus: \$ignoreStatus) {
        id
      }
    }
  """);
}
