import 'package:fig_style/types/partial_user.dart';
import 'package:fig_style/utils/date_helper.dart';

class Comment {
  final String commentId;
  final DateTime createdAt;
  final String id;
  final String name;
  final String quoteId;
  final DateTime updatedAt;
  final PartialUser user;

  Comment({
    this.commentId,
    this.createdAt,
    this.id,
    this.name,
    this.quoteId,
    this.updatedAt,
    this.user,
  });

  factory Comment.empty() {
    return Comment(
      createdAt: DateTime.now(),
      id: '',
      name: '',
      updatedAt: DateTime.now(),
      user: PartialUser.empty(),
    );
  }

  factory Comment.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return Comment.empty();
    }

    return Comment(
      createdAt: DateHelper.fromFirestore(data['createdAt']),
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      updatedAt: DateHelper.fromFirestore(data['updatedAt']),
      user: PartialUser.fromJSON(data['user']),
    );
  }
}
