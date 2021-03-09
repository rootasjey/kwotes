import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/utils/app_logger.dart';

/// Helper for date and time conversions.
class DateHelper {
  /// Parse a date from Firestore.
  /// The raw value can be a int, Timestamp or a Map.
  /// Return a valida date and the currect date if it fails to parse ra‹ value.
  static DateTime fromFirestore(Map<String, dynamic> data) {
    DateTime date = DateTime.now();

    try {
      if (data['original'].runtimeType == int) {
        date = DateTime.fromMillisecondsSinceEpoch(data['original']);
      } else if (data['date'].runtimeType == Timestamp) {
        date = (data['date'] as Timestamp)?.toDate();
      } else if (data['date'] != null && data['date']['_seconds'] != null) {
        date = DateTime.fromMillisecondsSinceEpoch(
            data['date']['_seconds'] * 1000);
      }
    } catch (error) {
      appLogger.e(error);
    }

    return date;
  }
}
