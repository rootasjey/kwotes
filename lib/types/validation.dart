import 'package:memorare/types/validation_comment.dart';

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
    return Validation(
      comment: json['comment'] != null ?
        ValidationComment.fromJSON(json['comment']) : null,

      status: json['status'],
      updatedAt: json['updatedAt'],
    );
  }
}
