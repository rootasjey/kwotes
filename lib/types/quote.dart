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
    List<String> _topics = [];

    Author _author;
    if (data['author'] != null) {
      _author = Author.fromJSON(data['author']);
    }

    Reference _reference;
    if (data['reference'] != null) {
      Reference.fromJSON(data['reference']);
    }

    if (data['topics'] != null) {
      if (data['topics'] is Iterable<dynamic>) {
        for (var tag in data['topics']) {
          _topics.add(tag);
        }
      } else {
        Map<String, dynamic> mapTopics = data['topics'];

        mapTopics.forEach((key, value) {
          _topics.add(key);
        });
      }
    }

    return Quote(
      author: _author,
      id: data['id'],
      lang: data['lang'],
      name: data['name'],
      reference: _reference,
      quoteId: data['quoteId'] ?? '',
      starred: data['starred'] ?? false,
      topics: _topics,
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();

    json['author'] = author.toJSON();
    json['id'] = id;
    json['lang'] = lang;
    json['name'] = name;
    json['reference'] = reference.toJSON();
    json['quoteId'] = quoteId;
    json['starred'] = starred;
    json['topics'] = topics;

    return json;
  }
}
