import 'package:memorare/types/urls.dart';

class Author {
  final String id;
  final String imgUrl;

  /// True if the author is fictional.
  bool isFictional;

  String job;
  String name;
  String summary;

  final Urls urls;

  Author({
    this.id = '',
    this.isFictional = false,
    this.imgUrl = '',
    this.job = '',
    this.name = '',
    this.summary = '',
    this.urls,
  });

  factory Author.empty() {
    return Author(
      id: '',
      isFictional: false,
      imgUrl: '',
      job: '',
      name: '',
      summary: '',
      urls: Urls(),
    );
  }

  factory Author.fromJSON(Map<String, dynamic> json) {
    final _urls = json['urls'] != null ? Urls.fromJSON(json['urls']) : Urls();

    return Author(
      id: json['id'] ?? '',
      isFictional: json['isFictional'] ?? false,
      imgUrl: json['imgUrl'] ?? '',
      job: json['job'],
      name: json['name'],
      summary: json['summary'],
      urls: _urls,
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();

    json['id'] = id;
    json['isFictional'] = isFictional;
    json['imgUrl'] = imgUrl;
    json['job'] = job;
    json['name'] = name;
    json['summary'] = summary;

    return json;
  }
}
