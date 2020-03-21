import 'author.dart';
import 'reference.dart';

class Quote {
  final Author author;
  final String id;
  final String lang;
  final String name;
  final Reference mainReference;
  /// Useful when the quote is in a list.
  final String quoteId;
  final List<Reference> references;
  bool starred;
  final List<String> topics;

  Quote({
    this.author,
    this.id,
    this.lang,
    this.name,
    this.mainReference,
    this.quoteId,
    this.references,
    this.starred = false,
    this.topics,
  });

  factory Quote.fromJSON(Map<String, dynamic> json) {
    List<Reference> _references = [];
    List<String> _topics = [];

    final _author = json['author'] != null ?
      Author.fromJSON(json['author']) : null;

    final _mainReference = json['mainReference'] != null ?
      Reference.fromJSON(json['mainReference']) : null;

    if (json['references'] != null) {
      for (var ref in json['references']) {
        _references.add(Reference.fromJSON(ref));
      }
    }

    if (json['topics'] != null) {
        if (json['topics'] is Iterable<dynamic>) {
          for (var tag in json['topics']) {
          _topics.add(tag);
        }

      } else {
        Map<String, dynamic> mapTopics = json['topics'];

        mapTopics.forEach((key, value) {
          _topics.add(key);
        });
      }
    }

    return Quote(
      author        : _author,
      id            : json['id'],
      lang          : json['lang'],
      name          : json['name'],
      mainReference : _mainReference,
      quoteId       : json['quoteId'] ?? '',
      references    : _references,
      starred       : json['starred'] ?? false,
      topics        : _topics,
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();
    List<Map<String, dynamic>> refStr = [];

    for (var ref in references) {
      refStr.add(ref.toJSON());
    }

    json['author']      = author.toJSON();
    json['id']          = id;
    json['lang']        = lang;
    json['name']        = name;
    json['quoteId']     = quoteId;
    json['references']  = refStr;
    json['starred']     = starred;
    json['topics']      = topics;

    return json;
  }
}
