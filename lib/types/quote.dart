
import 'author.dart';
import 'reference.dart';

class Quote {
  final Author author;
  final String id;
  final String name;
  final List<Reference> references;

  Quote({this.author, this.id, this.name, this.references});

  factory Quote.fromJSON(Map<String, dynamic> json) {
    List<Reference> refs = [];

    if (json['references'] != null) {
      for (var ref in json['references']) {
        refs.add(Reference.fromJSON(ref));
      }
    }

    return Quote(
      author: json['author'] != null ? Author.fromJSON(json['author']) : null,
      id: json['id'],
      name: json['name'],
      references: refs,
    );
  }
}
