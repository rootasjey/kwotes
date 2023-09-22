import "dart:convert";

import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/validation_comment.dart";

/// Quote's validation state.
class Validation {
  Validation({
    required this.comment,
    required this.status,
    required this.updatedAt,
  });

  /// Last time this validation was updated.
  final DateTime updatedAt;

  /// Is the quote rejected?
  final String status;

  /// The validation comment.
  final ValidationComment comment;

  factory Validation.empty() {
    return Validation(
      comment: ValidationComment.empty(),
      status: "",
      updatedAt: DateTime.now(),
    );
  }

  Validation copyWith({
    ValidationComment? comment,
    String? status,
    DateTime? updatedAt,
  }) {
    return Validation(
      comment: comment ?? this.comment,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "comment": comment.toMap(),
      "status": status,
    };
  }

  factory Validation.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Validation.empty();
    }

    return Validation(
      comment: ValidationComment.fromMap(map["comment"]),
      status: map["status"] ?? "",
      updatedAt: Utils.tictac.fromFirestore(map["updated_at"]),
    );
  }

  String toJson() => json.encode(toMap());

  factory Validation.fromJson(String source) =>
      Validation.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      "Validation(comment: $comment, status: $status, updatedAt: $updatedAt)";

  @override
  bool operator ==(covariant Validation other) {
    if (identical(this, other)) return true;

    return other.comment == comment &&
        other.status == status &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => comment.hashCode ^ status.hashCode ^ updatedAt.hashCode;
}
