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
    return Release(
      original: (json['original'] as Timestamp)?.toDate(),
      beforeJC: json['beforeJC'],
    );
  }
}
