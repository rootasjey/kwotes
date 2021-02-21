import 'package:cloud_firestore/cloud_firestore.dart';

class PointInTime {
  bool beforeJC;
  String country;
  String city;
  DateTime date;

  PointInTime({
    this.city = '',
    this.country = '',
    this.date,
    this.beforeJC = false,
  });

  factory PointInTime.fromJSON(Map<String, dynamic> data) {
    DateTime date;

    if (data['date'].runtimeType == Timestamp) {
      date = (data['date'] as Timestamp)?.toDate();
    } else if (data['date'] != null && data['date']['_seconds'] != null) {
      date =
          DateTime.fromMillisecondsSinceEpoch(data['date']['_seconds'] * 1000);
    }

    return PointInTime(
      beforeJC: data['beforeJC'],
      country: data['country'],
      city: data['city'],
      date: date,
    );
  }

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();

    data['beforeJC'] = beforeJC;
    data['country'] = country;
    data['city'] = city;
    data['date'] = date;

    return data;
  }
}
