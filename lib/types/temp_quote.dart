import 'package:memorare/types/author.dart';
import 'package:memorare/types/partial_user.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/types/validation.dart';

class TempQuote {
  final Author author;
  final List<String> comments;
  final DateTime createdAt;
  final String id;
  final String lang;
  final Reference mainReference;
  final String name;
  final List<Reference> references;
  final String region;
  final List<String> topics;
  final DateTime updatedAt;
  final PartialUser user;
  final Validation validation;

  TempQuote({
    this.author,
    this.comments,
    this.createdAt,
    this.id,
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
      final Map<String, dynamic> _topics = json['topics'];
      _topics.forEach((key, value) {
        topicsList.add(key);
      });
    }

    final _author = json['author'] != null ?
      Author.fromJSON(json['author']) : null;

    final _mainReference = json['mainReference'] != null ?
      Reference.fromJSON(json['mainReference']) : null;

    final _user = json['user'] != null ?
      PartialUser.fromJSON(json['user']) : null;

    final _validation = json['validation'] != null ?
      Validation.fromJSON(json['validation']) : null;

    final List<dynamic> _dynamicList = json['comments'];
    final _comments = _dynamicList.length > 0 ? _dynamicList : List<String>();

    return TempQuote(
      author        : _author,
      comments      : _comments,
      createdAt     : json['createdAt'],
      id            : json['id'],
      lang          : json['lang'],
      mainReference : _mainReference,
      name          : json['name'],
      references    : referencesList,
      region        : json['region'],
      topics        : topicsList,
      updatedAt     : json['updatedAt'],
      user          : _user,
      validation    : _validation,
    );
  }
}
