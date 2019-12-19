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

}
