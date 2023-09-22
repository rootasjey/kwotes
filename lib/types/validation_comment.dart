import "dart:convert";

/// A comment for a quote validation status.
class ValidationComment {
  ValidationComment({
    required this.name,
    required this.moderatorId,
  });

  /// Comment's content.
  final String name;

  /// Moderator user's id.
  final String moderatorId;

  ValidationComment copyWith({
    String? name,
    String? moderatorId,
  }) {
    return ValidationComment(
      name: name ?? this.name,
      moderatorId: moderatorId ?? this.moderatorId,
    );
  }

  factory ValidationComment.empty() {
    return ValidationComment(
      name: "",
      moderatorId: "",
    );
  }

  /// Convert the current instance to a map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "name": name,
      "moderator_id": moderatorId,
    };
  }

  factory ValidationComment.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ValidationComment.empty();
    }

    return ValidationComment(
      name: map["name"] ?? "",
      moderatorId: map["moderator_id"] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory ValidationComment.fromJson(String source) =>
      ValidationComment.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      "ValidationComment(name: $name, moderatorId: $moderatorId)";

  @override
  bool operator ==(covariant ValidationComment other) {
    if (identical(this, other)) return true;

    return other.name == name && other.moderatorId == moderatorId;
  }

  @override
  int get hashCode => name.hashCode ^ moderatorId.hashCode;
}
