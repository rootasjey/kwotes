import 'package:figstyle/types/reference_type.dart';
import 'package:figstyle/types/release.dart';
import 'package:figstyle/types/urls.dart';

class Reference {
  /// When this reference was released.
  Release release;

  String id;
  String lang;
  String name;
  String summary;

  ReferenceType type;

  Urls urls;

  Reference({
    this.id = '',
    this.lang = 'en',
    this.name = '',
    this.release,
    this.summary = '',
    this.type,
    this.urls,
  });

  void clear() {
    id = '';
    lang = 'en';
    name = '';
    release = Release();
    summary = '';
    type = ReferenceType();
    urls = Urls();
  }

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
      summary: data['summary'] ?? '',
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

  /// Return a map with only [id] and [name] as properties.
  /// Useful wwhen converting reference"s data into a published quote.
  Map<String, dynamic> toPartialJSON() {
    Map<String, dynamic> data = Map();

    data['id'] = id;
    data['name'] = name;

    return data;
  }
}
