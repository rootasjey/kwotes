import 'package:figstyle/utils/date_helper.dart';

class AppNotification {
  final String id;
  final String title;

  /// E.g. quotidians, tempquotes, ...
  /// Used to decide how to send push notification.
  final String subject;

  /// Destination page when the user clicks on this notification.
  /// E.g. Clicking on a notification about a quote in validation should
  /// redirect to the edit quote page or to the published quote page.
  final String path;
  final String body;
  bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotification({
    this.createdAt,
    this.id,
    this.body,
    this.isRead,
    this.path,
    this.subject,
    this.title,
    this.updatedAt,
  });

  factory AppNotification.empty() {
    return AppNotification(
      body: '',
      createdAt: DateTime.now(),
      id: '',
      isRead: false,
      path: '',
      subject: '',
      title: '',
      updatedAt: DateTime.now(),
    );
  }

  factory AppNotification.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return AppNotification.empty();
    }

    return AppNotification(
      body: data['body'] ?? '',
      createdAt: DateHelper.fromFirestore(data['createdAt']),
      id: data['id'] ?? '',
      isRead: data['isRead'] ?? false,
      path: data['path'] ?? '',
      subject: data['subject'] ?? '',
      title: data['title'] ?? '',
      updatedAt: DateHelper.fromFirestore(data['updatedAt']),
    );
  }
}
