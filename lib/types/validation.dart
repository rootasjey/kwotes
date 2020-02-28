import 'package:memorare/types/comment.dart';

class Validation {
  final Comment comment;
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
        Comment.fromJSON(json['comment']) : null,

      status: json['status'],
      updatedAt: json['updatedAt'],
    );
  }
}
