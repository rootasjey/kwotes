import 'package:fig_style/types/image_property.dart';
import 'package:fig_style/types/reference_type.dart';
import 'package:fig_style/types/release.dart';
import 'package:fig_style/types/urls.dart';

class Reference {
  /// When this reference was released.
  Release release;

  final String id;
  final ImageProperty image;
  String lang;
  String name;
  String summary;

  ReferenceType type;

  Urls urls;

  Reference({
    this.id = '',
    this.image,
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
      image: ImageProperty.empty(),
      lang: 'en',
      name: '',
      release: Release.empty(),
      summary: '',
      type: ReferenceType(),
      urls: Urls.empty(),
    );
  }

  factory Reference.fromIdName({
    id: '',
    name: '',
  }) {
    return Reference(
      id: id,
      image: ImageProperty.empty(),
      lang: 'en',
      name: name,
      release: Release.empty(),
      summary: '',
      type: ReferenceType(),
      urls: Urls.empty(),
    );
  }

  factory Reference.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return Reference.empty();
    }

    final image = ImageProperty.fromJSON(data['image']);
    Release release = Release.fromJSON(data['release']);
    ReferenceType type = ReferenceType.fromJSON(data['type']);
    final urls = Urls.fromJSON(data['urls']);

    return Reference(
      id: data['id'] ?? '',
      image: image,
      lang: data['lang'],
      name: data['name'] ?? '',
      release: release,
      summary: data['summary'] ?? '',
      type: type,
      urls: urls,
    );
  }

  Map<String, dynamic> toJSON({bool withId = false, bool dateAsInt = false}) {
    final Map<String, dynamic> data = Map();

    if (withId) {
      data['id'] = id;
    }

    data['image'] = image.toJSON();
    data['lang'] = lang;
    data['name'] = name;
    data['release'] = release.toJSON(dateAsInt: dateAsInt);
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
