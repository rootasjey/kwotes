import "dart:convert";

import "package:flutter/foundation.dart";
import "package:kwotes/globals/utils.dart";

class RandomQuoteDocument {
  RandomQuoteDocument({
    required this.createdAt,
    required this.updatedAt,
    required this.index,
    required this.id,
    required this.language,
    required this.type,
    required this.items,
  });

  /// When this document was created.
  final DateTime createdAt;

  /// Last time this document was updated.
  final DateTime updatedAt;

  /// Document index order (first, second, ...).
  final int index;

  /// Document unique identifier (custom generated).
  final String id;

  /// The language of the quotes.
  final String language;

  /// What type of data this document contains.
  final String type;

  /// List of quotes.
  final List<String> items;

  RandomQuoteDocument copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    int? index,
    String? id,
    String? language,
    String? type,
    List<String>? items,
  }) {
    return RandomQuoteDocument(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      index: index ?? this.index,
      id: id ?? this.id,
      language: language ?? this.language,
      type: type ?? this.type,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "created_at": createdAt.millisecondsSinceEpoch,
      "updated_at": updatedAt.millisecondsSinceEpoch,
      "index": index,
      "language": language,
      "type": type,
      "items": items,
    };
  }

  factory RandomQuoteDocument.fromMap(Map<String, dynamic> map) {
    return RandomQuoteDocument(
      createdAt: Utils.tictac.fromFirestore(map["created_at"]),
      updatedAt: Utils.tictac.fromFirestore(map["updated_at"]),
      index: map["index"] ?? 0,
      id: map["id"] ?? "",
      language: map["language"] ?? "en",
      type: map["type"] ?? "",
      items: List<String>.from(
        (map["items"] ?? []),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory RandomQuoteDocument.fromJson(String source) =>
      RandomQuoteDocument.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "RandomQuoteDocument(createdAt: $createdAt, updatedAt: $updatedAt, "
        "index: $index, id: $id, language: $language, type: $type, "
        "items: $items)";
  }

  @override
  bool operator ==(covariant RandomQuoteDocument other) {
    if (identical(this, other)) return true;

    return other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.index == index &&
        other.id == id &&
        other.language == language &&
        other.type == type &&
        listEquals(other.items, items);
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        updatedAt.hashCode ^
        index.hashCode ^
        id.hashCode ^
        language.hashCode ^
        type.hashCode ^
        items.hashCode;
  }
}
