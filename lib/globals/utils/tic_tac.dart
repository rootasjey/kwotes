import "package:cloud_firestore/cloud_firestore.dart";
import "package:loggy/loggy.dart";

/// Helper for date and time conversions.
class TicTac with UiLoggy {
  const TicTac();

  /// Parse a date from Firestore.
  /// The raw value can be a int, Timestamp or a Map.
  /// Return a valida date and the currect date if it fails to parse ra‹ value.
  DateTime fromFirestore(dynamic map) {
    DateTime date = DateTime.now();

    if (map == null) {
      return date;
    }

    try {
      if (map is int) {
        date = DateTime.fromMillisecondsSinceEpoch(map);
      } else if (map is Timestamp) {
        date = map.toDate();
      } else if (map is String) {
        date = DateTime.parse(map);
      } else if (map != null && map["_seconds"] != null) {
        date = DateTime.fromMillisecondsSinceEpoch(map["_seconds"] * 1000);
      }
    } catch (error) {
      loggy.error(error);
    }

    return date;
  }
}
