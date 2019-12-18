import 'package:gql/language.dart';
import 'package:gql/ast.dart';

class Mutations {
  static MutationsQuote quote;
}

class MutationsQuote {
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
  """);
}
