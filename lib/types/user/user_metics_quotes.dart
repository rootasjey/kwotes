import "dart:convert";

class UserMetricsQuotes {
  const UserMetricsQuotes({
    required this.created,
    required this.proposed,
    required this.published,
    required this.submitted,
  });

  final int created;
  final int proposed;
  final int published;
  final int submitted;

  UserMetricsQuotes copyWith({
    int? created,
    int? proposed,
    int? published,
    int? submitted,
  }) {
    return UserMetricsQuotes(
      created: created ?? this.created,
      proposed: proposed ?? this.proposed,
      published: published ?? this.published,
      submitted: submitted ?? this.submitted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "created": created,
      "proposed": proposed,
      "published": published,
      "submitted": submitted,
    };
  }

  factory UserMetricsQuotes.empty() {
    return const UserMetricsQuotes(
      created: 0,
      proposed: 0,
      published: 0,
      submitted: 0,
    );
  }

  factory UserMetricsQuotes.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserMetricsQuotes.empty();
    }

    return UserMetricsQuotes(
      created: map["created"] ?? 0,
      proposed: map["proposed"] ?? 0,
      published: map["published"] ?? 0,
      submitted: map["submitted"] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserMetricsQuotes.fromJson(String source) =>
      UserMetricsQuotes.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      "UserMetricsQuotes(created: $created, proposed: $proposed, "
      "published: $published, submitted: $submitted)";

  @override
  bool operator ==(covariant UserMetricsQuotes other) {
    if (identical(this, other)) return true;

    return other.created == created &&
        other.proposed == proposed &&
        other.published == published &&
        other.submitted == submitted;
  }

  @override
  int get hashCode =>
      created.hashCode ^
      proposed.hashCode ^
      published.hashCode ^
      submitted.hashCode;
}
