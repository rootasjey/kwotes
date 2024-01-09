import "dart:convert";

import "package:flutter/foundation.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_draft_quote_operation.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/user/user_firestore.dart";

class Quote {
  Quote({
    required this.author,
    required this.id,
    required this.language,
    required this.name,
    required this.reference,
    required this.quoteId,
    required this.starred,
    required this.topics,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.likes = 0,
    this.shares = 0,
  });

  /// The author of the quote (e.g. Albert Einstein).
  final Author author;

  /// True if the quote is starred.
  final bool starred;

  /// When this quote was created.
  final DateTime createdAt;

  /// Last time this quote was updated (any field update).
  final DateTime updatedAt;

  /// How many times this quote has been liked.
  final int likes;

  /// How many times this quote has been shared.
  final int shares;

  /// List of topics.
  final List<String> topics;

  /// Where this quote was referenced (e.g. a movie, a book, a song).
  final Reference reference;

  /// Quote unique identifier (Firestore generated).
  final String id;

  /// The language of the quote.
  final String language;

  // The actual quote.
  final String name;

  /// Match the quote's id in the 'quotes' collection.
  final String quoteId;

  /// User who created the quote.
  /// Usually different from the Author.
  /// (e.g. I can add a quote of Albert Einstein).
  final UserFirestore user;

  Quote copyWith({
    Author? author,
    String? id,
    String? lang,
    String? name,
    Reference? reference,
    String? quoteId,
    bool? starred,
    List<String>? topics,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserFirestore? user,
    String? language,
    int? likes,
    int? shares,
  }) {
    return Quote(
      author: author ?? this.author,
      id: id ?? this.id,
      language: lang ?? this.language,
      name: name ?? this.name,
      reference: reference ?? this.reference,
      quoteId: quoteId ?? this.quoteId,
      starred: starred ?? this.starred,
      topics: topics ?? this.topics,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      user: user ?? this.user,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
    );
  }

  /// Convert the current instance to a map.
  Map<String, dynamic> toMap({
    String userId = "",
    EnumQuoteOperation operation = EnumQuoteOperation.update,
  }) {
    final Map<String, dynamic> baseMap = {
      "author": author.toMap(minimal: true),
      "language": language.isEmpty ? "en" : language,
      "name": name,
      "reference": reference.toMap(minimal: true),
      if (operation == EnumQuoteOperation.restore)
        "metrics": {
          "likes": likes,
          "shares": shares,
        },
      "topics": topics.fold(<String, bool>{}, (
        Map<String, bool> previousValue,
        String topicString,
      ) {
        previousValue[topicString] = true;
        return previousValue;
      }),
      if (operation == EnumQuoteOperation.create ||
          operation == EnumQuoteOperation.restore)
        "user": {
          "id": userId.isEmpty ? user.id : userId,
        },
    };

    return baseMap;
  }

  /// Convert the current instance to a map for user's favourites.
  Map<String, dynamic> toMapFavourite() {
    return {
      "author": author.toMap(minimal: true),
      "language": language.isEmpty ? "en" : language,
      "name": name,
      "created_at": DateTime.now(),
      "reference": reference.toMap(minimal: true),
      "topics": topics.fold(<String, bool>{}, (
        Map<String, bool> previousValue,
        String topicString,
      ) {
        previousValue[topicString] = true;
        return previousValue;
      }),
    };
  }

  factory Quote.empty() {
    return Quote(
      author: Author.empty(),
      id: "",
      language: "",
      name: "",
      reference: Reference.empty(),
      quoteId: "",
      starred: false,
      topics: [],
      likes: 0,
      shares: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      user: UserFirestore.empty(),
    );
  }

  factory Quote.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Quote.empty();
    }

    final Author author = Author.fromMap(map["author"]);
    final Reference reference = Reference.fromMap(map["reference"]);
    final List<String> topics = parseTopics(map["topics"]);

    return Quote(
      author: author,
      createdAt: Utils.tictac.fromFirestore(map["created_at"]),
      updatedAt: Utils.tictac.fromFirestore(map["updated_at"]),
      id: map["id"] ?? "",
      language: map["language"] ?? "",
      name: map["name"] ?? "",
      reference: reference,
      likes: map["metrics"]?["likes"] ?? 0,
      shares: map["metrics"]?["shares"] ?? 0,
      quoteId: map["quoteId"] ?? "",
      starred: map["starred"] ?? false,
      topics: topics,
      user: UserFirestore.fromMap(map["user"]),
    );
  }

  static List<String> parseTopics(dynamic data) {
    final topics = <String>[];

    if (data == null) {
      return topics;
    }

    if (data is Iterable<dynamic>) {
      for (String tag in data) {
        topics.add(tag);
      }

      return topics;
    }

    Map<String, dynamic> mapTopics = data;

    mapTopics.forEach((key, value) {
      topics.add(key);
    });

    return topics;
  }

  String toJson() => json.encode(toMap());

  factory Quote.fromJson(String source) =>
      Quote.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "Quote(author: $author, id: $id, lang: $language, name: $name, "
        "reference: $reference, quoteId: $quoteId, starred: $starred,"
        "topics: $topics)";
  }

  @override
  bool operator ==(covariant Quote other) {
    if (identical(this, other)) return true;

    return other.author == author &&
        other.id == id &&
        other.language == language &&
        other.name == name &&
        other.reference == reference &&
        other.quoteId == quoteId &&
        other.starred == starred &&
        listEquals(other.topics, topics);
  }

  @override
  int get hashCode {
    return author.hashCode ^
        id.hashCode ^
        language.hashCode ^
        name.hashCode ^
        reference.hashCode ^
        quoteId.hashCode ^
        starred.hashCode ^
        topics.hashCode;
  }
}
