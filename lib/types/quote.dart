import 'author.dart';
import 'reference.dart';

class Quote {
  final Author author;
  final String id;
  String lang;
  String name;
  final Reference reference;

  /// Match the quote's id in the 'quotes' collection.
  final String quoteId;

  bool starred;
  List<String> topics;

  Quote({
    this.author,
    this.id,
    this.lang,
    this.name,
    this.reference,
    this.quoteId,
    this.starred = false,
    this.topics,
  });

  factory Quote.empty() {
    return Quote(
      author: Author.empty(),
      id: '',
      lang: 'en',
      name: '',
      reference: Reference.empty(),
      quoteId: '',
      starred: false,
      topics: [],
    );
  }

  factory Quote.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return Quote.empty();
    }

    final author = Author.fromJSON(data['author']);
    final reference = Reference.fromJSON(data['reference']);
    final topics = parseTopics(data['topics']);

    return Quote(
      author: author,
      id: data['id'] ?? '',
      lang: data['lang'] ?? 'en',
      name: data['name'] ?? '',
      reference: reference,
      quoteId: data['quoteId'] ?? '',
      starred: data['starred'] ?? false,
      topics: topics,
    );
  }

  static List<String> parseTopics(dynamic data) {
    final topics = <String>[];

    if (data == null) {
      return topics;
    }

    if (data is Iterable<dynamic>) {
      for (String tag in data) {
        topics.add(tag);
      }

      return topics;
    }

    Map<String, dynamic> mapTopics = data;

    mapTopics.forEach((key, value) {
      topics.add(key);
    });

    return topics;
  }

  Map<String, dynamic> toJSON({
    bool withId = false,
    Author withAuthor,
    Reference withReference,
  }) {
    Map<String, dynamic> data = Map();
    final Map<String, bool> topicsMap = Map();

    for (var topic in topics) {
      topicsMap.putIfAbsent(topic, () => true);
    }

    if (withId) {
      data['id'] = id;
    }

    if (withAuthor != null) {
      data['author'] = withAuthor.toPartialJSON();
    } else {
      data['author'] = author.toPartialJSON();
    }

    if (withReference != null) {
      data['reference'] = withReference.toPartialJSON();
    } else {
      data['reference'] = reference.toPartialJSON();
    }

    data['lang'] = lang;
    data['name'] = name;
    data['topics'] = topicsMap;
    data['updatedAt'] = DateTime.now();

    return data;
  }
}
