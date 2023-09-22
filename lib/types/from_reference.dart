// ignore_for_file: public_member_api_docs, sort_constructors_first
import "dart:convert";

class FromReference {
  FromReference({
    required this.id,
    required this.name,
  });

  /// Reference's id to which the author belongs to.
  String id;

  /// Reference's name.
  /// This property doesn't exist in Firestore,
  /// and is used mainly when editing author
  /// (better indication to which reference the author belongs to).
  String name;

  FromReference copyWith({
    String? id,
    String? name,
  }) {
    return FromReference(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "name": name,
    };
  }

  factory FromReference.empty() {
    return FromReference(
      id: "",
      name: "",
    );
  }

  factory FromReference.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return FromReference.empty();
    }

    return FromReference(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory FromReference.fromJson(String source) =>
      FromReference.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => "FromReference(id: $id, name: $name)";

  @override
  bool operator ==(covariant FromReference other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
