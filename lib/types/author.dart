import 'package:figstyle/types/from_reference.dart';
import 'package:figstyle/types/point_in_time.dart';
import 'package:figstyle/types/urls.dart';

class Author {
  /// Useful if the author is fictional.
  final FromReference fromReference;
  final String id;

  final PointInTime born;
  final PointInTime death;

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
    this.isFictional = false,
    this.job = '',
    this.name = '',
    this.summary = '',
    this.urls,
  });

  factory Author.empty() {
    return Author(
      born: PointInTime(),
      death: PointInTime(),
      fromReference: FromReference(),
      id: '',
      isFictional: false,
      job: '',
      name: '',
      summary: '',
      urls: Urls(),
    );
  }

  factory Author.fromJSON(Map<String, dynamic> json) {
    final urls = json['urls'] != null ? Urls.fromJSON(json['urls']) : Urls();

    final born = json['born'] != null
        ? PointInTime.fromJSON(json['born'])
        : PointInTime();

    final death = json['death'] != null
        ? PointInTime.fromJSON(json['death'])
        : PointInTime();

    final fromReference = json['fromReference'] != null
        ? FromReference.fromJSON(json['fromReference'])
        : FromReference();

    return Author(
      born: born,
      death: death,
      fromReference: fromReference,
      id: json['id'] ?? '',
      isFictional: json['isFictional'] ?? false,
      job: json['job'],
      name: json['name'],
      summary: json['summary'],
      urls: urls,
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();

    json['born'] = born;
    json['death'] = death;
    json['fromReference'] = fromReference;
    json['id'] = id;
    json['isFictional'] = isFictional;
    json['job'] = job;
    json['name'] = name;
    json['summary'] = summary;
    json['urls'] = urls;

    return json;
  }
}
