
import 'author.dart';

class Quote {
  final Author author;
  final String id;
  final String name;

  Quote({this.author, this.id, this.name});

  factory Quote.fromJSON(Map<String, dynamic> json) {
    return Quote(
      author: json['author'] != null ? Author.fromJSON(json['author']) : null,
      id: json['id'],
      name: json['name'],
    );
  }
}
