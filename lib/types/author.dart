import 'package:memorare/types/point_in_time.dart';
import 'package:memorare/types/urls.dart';

class Author {
  final String id;
  final String imgUrl;

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
    this.id = '',
    this.isFictional = false,
    this.imgUrl = '',
    this.job = '',
    this.name = '',
    this.summary = '',
    this.urls,
  });

  factory Author.empty() {
    return Author(
      born: PointInTime(),
      death: PointInTime(),
      id: '',
      isFictional: false,
      imgUrl: '',
      job: '',
      name: '',
      summary: '',
      urls: Urls(),
    );
  }

  factory Author.fromJSON(Map<String, dynamic> json) {
    final _urls = json['urls'] != null ? Urls.fromJSON(json['urls']) : Urls();
    final born = json['born'] != null
        ? PointInTime.fromJSON(json['born'])
        : PointInTime();
    final death = json['death'] != null
        ? PointInTime.fromJSON(json['death'])
        : PointInTime();

    return Author(
      born: born,
      death: death,
      id: json['id'] ?? '',
      isFictional: json['isFictional'] ?? false,
      imgUrl: json['imgUrl'] ?? '',
      job: json['job'],
      name: json['name'],
      summary: json['summary'],
      urls: _urls,
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();

    json['born'] = born;
    json['death'] = death;
    json['id'] = id;
    json['isFictional'] = isFictional;
    json['imgUrl'] = imgUrl;
    json['job'] = job;
    json['name'] = name;
    json['summary'] = summary;

    return json;
  }
}
