import 'package:figstyle/utils/date_helper.dart';

class PointInTime {
  bool beforeJC;
  String country;
  String city;
  DateTime date;

  /// True if the Firestore [date] value is null or doesn't exist.
  /// In this app, the [date] property will never be null (null safety).
  ///
  /// This property doesn't exist in Firestore.
  bool dateEmpty;

  PointInTime({
    this.beforeJC = false,
    this.city = '',
    this.country = '',
    this.date,
    this.dateEmpty = true,
  });

  factory PointInTime.empty() {
    return PointInTime(
      beforeJC: false,
      country: '',
      city: '',
      date: DateTime.now(),
      dateEmpty: true,
    );
  }

  factory PointInTime.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return PointInTime.empty();
    }

    DateTime date = DateHelper.fromFirestore(data['date']);

    return PointInTime(
      beforeJC: data['beforeJC'],
      country: data['country'],
      city: data['city'],
      date: date,
      dateEmpty: data['date'] == null,
    );
  }

  Map<String, dynamic> toJSON({bool dateAsInt = false}) {
    final data = Map<String, dynamic>();

    data['beforeJC'] = beforeJC;
    data['country'] = country;
    data['city'] = city;

    if (date == null || dateEmpty) {
      return data;
    }

    if (dateAsInt) {
      data['date'] = date.millisecondsSinceEpoch;
    } else {
      data['date'] = date;
    }

    return data;
  }
}
