import 'package:cloud_firestore/cloud_firestore.dart';

class Release {
  /// Original release.
  DateTime original;
  bool beforeJC;

  Release({
    this.original,
    this.beforeJC = false,
  });

  factory Release.fromJSON(Map<String, dynamic> json) {
    DateTime original;

    if (json['original'] == null) {
      return Release(
        original: original,
        beforeJC: json['beforeJC'],
      );
    }

    if (json['original'].runtimeType != Timestamp) {
      original = DateTime.fromMillisecondsSinceEpoch(
          json['original']['_seconds'] * 1000);
    } else {
      original = (json['original'] as Timestamp)?.toDate();
    }

    return Release(
      original: original,
      beforeJC: json['beforeJC'],
    );
  }
}
