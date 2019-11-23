
class Quote {
  final String id;
  final String name;

  Quote({this.id, this.name});

  factory Quote.fromJSON(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      name: json['name'],
    );
  }
}
