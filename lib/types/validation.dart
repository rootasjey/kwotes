import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/types/validation_comment.dart';

class Validation {
  final ValidationComment comment;
  final String status;
  final DateTime updatedAt;

  Validation({
    this.comment,
    this.status,
    this.updatedAt,
  });

  factory Validation.fromJSON(Map<String, dynamic> json) {
    DateTime updatedAt;
    if (json['updatedAt'].runtimeType == String) {
      updatedAt = DateTime.parse(json['updatedAt']);
    } else {
      updatedAt = (json['updatedAt'] as Timestamp).toDate();
    }

    ValidationComment comment;
    if (json['comment'] != null) {
      comment = ValidationComment.fromJSON(json['comment']);
    } else {
      comment = ValidationComment();
    }

    return Validation(
      comment: comment,
      status: json['status'],
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = Map();

    data['comment'] = comment.toJSON();
    data['status'] = status;
    data['updatedAt'] = updatedAt;

    return data;
  }
}
