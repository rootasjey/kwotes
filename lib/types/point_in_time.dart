class PointInTime {
  String country;
  String city;
  DateTime date;

  PointInTime({
    this.city = '',
    this.country = '',
    this.date,
  });

  factory PointInTime.fromJSON(Map<String, dynamic> json) {
    return PointInTime(
      country: json['country'],
      city: json['city'],
      date: json['date'],
    );
  }
}
