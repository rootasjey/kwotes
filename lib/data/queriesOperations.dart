import 'package:gql/language.dart';
import 'package:gql/ast.dart';

class QueriesOperations {
  static DocumentNode author = parseString("""
    query (\$id: String!) {
      author (id: \$id) {
        id
        imgUrl
        job
        name
        summary
        url
        wikiUrl
      }
    }
  """);

  static DocumentNode listById = parseString("""
    query (\$id: String!) {
      listById(id: \$id) {
        id
        name
        description
        quotes {
          entries {
            id
            name
            topics
          }
        }
      }
    }
  """);

  static DocumentNode lists = parseString("""
    query (\$limit: Float, \$order: Float, \$skip: Float) {
      userData {
        quotesLists (limit: \$limit, order: \$order, skip: \$skip) {
          entries {
            id
            description
            name
          }
        }
      }
    }
  """);

  static DocumentNode publishedQuotes = parseString("""
    query (\$lang: String, \$limit: Float, \$order: Float, \$skip: Float) {
      publishedQuotes (lang: \$lang, limit: \$limit, order: \$order, skip: \$skip) {
        pagination {
          hasNext
          limit
          nextSkip
          skip
        }
        entries {
          id
          name
          topics
        }
      }
    }
  """);

  static DocumentNode quote = parseString("""
    query (\$id: String!) {
      quote (id: \$id) {
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
        starred
        topics
      }
    }
  """);

  static DocumentNode quotes = parseString("""
    query (\$lang: String, \$limit: Float, \$order: Float) {
      quotes (lang: \$lang, limit: \$limit, order: \$order) {
        pagination {
          hasNext
          limit
          nextSkip
          skip
        }
        entries {
          author {
            id
            name
          }
          id
          name
          starred
          topics
        }
      }
    }
  """);

  static DocumentNode quotesByAuthorId = parseString("""
    query (\$id: String!) {
      quotesByAuthorId (id: \$id) {
        entries {
          id
          name
          references {
            name
          }
          topics
        }
        pagination {
          limit
          nextSkip
          skip
        }
      }
    }
  """);

  static DocumentNode quotesByTopics = parseString("""
    query (\$topics: [String!]!) {
      quotesByTopics (topics: \$topics) {
        id
        name
        author {
          id
          name
        }
      }
    }
  """);

  static DocumentNode quotidian = parseString("""
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
          starred
          topics
        }
      }
    }
  """);

  static DocumentNode quotidians = parseString("""
    query {
      quotidians {
        entries {
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
            starred
            topics
          }
        }
      }
    }
  """);

  static DocumentNode starred = parseString("""
    query (\$limit: Float, \$order: Float, \$skip: Float) {
      userData {
        starred (limit: \$limit, order: \$order, skip: \$skip) {
          entries {
            id
            name
            topics
          }
        }
      }
    }
  """);

  static DocumentNode tempQuotes = parseString("""
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

  static DocumentNode todayTopics = parseString("""
    query {
      quotidian {
        quote {
          topics
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

