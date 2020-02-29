class ValidationComment {
  final String name;
  final DateTime updatedAt;

  ValidationComment({
    this.name,
    this.updatedAt,
  });

  factory ValidationComment.fromJSON(Map<String, dynamic> json) {
    return ValidationComment(
      name: json['name'],
      updatedAt: json['updatedAt'],
    );
  }
}
