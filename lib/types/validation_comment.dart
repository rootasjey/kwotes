import 'package:cloud_firestore/cloud_firestore.dart';

class ValidationComment {
  final String name;
  final DateTime updatedAt;

  ValidationComment({
    this.name,
    this.updatedAt,
  });

  factory ValidationComment.fromJSON(Map<String, dynamic> json) {
    final updatedAt = json['updatedAt'].runtimeType == String ?
      DateTime.parse(json['updatedAt']) :
      (json['updatedAt'] as Timestamp).toDate();

    return ValidationComment(
      name: json['name'],
      updatedAt: updatedAt,
    );
  }
}
