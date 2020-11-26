import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory AppNotification.fromJSON(Map<String, dynamic> data) {
    return AppNotification(
      body: data['body'],
      createdAt: (data['createdAt'] as Timestamp)?.toDate(),
      id: data['id'],
      isRead: data['isRead'],
      path: data['path'],
      subject: data['subject'],
      title: data['title'],
      updatedAt: (data['updatedAt'] as Timestamp)?.toDate(),
    );
  }
}
