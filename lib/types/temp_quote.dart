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
  final List<String> topics;

  final PartialUser user;

  final Reference reference;

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
    this.reference,
    this.name,
    this.region,
    this.topics,
    this.updatedAt,
    this.user,
    this.validation,
  });

  factory TempQuote.fromJSON(Map<String, dynamic> data) {
    List<String> _topicsList = [];
    if (data['topics'] != null) {
      final Map<String, dynamic> topics = data['topics'];
      topics.forEach((key, value) {
        _topicsList.add(key);
      });
    }

    Author _author;
    if (data['author'] != null) {
      _author = Author.fromJSON(data['author']);
    }

    Reference _reference;
    if (data['reference'] != null) {
      _reference = Reference.fromJSON(data['reference']);
    } else if (data['mainReference'] != null) {
      // Keep for drafts. To delete later.
      _reference = Reference.fromJSON(data['mainReference']);
    }

    PartialUser _user;
    if (data['user'] != null) {
      _user = PartialUser.fromJSON(data['user']);
    }

    Validation _validation;
    if (data['validation'] != null) {
      Validation.fromJSON(data['validation']);
    }

    final List<dynamic> rawComments = data['comments'];
    final comments = <String>[];

    if (rawComments != null) {
      rawComments.forEach((rawComment) {
        comments.add(rawComment);
      });
    }

    DateTime _createdAt;
    if (data['createdAt'].runtimeType == String) {
      _createdAt = DateTime.parse(data['createdAt']);
    } else {
      _createdAt = (data['createdAt'] as Timestamp).toDate();
    }

    DateTime _updatedAt;
    if (data['updatedAt'].runtimeType == String) {
      DateTime.parse(data['updatedAt']);
    } else {
      _updatedAt = (data['updatedAt'] as Timestamp).toDate();
    }

    return TempQuote(
      author: _author,
      comments: comments,
      createdAt: _createdAt,
      id: data['id'] ?? '',
      isOffline: data['isOffline'] ?? false,
      lang: data['lang'] ?? 'en',
      reference: _reference,
      name: data['name'] ?? '',
      region: data['region'],
      topics: _topicsList,
      updatedAt: _updatedAt,
      user: _user,
      validation: _validation,
    );
  }
}
