import "dart:convert";

import "package:kwotes/globals/utils.dart";

/// A list of quotes created by a user.
class QuoteList {
  QuoteList({
    required this.createdAt,
    required this.description,
    required this.id,
    required this.name,
    required this.isPublic,
    required this.updatedAt,
  });

  /// True if this list is public.
  final bool isPublic;

  /// When this list was created.
  final DateTime createdAt;

  /// Last time this list was updated.
  final DateTime updatedAt;

  /// List's description.
  final String description;

  /// List's id.
  final String id;

  /// List's name.
  final String name;

  QuoteList copyWith({
    DateTime? createdAt,
    String? description,
    String? iconUrl,
    String? id,
    String? name,
    bool? isPublic,
    DateTime? updatedAt,
  }) {
    return QuoteList(
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      id: id ?? this.id,
      name: name ?? this.name,
      isPublic: isPublic ?? this.isPublic,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "description": description,
      "name": name,
      "is_public": isPublic,
    };
  }

  /// Convert the current instance to a map suitable to update.
  Map<String, dynamic> toMapUpdate() {
    return <String, dynamic>{
      "description": description,
      "name": name,
      "is_public": isPublic,
    };
  }

  factory QuoteList.empty() {
    return QuoteList(
      createdAt: DateTime.now(),
      description: "",
      id: "",
      name: "",
      isPublic: false,
      updatedAt: DateTime.now(),
    );
  }

  factory QuoteList.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return QuoteList.empty();
    }

    return QuoteList(
      createdAt: Utils.tictac.fromFirestore(map["created_at"]),
      description: map["description"] ?? "",
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      isPublic: map["is_public"] ?? false,
      updatedAt: Utils.tictac.fromFirestore(map["updated_at"]),
    );
  }

  String toJson() => json.encode(toMap());

  factory QuoteList.fromJson(String source) =>
      QuoteList.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "QuoteList(createdAt: $createdAt, description: $description, "
        "id: $id, name: $name, isPublic: $isPublic, "
        "updatedAt: $updatedAt)";
  }

  @override
  bool operator ==(covariant QuoteList other) {
    if (identical(this, other)) return true;

    return other.createdAt == createdAt &&
        other.description == description &&
        other.id == id &&
        other.name == name &&
        other.isPublic == isPublic &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        description.hashCode ^
        id.hashCode ^
        name.hashCode ^
        isPublic.hashCode ^
        updatedAt.hashCode;
  }
}
