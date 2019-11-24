class Author {
  final String id;
  final String name;

  Author({this.id, this.name});

  factory Author.fromJSON(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      name: json['name'],
    );
  }
}
