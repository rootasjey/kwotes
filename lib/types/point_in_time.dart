import 'package:figstyle/utils/date_helper.dart';

class PointInTime {
  bool beforeJC;
  String country;
  String city;
  DateTime date;

  PointInTime({
    this.beforeJC = false,
    this.city = '',
    this.country = '',
    this.date,
  });

  factory PointInTime.empty() {
    return PointInTime(
      beforeJC: false,
      country: '',
      city: '',
      date: DateTime.now(),
    );
  }

  factory PointInTime.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return PointInTime.empty();
    }

    DateTime date = DateHelper.fromFirestore(data['original']);

    return PointInTime(
      beforeJC: data['beforeJC'],
      country: data['country'],
      city: data['city'],
      date: date,
    );
  }

  Map<String, dynamic> toJSON({bool dateAsInt = false}) {
    final data = Map<String, dynamic>();

    data['beforeJC'] = beforeJC;
    data['country'] = country;
    data['city'] = city;

    if (date == null) {
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
