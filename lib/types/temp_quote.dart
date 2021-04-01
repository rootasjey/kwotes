import 'package:fig_style/types/author.dart';
import 'package:fig_style/types/partial_user.dart';
import 'package:fig_style/types/reference.dart';
import 'package:fig_style/types/urls.dart';
import 'package:fig_style/types/validation.dart';
import 'package:fig_style/types/validation_comment.dart';
import 'package:fig_style/utils/date_helper.dart';

class TempQuote {
  Author author;

  // To distinguish offline draft.
  final bool isOffline;

  final DateTime createdAt;
  final DateTime updatedAt;

  final List<String> comments;
  final List<String> topics;

  final PartialUser user;

  Reference reference;

  final String id;
  final String lang;
  final String name;
  final String region;

  final Urls urls;

  final Validation validation;

  TempQuote({
    this.author,
    this.comments,
    this.createdAt,
    this.id,
    this.isOffline = false,
    this.lang,
    this.reference,
    this.name,
    this.region,
    this.topics,
    this.updatedAt,
    this.urls,
    this.user,
    this.validation,
  });

  factory TempQuote.empty() {
    return TempQuote(
      author: Author.empty(),
      comments: [],
      createdAt: DateTime.now(),
      id: '',
      isOffline: false,
      lang: 'en',
      reference: Reference.empty(),
      name: '',
      region: '',
      topics: [],
      updatedAt: DateTime.now(),
      urls: Urls.empty(),
      user: PartialUser.empty(),
      validation: Validation.empty(),
    );
  }

  factory TempQuote.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return TempQuote.empty();
    }

    final author = Author.fromJSON(data['author']);
    final comments = parseComments(data['comments']);
    final createdAt = DateHelper.fromFirestore(data['createdAt']);
    final reference = parseReference(data);
    final topics = parseTopics(data['topics']);
    final user = PartialUser.fromJSON(data['user']);
    final validation = Validation.fromJSON(data['validation']);
    final updatedAt = DateHelper.fromFirestore(data['updatedAt']);
    final urls = Urls.fromJSON(data['urls']);

    return TempQuote(
      author: author,
      comments: comments,
      createdAt: createdAt,
      id: data['id'] ?? '',
      isOffline: data['isOffline'] ?? false,
      lang: data['lang'] ?? 'en',
      reference: reference,
      name: data['name'] ?? '',
      region: data['region'],
      topics: topics,
      updatedAt: updatedAt,
      urls: urls,
      user: user,
      validation: validation,
    );
  }

  void addComment(String comment) {
    comments.add(comment);
  }

  static List<String> parseComments(dynamic data) {
    final comments = <String>[];

    if (data == null) {
      return comments;
    }

    (data as List<dynamic>).forEach((comment) {
      comments.add(comment);
    });

    return comments;
  }

  static Reference parseReference(data) {
    if (data['reference'] != null) {
      return Reference.fromJSON(data['reference']);
    } else if (data['mainReference'] != null) {
      // Keep for drafts. To delete later.
      return Reference.fromJSON(data['mainReference']);
    }

    return Reference.empty();
  }

  static List<String> parseTopics(dynamic data) {
    final topics = <String>[];

    if (data == null) {
      return topics;
    }

    (data as Map<String, dynamic>).forEach((key, value) {
      topics.add(key);
    });

    return topics;
  }

  void setAuthor(Author newAuthor) {
    author = newAuthor;
  }

  void setReference(Reference newReference) {
    reference = newReference;
  }

  Map<String, dynamic> toJSON({bool dateAsInt = false}) {
    final Map<String, dynamic> data = Map();

    Validation _validation;

    if (validation != null) {
      _validation = validation;
    } else {
      _validation = Validation(
        comment: ValidationComment(
          moderatorId: '',
          name: '',
        ),
        status: '',
        updatedAt: DateTime.now(),
      );
    }

    data['author'] = author.toJSON(dateAsInt: dateAsInt);
    data['comments'] = comments;
    data['createdAt'] = createdAt.millisecondsSinceEpoch;
    data['isOffline'] = isOffline;
    data['lang'] = lang;
    data['reference'] = reference.toJSON(dateAsInt: dateAsInt);
    data['name'] = name;
    data['region'] = region;
    data['topics'] = topics;
    data['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
    data['urls'] = urls.toJSON();
    data['user'] = user.toJSON();
    data['validation'] = _validation.toJSON();

    return data;
  }
}
