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

  factory PointInTime.fromJSON(Map<String, dynamic> json) {
    DateTime date;

    if (json['date'] != null && json['date']['_seconds'] != null) {
      date =
          DateTime.fromMillisecondsSinceEpoch(json['date']['_seconds'] * 1000);
    } else {
      date = (json['date'] as Timestamp)?.toDate();
    }

    return PointInTime(
      beforeJC: json['beforeJC'],
      country: json['country'],
      city: json['city'],
      date: date,
    );
  }
}
