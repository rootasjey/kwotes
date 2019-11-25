class Author {
  final String id;
  final String imgUrl;
  final String name;

  Author({this.id, this.imgUrl = '', this.name});

  factory Author.fromJSON(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      imgUrl: json['imgUrl'] != null ? json['imgUrl'] : '',
      name: json['name'],
    );
  }
}
