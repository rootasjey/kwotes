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
    Urls _urls;
    if (data['urls'] != null) {
      _urls = Urls.fromJSON(data['urls']);
    } else {
      _urls = Urls();
    }

    ReferenceType _type;
    if (data['type'] != null) {
      _type = ReferenceType.fromJSON(data['type']);
    } else {
      _type = ReferenceType();
    }

    Release _release;
    if (data['release'] != null) {
      _release = Release.fromJSON(data['release']);
    } else {
      _release = Release();
    }

    return Reference(
      id: data['id'] ?? '',
      lang: data['lang'],
      name: data['name'] ?? '',
      release: _release,
      summary: data['summary'] ?? '',
      type: _type,
      urls: _urls,
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
