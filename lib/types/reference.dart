import 'package:memorare/types/reference_type.dart';
import 'package:memorare/types/release.dart';
import 'package:memorare/types/urls.dart';

class Reference {
  /// When this reference was released.
  final Release release;

  final List<String> links;

  final String id;
  String lang;
  String name;
  String summary;
  final String wikiUrl;

  final ReferenceType type;

  final Urls urls;

  Reference({
    this.id = '',
    this.lang = 'en',
    this.links,
    this.name = '',
    this.release,
    this.summary = '',
    this.type,
    this.urls,
    this.wikiUrl,
  });

  factory Reference.empty() {
    return Reference(
      id: '',
      lang: 'en',
      links: [],
      name: '',
      release: Release(),
      summary: '',
      type: ReferenceType(),
      urls: Urls(),
      wikiUrl: '',
    );
  }

  factory Reference.fromJSON(Map<String, dynamic> json) {
    final _links = List<String>();

    if (json['links'] != null) {
      for (String ref in json['links']) {
        _links.add(ref);
      }
    }

    final _urls = json['urls'] != null ? Urls.fromJSON(json['urls']) : Urls();

    final _type = json['type'] != null
        ? ReferenceType.fromJSON(json['type'])
        : ReferenceType();

    final release =
        json['release'] != null ? Release.fromJSON(json['release']) : Release();

    return Reference(
      id: json['id'] ?? '',
      lang: json['lang'],
      links: _links,
      name: json['name'] ?? '',
      release: release,
      summary: json['summary'],
      type: _type,
      urls: _urls,
      wikiUrl: json['wikiUrl'],
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();

    json['id'] = id;
    json['lang'] = lang;
    json['links'] = links;
    json['name'] = name;
    json['release'] = release;
    json['summary'] = summary;
    json['type'] = type;
    json['wikiUrl'] = wikiUrl;

    return json;
  }
}
