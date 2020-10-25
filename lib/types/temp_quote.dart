import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/types/author.dart';
import 'package:figstyle/types/partial_user.dart';
import 'package:figstyle/types/reference.dart';
import 'package:figstyle/types/validation.dart';

class TempQuote {
  final Author author;

  // To distinguish offline draft.
  final bool isOffline;

  final DateTime createdAt;
  final DateTime updatedAt;

  final List<String> comments;
  final List<Reference> references;
  final List<String> topics;

  final PartialUser user;

  final Reference mainReference;

  final String id;
  final String lang;
  final String name;
  final String region;

  final Validation validation;

  TempQuote({
    this.author,
    this.comments,
    this.createdAt,
    this.id,
    this.isOffline = false,
    this.lang,
    this.mainReference,
    this.name,
    this.references,
    this.region,
    this.topics,
    this.updatedAt,
    this.user,
    this.validation,
  });

  factory TempQuote.fromJSON(Map<String, dynamic> json) {
    List<Reference> referencesList = [];
    List<String> topicsList = [];

    if (json['references'] != null) {
      for (var ref in json['references']) {
        referencesList.add(Reference.fromJSON(ref));
      }
    }

    if (json['topics'] != null) {
      final Map<String, dynamic> topics = json['topics'];
      topics.forEach((key, value) {
        topicsList.add(key);
      });
    }

    final author =
        json['author'] != null ? Author.fromJSON(json['author']) : null;

    final _mainReference = json['mainReference'] != null
        ? Reference.fromJSON(json['mainReference'])
        : null;

    final user =
        json['user'] != null ? PartialUser.fromJSON(json['user']) : null;

    final validation = json['validation'] != null
        ? Validation.fromJSON(json['validation'])
        : null;

    final List<dynamic> rawComments = json['comments'];
    final comments = <String>[];

    if (rawComments != null) {
      rawComments.forEach((rawComment) {
        comments.add(rawComment);
      });
    }

    final createdAt = json['createdAt'].runtimeType == String
        ? DateTime.parse(json['createdAt'])
        : (json['createdAt'] as Timestamp).toDate();

    final updatedAt = json['updatedAt'].runtimeType == String
        ? DateTime.parse(json['updatedAt'])
        : (json['updatedAt'] as Timestamp).toDate();

    return TempQuote(
      author: author,
      comments: comments,
      createdAt: createdAt,
      id: json['id'],
      isOffline: json['isOffline'] ?? false,
      lang: json['lang'],
      mainReference: _mainReference,
      name: json['name'],
      references: referencesList,
      region: json['region'],
      topics: topicsList,
      updatedAt: updatedAt,
      user: user,
      validation: validation,
    );
  }
}
