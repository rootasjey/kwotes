import 'package:memorare/types/reference.dart';
import 'package:memorare/types/temp_author.dart';

class TempQuote {
  final TempAuthor author;
  final String comment;
  final String id;
  final String lang;
  final String name;
  final List<Reference> references;
  final List<String> topics;

  TempQuote({
    this.author,
    this.comment,
    this.id,
    this.lang,
    this.name,
    this.references,
    this.topics,
  });

  factory TempQuote.fromJSON(Map<String, dynamic> json) {
    List<Reference> referencesList = [];
    List<String> topicsList = [];

    if (json['references'] != null) {
      for (var ref in json['references']) {
        referencesList.add(Reference.fromJSON(ref));
      }
    }

    if (json['topics'] != null) {
      for (var tag in json['topics']) {
        topicsList.add(tag);
      }
    }

    return TempQuote(
      author: json['author'] != null ? TempAuthor.fromJSON(json['author']): null,
      comment: json['comment'],
      id: json['id'],
      lang: json['lang'],
      name: json['name'],
      references: referencesList,
      topics: topicsList,
    );
  }
}
