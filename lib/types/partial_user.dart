class PartialUser {
  final String id;
  final String name;

  PartialUser({this.id, this.name});

  factory PartialUser.fromJSON(Map<String, dynamic> json) {
    return PartialUser(
      id  : json['id'],
      name: json['name'],
    );
  }
}
