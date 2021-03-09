import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/utils/app_logger.dart';

/// Helper for date and time conversions.
class DateHelper {
  /// Parse a date from Firestore.
  /// The raw value can be a int, Timestamp or a Map.
  /// Return a valida date and the currect date if it fails to parse ra‹ value.
  static DateTime fromFirestore(dynamic data) {
    DateTime date = DateTime.now();

    try {
      if (data.runtimeType == int) {
        date = DateTime.fromMillisecondsSinceEpoch(data);
      } else if (data.runtimeType == Timestamp) {
        date = (data as Timestamp)?.toDate();
      } else if (data != null && data['_seconds'] != null) {
        date = DateTime.fromMillisecondsSinceEpoch(data['_seconds'] * 1000);
      }
    } catch (error) {
      appLogger.e(error);
    }

    return date;
  }
}
