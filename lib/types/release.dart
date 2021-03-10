import 'package:figstyle/utils/date_helper.dart';

class Release {
  /// Original release.
  DateTime original;
  bool beforeJC;

  Release({
    this.original,
    this.beforeJC = false,
  });

  factory Release.empty() {
    return Release(
      original: DateTime.now(),
      beforeJC: false,
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
    );
  }

  Map<String, dynamic> toJSON({bool dateAsInt = false}) {
    final Map<String, dynamic> data = Map();

    data['beforeJC'] = beforeJC ?? false;

    if (original == null) {
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
