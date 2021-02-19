class ValidationComment {
  /// Comment content.
  final String name;

  /// Moderator user's id.
  final String moderatorId;

  ValidationComment({
    this.name = '',
    this.moderatorId = '',
  });

  factory ValidationComment.fromJSON(Map<String, dynamic> json) {
    return ValidationComment(
      name: json['name'],
      moderatorId: json['moderatorid'] != null ? json['moderatorid'] : '',
    );
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = Map();

    data['name'] = name;
    data['moderatorId'] = moderatorId;

    return data;
  }
}
