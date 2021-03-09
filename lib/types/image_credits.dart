import 'package:figstyle/utils/date_helper.dart';

class ImageCredits {
  bool beforeJC;
  String company;
  DateTime date;
  String location;
  String name;
  String artist;
  String url;

  ImageCredits({
    this.beforeJC = false,
    this.company = '',
    this.date,
    this.location = '',
    this.name = '',
    this.artist = '',
    this.url = '',
  });

  factory ImageCredits.empty() {
    return ImageCredits(
      beforeJC: false,
      company: '',
      date: DateTime.now(),
      location: '',
      name: '',
      artist: '',
      url: '',
    );
  }

  factory ImageCredits.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return ImageCredits.empty();
    }

    DateTime date;

    if (data['date'] != null) {
      date = DateHelper.fromFirestore(data['date']);
    }

    return ImageCredits(
      beforeJC: data['beforeJC'] ?? false,
      company: data['company'] ?? '',
      date: date,
      location: data['location'] ?? '',
      name: data['name'] ?? '',
      artist: data['artist'] ?? '',
      url: data['url'] ?? '',
    );
  }

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();

    data['beforeJC'] = beforeJC;
    data['company'] = company;
    data['date'] = date.millisecondsSinceEpoch;
    data['location'] = location;
    data['name'] = name;
    data['artist'] = artist;
    data['url'] = url;

    return data;
  }
}
