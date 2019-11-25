class Reference {
  final String id;
  final String name;

  Reference({this.id, this.name});

  factory Reference.fromJSON(Map<String, dynamic> json) {
    return Reference(
      id: json['id'],
      name: json['name'],
    );
  }
}
