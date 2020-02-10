import 'package:memorare/types/reference_type.dart';
import 'package:memorare/types/urls.dart';

class Reference {
  final String id;
  final String imgUrl;
  final String lang;
  final List<Reference> linkedRefs;
  final String name;
  final String subType;
  final String summary;
  final ReferenceType type;
  final String url;
  final Urls urls;
  final String wikiUrl;

  Reference({
    this.id,
    this.imgUrl,
    this.lang,
    this.linkedRefs,
    this.name,
    this.subType,
    this.summary,
    this.type,
    this.url,
    this.urls,
    this.wikiUrl,
  });

  factory Reference.fromJSON(Map<String, dynamic> json) {
    List<Reference> _linkedRefs = [];

    if (json['linkedRefs'] != null) {
      for (var ref in json['linkedRefs']) {
        _linkedRefs.add(Reference.fromJSON(ref));
      }
    }

    return Reference(
      id          : json['id'],
      imgUrl      : json['imgUrl'],
      lang        : json['lang'],
      linkedRefs  : _linkedRefs,
      name        : json['name'],
      subType     : json['subType'],
      summary     : json['summary'],
      type        : json['type'] != null ?
        ReferenceType.fromJSON(json['type']) : ReferenceType(),

      url         : json['url'],
      urls        : json['urls'] != null ?
        Urls.fromJSON(json['urls']) : null,

      wikiUrl     : json['wikiUrl'],
    );
  }


  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();

    json['id']          = id;
    json['imgUrl']      = imgUrl;
    json['lang']        = lang;
    json['linkedRefs']  = linkedRefs;
    json['name']        = name;
    json['subType']     = subType;
    json['summary']     = summary;
    json['type']        = type;
    json['url']         = url;
    json['wikiUrl']     = wikiUrl;

    return json;
  }
}
