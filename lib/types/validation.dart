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
    final updatedAt = json['updatedAt'].runtimeType == String ?
      DateTime.parse(json['updatedAt']) :
      (json['updatedAt'] as Timestamp).toDate();

    return Validation(
      comment: json['comment'] != null ?
        ValidationComment.fromJSON(json['comment']) : null,

      status: json['status'],
      updatedAt: updatedAt,
    );
  }
}
