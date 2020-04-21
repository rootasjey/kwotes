import 'package:memorare/types/urls.dart';

class Author {
  final String id;
  final String imgUrl;
  String job;
  String name;
  String summary;
  /// Deprecated
  final String url;
  /// Deprecated
  final String wikiUrl;
  final Urls urls;

  Author({
    this.id       = '',
    this.imgUrl   = '',
    this.job      = '',
    this.name     = '',
    this.summary  = '',
    this.url      = '',
    this.urls,
    this.wikiUrl  = '',
  });

  factory Author.empty() {
    return Author(
      id      : '',
      imgUrl  : '',
      job     : '',
      name    : '',
      summary : '',
      url     : '',
      urls    : Urls(),
      wikiUrl : '',
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
      url     : json['url'],
      urls    : _urls,
      wikiUrl : json['wikiUrl'],
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();

    json['id']      = id;
    json['imgUrl']  = imgUrl;
    json['job']     = job;
    json['name']    = name;
    json['summary'] = summary;
    json['url']     = url;
    json['wikiUrl'] = wikiUrl;

    return json;
  }
}
