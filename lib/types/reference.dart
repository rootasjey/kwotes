import 'package:figstyle/types/reference_type.dart';
import 'package:figstyle/types/release.dart';
import 'package:figstyle/types/urls.dart';

class Reference {
  /// When this reference was released.
  final Release release;

  final String id;
  String lang;
  String name;
  String summary;

  final ReferenceType type;

  final Urls urls;

  Reference({
    this.id = '',
    this.lang = 'en',
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
      name: '',
      release: Release(),
      summary: '',
      type: ReferenceType(),
      urls: Urls(),
    );
  }

  factory Reference.fromJSON(Map<String, dynamic> data) {
    final links = <String>[];

    if (data['links'] != null) {
      for (String ref in data['links']) {
        links.add(ref);
      }
    }

    final urls = data['urls'] != null ? Urls.fromJSON(data['urls']) : Urls();

    final type = data['type'] != null
        ? ReferenceType.fromJSON(data['type'])
        : ReferenceType();

    final release =
        data['release'] != null ? Release.fromJSON(data['release']) : Release();

    return Reference(
      id: data['id'] ?? '',
      lang: data['lang'],
      name: data['name'] ?? '',
      release: release,
      summary: data['summary'],
      type: type,
      urls: urls,
    );
  }

  Map<String, dynamic> toJSON({bool withId = false}) {
    final Map<String, dynamic> data = Map();

    if (withId) {
      data['id'] = id;
    }

    data['lang'] = lang;
    data['name'] = name;
    data['release'] = release.toJSON();
    data['summary'] = summary;
    data['type'] = type.toJSON();
    data['urls'] = urls.toJSON();

    return data;
  }
}
