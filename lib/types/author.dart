import 'package:figstyle/types/from_reference.dart';
import 'package:figstyle/types/image_property.dart';
import 'package:figstyle/types/point_in_time.dart';
import 'package:figstyle/types/urls.dart';

class Author {
  /// Useful if the author is fictional.
  final FromReference fromReference;

  final PointInTime born;
  final PointInTime death;

  final String id;
  final ImageProperty image;

  /// True if the author is fictional.
  bool isFictional;

  String job;
  String name;
  String summary;

  final Urls urls;

  Author({
    this.born,
    this.death,
    this.fromReference,
    this.id = '',
    this.image,
    this.isFictional = false,
    this.job = '',
    this.name = '',
    this.summary = '',
    this.urls,
  });

  factory Author.empty() {
    return Author(
      born: PointInTime.empty(),
      death: PointInTime.empty(),
      fromReference: FromReference(),
      id: '',
      image: ImageProperty.empty(),
      isFictional: false,
      job: '',
      name: '',
      summary: '',
      urls: Urls.empty(),
    );
  }

  factory Author.fromIdName({
    id = '',
    name = '',
  }) {
    return Author(
      born: PointInTime(),
      death: PointInTime(),
      fromReference: FromReference(),
      id: id,
      image: ImageProperty.empty(),
      isFictional: false,
      job: '',
      name: name,
      summary: '',
      urls: Urls.empty(),
    );
  }

  factory Author.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return Author.empty();
    }

    final born = PointInTime.fromJSON(data['born']);
    final death = PointInTime.fromJSON(data['death']);
    final fromReference = FromReference.fromJSON(data['fromReference']);
    final image = ImageProperty.fromJSON(data['image']);
    final urls = Urls.fromJSON(data['urls']);

    return Author(
      born: born,
      death: death,
      fromReference: fromReference,
      id: data['id'] ?? '',
      image: image,
      isFictional: data['isFictional'] ?? false,
      job: data['job'] ?? '',
      name: data['name'] ?? '',
      summary: data['summary'] ?? '',
      urls: urls,
    );
  }

  Map<String, dynamic> toJSON({
    bool withId = false,
    bool dateAsInt = false,
  }) {
    Map<String, dynamic> data = Map();

    if (withId) {
      data['id'] = id;
    }

    data['born'] = born.toJSON(dateAsInt: dateAsInt);
    data['death'] = death.toJSON(dateAsInt: dateAsInt);
    data['fromReference'] = fromReference.toJSON();
    data['isFictional'] = isFictional;
    data['image'] = image.toJSON();
    data['job'] = job;
    data['name'] = name;
    data['summary'] = summary;
    data['urls'] = urls.toJSON();

    return data;
  }

  /// Return a map with only [id] and [name] as properties.
  /// Useful when converting author's data into a published quote.
  Map<String, dynamic> toPartialJSON() {
    Map<String, dynamic> data = Map();

    data['id'] = id;
    data['name'] = name;

    return data;
  }
}
