import 'package:memorare/types/partial_user.dart';

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

  factory Comment.fromJSON(Map<String, dynamic> json) {
    final _user = PartialUser.fromJSON(json['user']);

    return Comment(
      createdAt : json['createdAt'],
      id        : json['id'],
      name      : json['name'],
      updatedAt : json['updatedAt'],
      user      : _user,
    );
  }
}
