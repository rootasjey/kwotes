import 'package:gql/language.dart';
import 'package:gql/ast.dart';

class QuoteQueries {
  static DocumentNode queryTempQuotes = parseString("""
    query (\$lang: String, \$limit: Float, \$order: Float, \$skip: Float) {
      tempQuotes (lang: \$lang, limit: \$limit, order: \$order, skip: \$skip) {
        pagination {
          hasNext
          limit
          nextSkip
          skip
        }
        entries {
          id
          name
        }
      }
    }
  """);

  static DocumentNode topics = parseString("""
    query {
      randomTopics
    }
  """);
}

class QuotidianQueries {
  static DocumentNode quotidians = parseString("""
    query Quotidian {
      quotidian {
        id
        quote {
          author {
            id
            name
          }
          id
          name
          references {
            id
            name
          }
          topics
        }
      }
    }
  """);
}
