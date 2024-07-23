// ignore_for_file: public_member_api_docs, sort_constructors_first
import "dart:convert";

import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_draft_quote_operation.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:kwotes/types/validation.dart";

/// A draft quote.
/// This quote may be waiting for validation or in draft in an user space.
class DraftQuote extends Quote {
  DraftQuote({
    required this.isOffline,
    required this.validation,
    required this.inValidation,
    required super.author,
    required super.id,
    required super.language,
    required super.name,
    required super.reference,
    required super.quoteId,
    required super.starred,
    required super.categories,
    required super.tags,
    required super.topics,
    required super.createdAt,
    required super.updatedAt,
    required super.user,
  });

  /// True if the quote is in validation state (in global collection).
  final bool inValidation;

  /// To distinguish offline draft to online one.
  final bool isOffline;

  /// Validation status of the draft quote.
  final Validation validation;

  @override
  DraftQuote copyWith({
    Author? author,
    String? id,
    String? lang,
    String? name,
    Reference? reference,
    String? quoteId,
    bool? starred,
    List<String>? categories,
    List<String>? tags,
    List<String>? topics,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserFirestore? user,
    String? language,
    int? likes,
    int? shares,
  }) {
    return DraftQuote(
      author: author ?? this.author,
      categories: categories ?? this.categories,
      id: id ?? this.id,
      language: lang ?? this.language,
      name: name ?? this.name,
      inValidation: inValidation,
      isOffline: isOffline,
      reference: reference ?? this.reference,
      quoteId: quoteId ?? this.quoteId,
      starred: starred ?? this.starred,
      tags: tags ?? this.tags,
      topics: topics ?? this.topics,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      user: user ?? this.user,
      validation: validation,
    );
  }

  DraftQuote copyDraftWith({
    bool? isOffline,
    bool? inValidation,
    Validation? validation,
    Author? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    String? language,
    String? name,
    Reference? reference,
    String? quoteId,
    bool? starred,
    List<String>? categories,
    List<String>? tags,
    List<String>? topics,
    UserFirestore? user,
  }) {
    return DraftQuote(
      isOffline: isOffline ?? this.isOffline,
      inValidation: inValidation ?? this.inValidation,
      validation: validation ?? this.validation,
      author: author ?? super.author,
      createdAt: createdAt ?? super.createdAt,
      updatedAt: updatedAt ?? super.updatedAt,
      id: id ?? super.id,
      language: language ?? super.language,
      name: name ?? super.name,
      reference: reference ?? super.reference,
      quoteId: quoteId ?? super.quoteId,
      starred: starred ?? super.starred,
      categories: categories ?? super.categories,
      tags: tags ?? super.tags,
      topics: topics ?? super.topics,
      user: user ?? super.user,
    );
  }

  /// Create an empty draft quote instance.
  factory DraftQuote.empty() {
    return DraftQuote(
      isOffline: false,
      inValidation: false,
      author: Author.empty(),
      categories: [],
      id: "",
      language: "en",
      name: "",
      reference: Reference.empty(),
      quoteId: "",
      starred: false,
      tags: [],
      topics: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      user: UserFirestore.empty(),
      validation: Validation.empty(),
    );
  }

  @override
  Map<String, dynamic> toMap({
    String userId = "",
    EnumQuoteOperation operation = EnumQuoteOperation.update,
  }) {
    return <String, dynamic>{
      "author": author.toMap(),
      "language": language,
      "name": name,
      "reference": reference.toMap(),
      "categories": categories.fold(<String, bool>{}, (
        Map<String, bool> previousValue,
        String topicString,
      ) {
        previousValue[topicString] = true;
        return previousValue;
      }),
      "tags": tags.fold(<String, bool>{}, (
        Map<String, bool> previousValue,
        String topicString,
      ) {
        previousValue[topicString] = true;
        return previousValue;
      }),
      "topics": topics.fold(<String, bool>{}, (
        Map<String, bool> previousValue,
        String topicString,
      ) {
        previousValue[topicString] = true;
        return previousValue;
      }),
      if (operation == EnumQuoteOperation.create ||
          operation == EnumQuoteOperation.validate)
        "user": {
          "id": userId,
        },
      if (operation == EnumQuoteOperation.adminUpdateInValidation)
        "validation": validation.toMap(),
    };
  }

  factory DraftQuote.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return DraftQuote.empty();
    }

    final List<String> topics = Quote.convertArrayToMap(map["topics"]);
    final List<String> categories = Quote.convertArrayToMap(map["categories"]);
    final List<String> tags = Quote.convertArrayToMap(map["tags"]);

    return DraftQuote(
      author: Author.fromMap(map["author"]),
      categories: categories,
      createdAt: Utils.tictac.fromFirestore(map["created_at"]),
      id: map["id"] ?? "",
      isOffline: map["is_offline"] ?? false,
      inValidation: map["in_validation"] ?? false,
      language: map["language"] ?? "en",
      name: map["name"] ?? "",
      quoteId: map["quoteId"] ?? "",
      reference: Reference.fromMap(map["reference"]),
      starred: map["starred"] ?? false,
      tags: tags,
      topics: topics,
      updatedAt: Utils.tictac.fromFirestore(map["updated_at"]),
      user: UserFirestore.fromMap(map["user"]),
      validation: Validation.fromMap(map["validation"]),
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory DraftQuote.fromJson(String source) =>
      DraftQuote.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      "DraftQuote(isOffline: $isOffline, validation: $validation)";

  @override
  bool operator ==(covariant DraftQuote other) {
    if (identical(this, other)) return true;

    return other.isOffline == isOffline &&
        other.validation == validation &&
        other.inValidation == inValidation;
  }

  @override
  int get hashCode =>
      isOffline.hashCode ^ validation.hashCode ^ inValidation.hashCode;
}
