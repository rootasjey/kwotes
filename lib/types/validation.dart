import 'package:figstyle/types/validation_comment.dart';
import 'package:figstyle/utils/date_helper.dart';

class Validation {
  final ValidationComment comment;
  final String status;
  final DateTime updatedAt;

  Validation({
    this.comment,
    this.status,
    this.updatedAt,
  });

  factory Validation.empty() {
    return Validation(
      comment: ValidationComment.empty(),
      status: '',
      updatedAt: DateTime.now(),
    );
  }

  factory Validation.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return Validation.empty();
    }

    final comment = ValidationComment.fromJSON(data['comment']);
    final updatedAt = DateHelper.fromFirestore(data['updatedAt']);

    return Validation(
      comment: comment,
      status: data['status'],
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = Map();

    data['comment'] = comment.toJSON();
    data['status'] = status;
    data['updatedAt'] = updatedAt.millisecondsSinceEpoch;

    return data;
  }
}
