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
          pagination {
            hasNext
            limit
            nextSkip
            skip
          }
        }
      }
    }
  """);

  static DocumentNode publishedQuotes = parseString("""
    query (\$lang: String, \$limit: Float, \$order: Float, \$skip: Float) {
      publishedQuotes (lang: \$lang, limit: \$limit, order: \$order, skip: \$skip) {
        entries {
          id
          name
          topics
        }
        pagination {
          hasNext
          limit
          nextSkip
          skip
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

  static DocumentNode quotesByReferenceId = parseString("""
    query (\$id: String!) {
      quotesByReferenceId (id: \$id) {
        entries {
          author {
            id
            name
          }
          id
          name
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

  static DocumentNode randomAuthors = parseString("""
    query (\$quoteLang: String) {
      randomAuthors (quoteLang: \$quoteLang) {
        id
        imgUrl
        name
      }
    }
  """);

  static DocumentNode randomReferences = parseString("""
    query (\$quoteLang: String) {
      randomReferences (quoteLang: \$quoteLang) {
        id
        imgUrl
        name
      }
    }
  """);

  static DocumentNode reference = parseString("""
    query (\$id: String!) {
      reference (id: \$id) {
        id
        imgUrl
        lang
        linkedRefs {
          id
          name
        }
        name
        subType
        summary
        type
        url
        wikiUrl
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
          pagination {
            hasNext
            limit
            nextSkip
            skip
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

  static DocumentNode tempQuote = parseString("""
    query (\$id: String!) {
      tempQuote (id: \$id) {
        author {
          imgUrl
          job
          name
          summary
          url
          wikiUrl
        }
        comment
        id
        lang
        name
        references {
          imgUrl
          lang
          name
          subType
          summary
          type
          url
          wikiUrl
        }
        topics
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

  static DocumentNode updateEmailStepOne = parseString("""
    query (\$newEmail: String!) {
      updateEmailStepOne(newEmail: \$newEmail)
    }
  """);

  static DocumentNode userData = parseString("""
    query {
      userData {
        email
        id
        imgUrl
        lang
        name
        rights
        token
      }
    }
  """);
}

