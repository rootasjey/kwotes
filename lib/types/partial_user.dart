class PartialUser {
  final String id;
  final String name;
  final String email;

  PartialUser({
    this.id = '',
    this.name = '',
    this.email = '',
  });

  factory PartialUser.fromJSON(Map<dynamic, dynamic> data) {
    return PartialUser(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = Map();

    data['id'] = id;
    data['name'] = name;
    data['email'] = email;

    return data;
  }
}
