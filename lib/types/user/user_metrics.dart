import "dart:convert";

import "package:kwotes/types/user/user_metics_quotes.dart";

class UserMetrics {
  const UserMetrics({
    required this.drafts,
    required this.favourites,
    required this.lists,
    required this.quotes,
  });

  final int drafts;
  final int favourites;
  final int lists;
  final UserMetricsQuotes quotes;

  UserMetrics copyWith({
    int? drafts,
    int? favourites,
    int? lists,
    UserMetricsQuotes? quotes,
  }) {
    return UserMetrics(
      drafts: drafts ?? this.drafts,
      favourites: favourites ?? this.favourites,
      lists: lists ?? this.lists,
      quotes: quotes ?? this.quotes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "drafts": drafts,
      "favourites": favourites,
      "lists": lists,
      "quotes": quotes.toMap(),
    };
  }

  factory UserMetrics.empty() {
    return UserMetrics(
      drafts: 0,
      favourites: 0,
      lists: 0,
      quotes: UserMetricsQuotes.empty(),
    );
  }

  factory UserMetrics.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserMetrics.empty();
    }

    return UserMetrics(
      drafts: map["drafts"] ?? 0,
      favourites: map["favourites"] ?? 0,
      lists: map["lists"] ?? 0,
      quotes: UserMetricsQuotes.fromMap(map["quotes"] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserMetrics.fromJson(String source) =>
      UserMetrics.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "UserMetrics(drafts: $drafts, favourites: $favourites, lists: $lists, quotes: $quotes)";
  }

  @override
  bool operator ==(covariant UserMetrics other) {
    if (identical(this, other)) return true;

    return other.drafts == drafts &&
        other.favourites == favourites &&
        other.lists == lists &&
        other.quotes == quotes;
  }

  @override
  int get hashCode {
    return drafts.hashCode ^
        favourites.hashCode ^
        lists.hashCode ^
        quotes.hashCode;
  }
}
