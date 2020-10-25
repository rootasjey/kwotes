import 'package:figstyle/types/reference_type.dart';
import 'package:figstyle/types/release.dart';
import 'package:figstyle/types/urls.dart';

class Reference {
  /// When this reference was released.
  final Release release;

  final List<String> links;

  final String id;
  String lang;
  String name;
  String summary;

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
    );
  }

  factory Reference.fromJSON(Map<String, dynamic> json) {
    final links = List<String>();

    if (json['links'] != null) {
      for (String ref in json['links']) {
        links.add(ref);
      }
    }

    final urls = json['urls'] != null ? Urls.fromJSON(json['urls']) : Urls();

    final type = json['type'] != null
        ? ReferenceType.fromJSON(json['type'])
        : ReferenceType();

    final release =
        json['release'] != null ? Release.fromJSON(json['release']) : Release();

    return Reference(
      id: json['id'] ?? '',
      lang: json['lang'],
      links: links,
      name: json['name'] ?? '',
      release: release,
      summary: json['summary'],
      type: type,
      urls: urls,
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

    return json;
  }
}
