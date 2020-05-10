import 'package:memorare/types/urls.dart';

class Author {
  final String id;
  final String imgUrl;
  String job;
  String name;
  String summary;
  final Urls urls;

  Author({
    this.id       = '',
    this.imgUrl   = '',
    this.job      = '',
    this.name     = '',
    this.summary  = '',
    this.urls,
  });

  factory Author.empty() {
    return Author(
      id      : '',
      imgUrl  : '',
      job     : '',
      name    : '',
      summary : '',
      urls    : Urls(),
    );
  }

  factory Author.fromJSON(Map<String, dynamic> json) {
    final _urls = json['urls'] != null ?
      Urls.fromJSON(json['urls']) : Urls();

    return Author(
      id      : json['id'] ?? '',
      imgUrl  : json['imgUrl'] ?? '',
      job     : json['job'],
      name    : json['name'],
      summary : json['summary'],
      urls    : _urls,
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();

    json['id']      = id;
    json['imgUrl']  = imgUrl;
    json['job']     = job;
    json['name']    = name;
    json['summary'] = summary;

    return json;
  }
}
