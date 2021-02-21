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

    if (data['original'].runtimeType != Timestamp) {
      original = DateTime.fromMillisecondsSinceEpoch(
          data['original']['_seconds'] * 1000);
    } else if (data['original'] != null &&
        data['original'].runtimeType == Timestamp) {
      original = (data['original'] as Timestamp)?.toDate();
    }

    return Release(
      original: original,
      beforeJC: data['beforeJC'],
    );
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = Map();

    data['original'] = original;
    data['beforeJC'] = beforeJC;

    return data;
  }
}
