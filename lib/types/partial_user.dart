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
}
