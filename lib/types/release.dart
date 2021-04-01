import 'package:fig_style/utils/date_helper.dart';

class Release {
  /// Original release.
  DateTime original;
  bool beforeJC;

  /// True if the Firestore [date] value is null or doesn't exist.
  /// In this app, the [date] property will never be null (null safety).
  ///
  /// This property doesn't exist in Firestore.
  bool dateEmpty;

  Release({
    this.original,
    this.beforeJC = false,
    this.dateEmpty = true,
  });

  factory Release.empty() {
    return Release(
      original: DateTime.now(),
      beforeJC: false,
      dateEmpty: true,
    );
  }

  factory Release.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return Release.empty();
    }

    DateTime original = DateHelper.fromFirestore(data['original']);

    return Release(
      original: original,
      beforeJC: data['beforeJC'] ?? false,
      dateEmpty: data['original'] == null,
    );
  }

  Map<String, dynamic> toJSON({bool dateAsInt = false}) {
    final Map<String, dynamic> data = Map();

    data['beforeJC'] = beforeJC ?? false;

    if (original == null || dateEmpty) {
      return data;
    }

    if (dateAsInt) {
      data['original'] = original.millisecondsSinceEpoch;
    } else {
      data['original'] = original;
    }

    return data;
  }
}
