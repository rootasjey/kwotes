import 'package:cloud_firestore/cloud_firestore.dart';

class Release {
  /// Original release.
  DateTime original;
  bool beforeJC;

  Release({
    this.original,
    this.beforeJC = false,
  });

  factory Release.fromJSON(Map<String, dynamic> data) {
    DateTime original;

    if (data['original'] == null) {
      return Release(
        original: original,
        beforeJC: data['beforeJC'],
      );
    }

    if (data['original'].runtimeType == int) {
      original = DateTime.fromMillisecondsSinceEpoch(data['original']);
    } else if (data['original'] != null &&
        data['original'].runtimeType == Timestamp) {
      original = (data['original'] as Timestamp)?.toDate();
    } else if (data['original'].runtimeType != Timestamp &&
        data['original']['_seconds'] != null) {
      original = DateTime.fromMillisecondsSinceEpoch(
          data['original']['_seconds'] * 1000);
    }

    return Release(
      original: original,
      beforeJC: data['beforeJC'],
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
