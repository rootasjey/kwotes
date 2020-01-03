import 'package:gql/language.dart';
import 'package:gql/ast.dart';

class MutationsOperations {

  static DocumentNode addUniqToList = parseString("""
    mutation (\$listId: String!, \$quoteId: String!) {
      addUniqToList (listId:\$listId, quoteId: \$quoteId) {
        isUniq
      }
    }
  """);

  static DocumentNode createList = parseString("""
    mutation (\$name: String!, \$description: String, \$quoteId: String) {
      createList (name: \$name, description: \$description, quoteId: \$quoteId) {
        id
        name
        description
      }
    }
  """);

  static DocumentNode createTempQuote = parseString("""
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
      \$refSummary: String
      \$refSubType: String
      \$refType: String
      \$refWikiUrl: String
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
        refSummary:\$refSummary
        refSubType:\$refSubType
        refType:\$refType
        refWikiUrl:\$refWikiUrl
        refUrl:\$refUrl
        topics: \$topics
      ) {
        id
      }
    }
  """);

  static DocumentNode deleteAccount = parseString("""
    mutation (\$password: String!) {
        deleteAccount(password: \$password) {
          id
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
      deleteTempQuote (id: \$id) {
        id
      }
    }
  """);

  static DocumentNode removeFromList = parseString("""
    mutation (\$listId: String!, \$quoteId: String!) {
      removeFromList (listId:\$listId, quoteId: \$quoteId) {
        id
      }
    }
  """);

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

  static DocumentNode updateImgUrl = parseString("""
    mutation (\$imgUrl: String!) {
      updateImgUrl(imgUrl: \$imgUrl) {
        imgUrl
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

  static DocumentNode updateName = parseString("""
    mutation (\$name: String!) {
      updateName(name: \$name) {
        name
      }
    }
  """);

  static DocumentNode updatePassword = parseString("""
    mutation (\$oldPassword: String!, \$newPassword: String!) {
      updatePassword(oldPassword: \$oldPassword, newPassword: \$newPassword) {
        id
      }
    }
  """);

  static DocumentNode updateTempQuote = parseString("""
    mutation (
      \$authorImgUrl: String
      \$authorName: String
      \$authorJob: String
      \$authorSummary: String
      \$authorUrl: String
      \$authorWikiUrl: String
      \$comment: String
      \$id: String!
      \$lang: String
      \$name: String!
      \$origin: String
      \$refImgUrl: String
      \$refLang: String
      \$refName: String
      \$refSummary: String
      \$refSubType: String
      \$refType: String
      \$refWikiUrl: String
      \$refUrl: String
      \$topics: [String!]
    ) {
      updateTempQuote(
        authorImgUrl: \$authorImgUrl
        authorName: \$authorName
        authorJob: \$authorJob
        authorSummary: \$authorSummary
        authorUrl: \$authorUrl
        authorWikiUrl: \$authorWikiUrl
        comment: \$comment
        id: \$id
        lang: \$lang
        name:\$name
        origin: \$origin
        refImgUrl: \$refImgUrl
        refLang:\$refLang
        refName:\$refName
        refSummary:\$refSummary
        refSubType:\$refSubType
        refType:\$refType
        refWikiUrl:\$refWikiUrl
        refUrl:\$refUrl
        topics: \$topics
      ) {
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
