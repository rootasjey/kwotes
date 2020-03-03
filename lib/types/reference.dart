import 'package:memorare/types/reference_type.dart';
import 'package:memorare/types/urls.dart';

class Reference {
  final String id;
  final String imgUrl;
  final String lang;
  final List<String> links;
  final String name;
  final String subType;
  final String summary;
  final ReferenceType type;
  final String url;
  final Urls urls;
  final String wikiUrl;

  Reference({
    this.id = '',
    this.imgUrl,
    this.lang = 'en',
    this.links,
    this.name = '',
    this.subType,
    this.summary = '',
    this.type,
    this.url,
    this.urls,
    this.wikiUrl,
  });

  factory Reference.fromJSON(Map<String, dynamic> json) {
    final _links = List<String>();

    if (json['links'] != null) {
      for (String ref in json['links']) {
        _links.add(ref);
      }
    }

    final _urls = json['urls'] != null ?
      Urls.fromJSON(json['urls']) : Urls();

    final _type = json['type'] != null ?
      ReferenceType.fromJSON(json['type']) : ReferenceType();

    return Reference(
      id          : json['id'] ?? '',
      imgUrl      : json['imgUrl'],
      lang        : json['lang'],
      links       : _links,
      name        : json['name'] ?? '',
      subType     : json['subType'],
      summary     : json['summary'],
      type        : _type,
      url         : json['url'],
      urls        : _urls,
      wikiUrl     : json['wikiUrl'],
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();

    json['id']          = id;
    json['imgUrl']      = imgUrl;
    json['lang']        = lang;
    json['links']       = links;
    json['name']        = name;
    json['subType']     = subType;
    json['summary']     = summary;
    json['type']        = type;
    json['url']         = url;
    json['wikiUrl']     = wikiUrl;

    return json;
  }
}
